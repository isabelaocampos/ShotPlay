import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_cell.dart';
import 'board_layout.dart';

class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.highlightSquare,
  });

  final int? highlightSquare;

  static const int _size = 7;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        final cellSize = boardSize / _size;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Column(
            children: List.generate(_size, (row) {
              return Row(
                children: List.generate(_size, (col) {
                  final square = gridPosToSquare(row, col, size: _size);
                  final data = _cellDataForSquare(square);

                  return BoardCell(
                    data: data,
                    size: cellSize,
                    isHighlighted: square == highlightSquare,
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }

  BoardCellData _cellDataForSquare(int square) {
    final specialCell = BoardDefinition.specialCellFor(square);
    if (specialCell != null) {
      return BoardCellData(
        square: square,
        borderColor: switch (specialCell.type) {
          SpecialCellType.takeShot => const Color(0xFFBAFA5E),
          SpecialCellType.giveShot => const Color(0xFF07FCFE),
          SpecialCellType.truthOrDare => const Color(0xFFFFBDF5),
          SpecialCellType.waterfall => const Color(0xFF07FCFE),
          SpecialCellType.splitShots => const Color(0xFFFFBDF5),
          SpecialCellType.giveShots => const Color(0xFFFEE967),
          SpecialCellType.revengeShot => const Color(0xFFFF339A),
          SpecialCellType.neverHaveIEver => const Color(0xFFA50EEB),
          SpecialCellType.mostLikelyTo => const Color(0xFFBFFBF9),
          SpecialCellType.trapCell => const Color(0xFFF97316),
          SpecialCellType.silentRound => const Color(0xFF94A3B8),
        },
        overlay: _SpecialCellPulse(
          color: switch (specialCell.type) {
            SpecialCellType.takeShot => const Color(0xFFBAFA5E),
            SpecialCellType.giveShot => const Color(0xFF07FCFE),
            SpecialCellType.truthOrDare => const Color(0xFFFFBDF5),
            SpecialCellType.waterfall => const Color(0xFF07FCFE),
            SpecialCellType.splitShots => const Color(0xFFFFBDF5),
            SpecialCellType.giveShots => const Color(0xFFFEE967),
            SpecialCellType.revengeShot => const Color(0xFFFF339A),
            SpecialCellType.neverHaveIEver => const Color(0xFFA50EEB),
            SpecialCellType.mostLikelyTo => const Color(0xFFBFFBF9),
            SpecialCellType.trapCell => const Color(0xFFF97316),
            SpecialCellType.silentRound => const Color(0xFF94A3B8),
          },
        ),
        isSpecial: true,
      );
    }

    if (BoardDefinition.snakes.containsKey(square)) {
      return BoardCellData(
        square: square,
        borderColor: const Color(0xFFFF339A),
      );
    }

    if (BoardDefinition.ladders.containsKey(square)) {
      return BoardCellData(
        square: square,
        borderColor: const Color(0xFF07FCFE),
      );
    }

    return BoardCellData(
      square: square,
      borderColor: const Color(0xFFA50EEB),
    );
  }
}

class _SpecialCellPulse extends StatelessWidget {
  const _SpecialCellPulse({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.88),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
