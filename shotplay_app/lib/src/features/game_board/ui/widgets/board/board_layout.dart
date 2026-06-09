import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';

({int row, int col}) squareToGridPos(int square, {int size = 7}) {
  assert(square >= 1 && square <= size * size);
  final idx = square - 1;
  final rowFromBottom = idx ~/ size;
  final colFromLeft =
      rowFromBottom.isEven ? idx % size : (size - 1) - idx % size;
  final row = (size - 1) - rowFromBottom;
  return (row: row, col: colFromLeft);
}

int gridPosToSquare(int row, int col, {int size = 7}) {
  final rowFromBottom = (size - 1) - row;
  return rowFromBottom * size + (rowFromBottom.isEven ? col + 1 : size - col);
}

double clamp01(double value) => value.clamp(0.0, 1.0).toDouble();

Offset squareCenter(int square, double cellSize) {
  final pos = squareToGridPos(square);
  return Offset(
    pos.col * cellSize + cellSize / 2,
    pos.row * cellSize + cellSize / 2,
  );
}

Color neonGlow(Color color, [double alpha = 0.18]) =>
    color.withValues(alpha: clamp01(alpha));

class BoardOverlayPlacement {
  const BoardOverlayPlacement({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.rotation = 0,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double rotation;
}

class BoardOverlayData {
  const BoardOverlayData({
    required this.startSquare,
    required this.endSquare,
    required this.asset,
    this.isLong = false,
  });

  final int startSquare;
  final int endSquare;
  final String asset;
  final bool isLong;
}

const Map<String, double> assetAspectRatios = {
  'assets/images/ladder1.png': 1 / 2.5,
  'assets/images/ladder2.png': 1 / 4.5,
  'assets/images/ladder3.png': 1 / 3.5,
  'assets/images/snake1.png': 1 / 2.8,
  'assets/images/snake2.png': 1 / 2.2,
};

List<BoardOverlayData> snakeOverlayData() {
  return BoardDefinition.snakes.entries.map((entry) {
    final distance = (entry.key - entry.value).abs();
    return BoardOverlayData(
      startSquare: entry.key,
      endSquare: entry.value,
      asset: '',
      isLong: distance > 12,
    );
  }).toList();
}

List<BoardOverlayData> ladderOverlayData() {
  return BoardDefinition.ladders.entries.map((entry) {
    final distance = (entry.value - entry.key).abs();
    return BoardOverlayData(
      startSquare: entry.key,
      endSquare: entry.value,
      asset: distance > 20
          ? 'assets/images/ladder2.png'
          : distance > 15
              ? 'assets/images/ladder3.png'
              : 'assets/images/ladder1.png',
    );
  }).toList();
}

BoardOverlayPlacement snakePlacementFor(BoardOverlayData overlay, double cellSize) {
  return _placementBetweenSquares(
    overlay.startSquare,
    overlay.endSquare,
    cellSize,
    lengthPadding: cellSize * 0.12,
    thickness: cellSize * 0.55,
    rotationOffset: 0,
  );
}

BoardOverlayPlacement ladderPlacementFor(BoardOverlayData overlay, double cellSize) {
  return _placementBetweenSquares(
    overlay.startSquare,
    overlay.endSquare,
    cellSize,
    lengthPadding: cellSize * 0.12,
    thickness: cellSize * 0.28,
    rotationOffset: 0,
  );
}

BoardOverlayPlacement _placementBetweenSquares(
  int startSquare,
  int endSquare,
  double cellSize, {
  required double lengthPadding,
  required double thickness,
  required double rotationOffset,
}) {
  final start = squareCenter(startSquare, cellSize);
  final end = squareCenter(endSquare, cellSize);
  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;
  final distance = math.sqrt(dx * dx + dy * dy);
  final safeDistance = distance == 0 ? 1.0 : distance;
  final unitX = dx / safeDistance;
  final unitY = dy / safeDistance;
  final edgeInset = cellSize * 0.26;

  final startEdge = Offset(
    start.dx + unitX * edgeInset,
    start.dy + unitY * edgeInset,
  );
  final endEdge = Offset(
    end.dx - unitX * edgeInset,
    end.dy - unitY * edgeInset,
  );

  final edgeDx = endEdge.dx - startEdge.dx;
  final edgeDy = endEdge.dy - startEdge.dy;
  final edgeDistance = math.sqrt(edgeDx * edgeDx + edgeDy * edgeDy);
  final midpoint = Offset(
    (startEdge.dx + endEdge.dx) / 2,
    (startEdge.dy + endEdge.dy) / 2,
  );
  final angle = math.atan2(edgeDy, edgeDx) + rotationOffset;
  final length = edgeDistance + lengthPadding;
  return BoardOverlayPlacement(
    left: midpoint.dx - length / 2,
    top: midpoint.dy - thickness / 2,
    width: length,
    height: thickness,
    rotation: angle,
  );
}

