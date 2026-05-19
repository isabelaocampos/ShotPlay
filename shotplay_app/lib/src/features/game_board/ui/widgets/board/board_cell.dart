import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';

class BoardCell extends StatelessWidget {
  const BoardCell({
    super.key,
    required this.data,
    required this.size,
    this.isHighlighted = false,
  });

  final BoardCellData data;
  final double size;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final borderColor = data.borderColor;
    final baseGlow = data.isSpecial ? 0.22 : 0.10;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            borderColor.withValues(alpha: data.isSpecial ? 0.18 : 0.10),
            const Color(0xFF110B18).withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.16),
        border: Border.all(
          color: borderColor.withValues(
            alpha: isHighlighted ? 0.95 : (data.isSpecial ? 0.70 : 0.45),
          ),
          width: isHighlighted ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: neonGlow(borderColor, baseGlow),
            blurRadius: isHighlighted ? 18 : 10,
            spreadRadius: isHighlighted ? 1.5 : 0.5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.16),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.6),
                    radius: 1.2,
                    colors: [
                      borderColor.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              top: 6,
              child: Text(
                '${data.square}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: borderColor.withValues(alpha: 0.55),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            if (data.overlay != null)
              Center(
                child: Opacity(
                  opacity: data.isSpecial ? 1 : 0.85,
                  child: data.overlay!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
