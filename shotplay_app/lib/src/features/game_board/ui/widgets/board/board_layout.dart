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
  });

  final int startSquare;
  final int endSquare;
  final String asset;
}

List<BoardOverlayData> snakeOverlayData() {
  return BoardDefinition.snakes.entries.map((entry) {
    return BoardOverlayData(
      startSquare: entry.key,
      endSquare: entry.value,
      asset: entry.key.isEven
          ? 'assets/images/snake1.png'
          : 'assets/images/snake2.png',
    );
  }).toList();
}

List<BoardOverlayData> ladderOverlayData() {
  return BoardDefinition.ladders.entries.map((entry) {
    final index = BoardDefinition.ladders.keys.toList().indexOf(entry.key);
    return BoardOverlayData(
      startSquare: entry.key,
      endSquare: entry.value,
      asset: switch (index % 3) {
        0 => 'assets/images/ladder1.png',
        1 => 'assets/images/ladder2.png',
        _ => 'assets/images/ladder3.png',
      },
    );
  }).toList();
}

BoardOverlayPlacement snakePlacementFor(BoardOverlayData overlay, double cellSize) {
  return _placementBetweenSquares(
    overlay.startSquare,
    overlay.endSquare,
    cellSize,
    lengthPadding: cellSize * 0.12,
    thickness: cellSize * 0.40,
    rotationOffset: 0,
  );
}

BoardOverlayPlacement ladderPlacementFor(BoardOverlayData overlay, double cellSize) {
  return _placementBetweenSquares(
    overlay.startSquare,
    overlay.endSquare,
    cellSize,
    lengthPadding: cellSize * 0.12,
    thickness: cellSize * 0.38,
    rotationOffset: -math.pi / 2,
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
  }).toList();
}

List<BoardOverlayData> ladderOverlayData() {
  return BoardDefinition.ladders.entries.map((entry) {
    final index = BoardDefinition.ladders.keys.toList().indexOf(entry.key);
    return BoardOverlayData(
      startSquare: entry.key,
      endSquare: entry.value,
      asset: switch (index % 3) {
        0 => 'assets/images/ladder1.png',
        1 => 'assets/images/ladder2.png',
        _ => 'assets/images/ladder3.png',
      },
    );
  }).toList();
}

BoardOverlayPlacement snakePlacementFor(BoardOverlayData overlay, double cellSize) {
  return _placementBetweenSquares(
    overlay.startSquare,
    overlay.endSquare,
    cellSize,
    lengthPadding: cellSize * 0.12,
    thickness: cellSize * 0.40,
    rotationOffset: 0,
  );
}

BoardOverlayPlacement ladderPlacementFor(BoardOverlayData overlay, double cellSize) {
  return _placementBetweenSquares(
    overlay.startSquare,
    overlay.endSquare,
    cellSize,
    lengthPadding: cellSize * 0.12,
    thickness: cellSize * 0.38,
    rotationOffset: -math.pi / 2,
  );
}

BoardOverlayPlacement _placementBetweenSquares(
  int startSquare,
  int endSquare,
  double cellSize, {
  final distance = math.sqrt(dx * dx + dy * dy);
  final safeDistance = distance == 0 ? 1.0 : distance;
  final unitX = dx / safeDistance;
