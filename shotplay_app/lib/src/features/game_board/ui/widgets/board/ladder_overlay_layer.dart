import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';

class LadderOverlayLayer extends StatelessWidget {
  const LadderOverlayLayer({
    super.key,
    required this.cellSize,
  });

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final ladders = ladderOverlayData();

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (var i = 0; i < ladders.length; i++)
              _LadderAssetOverlay(
                overlay: ladders[i],
                cellSize: cellSize,
                tintColor: switch (i % 3) {
                  0 => const Color(0xFF07FCFE),
                  1 => const Color(0xFFFFD84D),
                  _ => const Color(0xFFBFFBF9),
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LadderAssetOverlay extends StatelessWidget {
  const _LadderAssetOverlay({
    required this.overlay,
    required this.cellSize,
    required this.tintColor,
  });

  final BoardOverlayData overlay;
  final double cellSize;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final placement = ladderPlacementFor(overlay, cellSize);

    return Positioned(
      left: placement.left,
      top: placement.top,
      child: Opacity(
        opacity: 0.86,
        child: Transform.rotate(
          angle: placement.rotation,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8),
                child: SizedBox(
                  width: placement.width * 1.01,
                  height: placement.height * 1.01,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      tintColor.withValues(alpha: 0.34),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(overlay.asset, fit: BoxFit.contain),
                  ),
                ),
              ),
              SizedBox(
                width: placement.width,
                height: placement.height,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    tintColor.withValues(alpha: 0.92),
                    BlendMode.modulate,
                  ),
                  child: Image.asset(overlay.asset, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
