import 'package:flutter/material.dart';

import '../../domain/entities/board_entities.dart';

// ?????? Colour palette (matches Figma design) ???????????????????????????????????????????????????????????????????????????
const _kBg = Color(0xFF191022);
const _kCellBorder = Color(0xFF252336);

// Cell colours
const _kYellow = Color(0xFFFFCF12); // ladder base rows (31???36, 43???48)
const _kPink = Color(0xFFFF339A);   // snake head rows (37???42, 55???60 on 10??10)
const _kLime = Color(0xFFBAFA5E);   // take-a-shot
const _kCyan = Color(0xFF07FCFE);   // give-a-shot
const _kPlain = Color(0xFFA50EEB);  // default faint purple

// Snake / ladder colours
const _kSnakeBody = Color(0xFFFFAE29);
const _kSnakeRib = Color(0xFFFEE967);

/// Returns the accent colour for [square] on the 7??7 board.
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
  return Colors.white.withOpacity(0.0); // transparent ??? plain dark cell
}

/// Converts a 1-based square number to a [row, col] in the grid where
/// row 0 is the TOP row (square 43???49) and col 0 is the LEFT column.
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

              // Snakes
              ...BoardDefinition.snakes.entries.map((e) => _SnakePainter(
                    headSquare: e.key,
                    tailSquare: e.value,
                    cellSize: cellSize,
                  )),

              // Ladders
              ...BoardDefinition.ladders.entries.map((e) => _LadderPainter(
                    baseSquare: e.key,
                    topSquare: e.value,
                    cellSize: cellSize,
                  )),

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

// ── Snake Painter ──────────────────────────────────────────────────

class _SnakePainter extends StatelessWidget {
  const _SnakePainter({
    required this.headSquare,
    required this.tailSquare,
    required this.cellSize,
  });

  final int headSquare;
  final int tailSquare;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final head = squareToGridPos(headSquare);
    final tail = squareToGridPos(tailSquare);

    final x1 = head.col * cellSize + cellSize / 2;
    final y1 = head.row * cellSize + cellSize / 2;
    final x2 = tail.col * cellSize + cellSize / 2;
    final y2 = tail.row * cellSize + cellSize / 2;

    return Positioned.fill(
      child: CustomPaint(
        painter: _SnakePaintDelegate(
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          cellSize: cellSize,
        ),
      ),
    );
  }
}

class _SnakePaintDelegate extends CustomPainter {
  const _SnakePaintDelegate({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.cellSize,
  });

  final double x1, y1, x2, y2, cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = _kSnakeBody
      ..strokeWidth = cellSize * 0.16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final ribPaint = Paint()
      ..color = _kSnakeRib
      ..strokeWidth = cellSize * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    // Curved body
    final path = Path();
    path.moveTo(x1, y1);
    final cpX = (x1 + x2) / 2 + (y2 - y1) * 0.3;
    final cpY = (y1 + y2) / 2 - (x2 - x1) * 0.3;
    path.quadraticBezierTo(cpX, cpY, x2, y2);
    canvas.drawPath(path, bodyPaint);

    // Ribs along path (simplified: draw dashes)
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final length = metric.length;
      for (double d = cellSize * 0.2; d < length; d += cellSize * 0.3) {
        final pos = metric.getTangentForOffset(d);
        if (pos == null) continue;
        final nx = -pos.vector.dy * cellSize * 0.1;
        final ny = pos.vector.dx * cellSize * 0.1;
        canvas.drawLine(
          Offset(pos.position.dx - nx, pos.position.dy - ny),
          Offset(pos.position.dx + nx, pos.position.dy + ny),
          ribPaint,
        );
      }
    }

    // Head circle
    canvas.drawCircle(Offset(x1, y1), cellSize * 0.12, Paint()..color = _kPink);
  }

  @override
  bool shouldRepaint(covariant _SnakePaintDelegate old) =>
      old.x1 != x1 || old.y1 != y1;
}

// ── Ladder Painter ─────────────────────────────────────────────────

class _LadderPainter extends StatelessWidget {
  const _LadderPainter({
    required this.baseSquare,
    required this.topSquare,
    required this.cellSize,
  });

  final int baseSquare;
  final int topSquare;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final base = squareToGridPos(baseSquare);
    final top = squareToGridPos(topSquare);

    final bx = base.col * cellSize + cellSize / 2;
    final by = base.row * cellSize + cellSize / 2;
    final tx = top.col * cellSize + cellSize / 2;
    final ty = top.row * cellSize + cellSize / 2;

    return Positioned.fill(
      child: CustomPaint(
        painter: _LadderPaintDelegate(
          bx: bx,
          by: by,
          tx: tx,
          ty: ty,
          cellSize: cellSize,
        ),
      ),
    );
  }
}

class _LadderPaintDelegate extends CustomPainter {
  const _LadderPaintDelegate({
    required this.bx,
    required this.by,
    required this.tx,
    required this.ty,
    required this.cellSize,
  });

  final double bx, by, tx, ty, cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final railPaint = Paint()
      ..color = _kSnakeBody
      ..strokeWidth = cellSize * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rungPaint = Paint()
      ..color = _kSnakeRib
      ..strokeWidth = cellSize * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final offset = cellSize * 0.12;
    final dx = ty - by;
    final dy = -(tx - bx);
    final mag = (dx * dx + dy * dy).abs();
    if (mag == 0) return;
    final norm = mag == 0 ? 1.0 : (1 / mag);
    final ox = dx * norm * offset * 8;
    final oy = dy * norm * offset * 8;

    // Two rails
    canvas.drawLine(Offset(bx - ox, by - oy), Offset(tx - ox, ty - oy), railPaint);
    canvas.drawLine(Offset(bx + ox, by + oy), Offset(tx + ox, ty + oy), railPaint);

    // Rungs
    final steps = ((ty - by).abs() / (cellSize * 0.28)).round().clamp(3, 12);
    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      final rx = bx + (tx - bx) * t;
      final ry = by + (ty - by) * t;
      canvas.drawLine(Offset(rx - ox, ry - oy), Offset(rx + ox, ry + oy), rungPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LadderPaintDelegate old) =>
      old.bx != bx || old.by != by;
}

// Player Token
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

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
