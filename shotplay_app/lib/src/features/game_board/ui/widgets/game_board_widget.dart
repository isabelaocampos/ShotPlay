import 'package:flutter/material.dart';

import '../../domain/entities/board_entities.dart';

// ── Colour palette (matches Figma design) ─────────────────────────
const _kBg = Color(0xFF191022);
const _kCellBorder = Color(0xFF252336);

// Cell colours
const _kYellow = Color(0xFFFFCF12); // ladder base rows (31–36, 43–48)
const _kPink = Color(0xFFFF339A);   // snake head rows (37–42, 55–60 on 10×10)
const _kLime = Color(0xFFBAFA5E);   // take-a-shot
const _kCyan = Color(0xFF07FCFE);   // give-a-shot
const _kPlain = Color(0xFFA50EEB);  // default faint purple

/// Returns the accent colour for [square] on the 7×7 board.
/// Mirrors the Figma export colours.
Color _cellColor(int square) {
  // Give-a-shot squares (cyan)
  const cyanSquares = {4, 6, 8, 16, 18, 20, 28, 30};
  // Take-a-shot squares (lime)
  const limeSquares = {2, 10, 12, 14, 22, 24, 26};
  // Pink / snake rows
  const pinkSquares = {32, 40, 44, 52, 54, 56};
  // Yellow / ladder rows
  const yellowSquares = {34, 36, 38, 46, 48, 50, 58, 60};

  if (cyanSquares.contains(square)) return _kCyan;
  if (limeSquares.contains(square)) return _kLime;
  if (pinkSquares.contains(square)) return _kPink;
  if (yellowSquares.contains(square)) return _kYellow;
  // Odd squares that are just plain
  return Colors.white.withOpacity(0.0); // transparent → plain dark cell
}

/// Converts a 1-based square number to a [row, col] in the grid where
/// row 0 is the TOP row (square 43–49) and col 0 is the LEFT column.
/// Uses the boustrophedon (snake-path) numbering of the reference board.
({int row, int col}) squareToGridPos(int square, {int size = 7}) {
  assert(square >= 1 && square <= size * size);
  // Zero-based from bottom-left
  final idx = square - 1;
  final rowFromBottom = idx ~/ size;
  final colFromLeft =
      rowFromBottom.isEven ? idx % size : (size - 1) - idx % size;
  // Flip so row 0 is top
  final row = (size - 1) - rowFromBottom;
  return (row: row, col: colFromLeft);
}

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({
    super.key,
    required this.positions,
    this.highlightSquare,
  });

  final List<PlayerPosition> positions;
  final int? highlightSquare;

  static const int _size = 7;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final boardSize = constraints.maxWidth;
        final cellSize = boardSize / _size;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              // Grid cells
              Column(
                children: List.generate(_size, (row) {
                  return Row(
                    children: List.generate(_size, (col) {
                      final square = _gridToSquare(row, col);
                      return _BoardCell(
                        square: square,
                        size: cellSize,
                        isHighlighted: square == highlightSquare,
                      );
                    }),
                  );
                }),
              ),

              // Player tokens
              ...positions.map((p) => _PlayerToken(
                    position: p,
                    cellSize: cellSize,
                    allPositions: positions,
                  )),
            ],
          ),
        );
      },
    );
  }

  static int _gridToSquare(int row, int col) {
    final rowFromBottom = (_size - 1) - row;
    final square = rowFromBottom * _size +
        (rowFromBottom.isEven ? col + 1 : _size - col);
    return square;
  }
}

// ── Individual Cell ────────────────────────────────────────────────

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.square,
    required this.size,
    required this.isHighlighted,
  });

  final int square;
  final double size;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final accent = _cellColor(square);
    final hasAccent = accent.alpha > 0;
    final hasBorder = hasAccent;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasAccent
            ? accent.withOpacity(0.10)
            : const Color(0xff0ca50eeb).withOpacity(0.047),
        border: Border.all(
          color: hasBorder ? accent : Colors.white.withOpacity(0.12),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            '$square',
            style: TextStyle(
              color: hasAccent ? accent : Colors.white.withOpacity(0.55),
              fontSize: size * 0.18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Player Token ───────────────────────────────────────────────────

const _tokenColors = [
  Color(0xFFBFFBF9), // cyan-ish
  Color(0xFFFEE967), // yellow
  Color(0xFFFFBDF5), // pink
  Color(0xFFBAFA5E), // lime
];

class _PlayerToken extends StatelessWidget {
  const _PlayerToken({
    required this.position,
    required this.cellSize,
    required this.allPositions,
  });

  final PlayerPosition position;
  final double cellSize;
  final List<PlayerPosition> allPositions;

  @override
  Widget build(BuildContext context) {
    final gridPos = squareToGridPos(position.square);

    // Offset tokens that share a cell
    final sameCell =
        allPositions.where((p) => p.square == position.square).toList();
    final myIndex = sameCell.indexOf(position);
    final offsetX = myIndex.isOdd ? cellSize * 0.25 : -cellSize * 0.25;
    final offsetY = myIndex >= 2 ? cellSize * 0.25 : -cellSize * 0.25;

    final cx =
        gridPos.col * cellSize + cellSize / 2 + (sameCell.length > 1 ? offsetX : 0);
    final cy =
        gridPos.row * cellSize + cellSize / 2 + (sameCell.length > 1 ? offsetY : 0);
    final r = cellSize * 0.26;

    final color = _tokenColors[position.avatarIndex % _tokenColors.length];

    return Positioned(
      left: cx - r,
      top: cy - r,
      child: Container(
        width: r * 2,
        height: r * 2,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E0412), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: Center(
          child: Text(
            position.username.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: const Color(0xFF1E0412),
              fontSize: r * 0.85,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
