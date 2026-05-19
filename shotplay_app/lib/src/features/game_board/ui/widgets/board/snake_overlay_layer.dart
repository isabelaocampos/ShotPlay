import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';

class SnakeOverlayLayer extends StatelessWidget {
  const SnakeOverlayLayer({
    super.key,
    required this.cellSize,
  });

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final snakes = snakeOverlayData();

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (var i = 0; i < snakes.length; i++)
              _SnakeAssetOverlay(
                overlay: snakes[i],
                cellSize: cellSize,
                tintColor: i.isEven
                    ? const Color(0xFFFF4BCB)
                    : const Color(0xFF6CFBFF),
              ),
          ],
        ),
      ),
    );
  }
}

class _SnakeAssetOverlay extends StatelessWidget {
  const _SnakeAssetOverlay({
    required this.overlay,
    required this.cellSize,
    required this.tintColor,
  });

  final BoardOverlayData overlay;
  final double cellSize;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final placement = snakePlacementFor(overlay, cellSize);

    return Positioned(
      left: placement.left,
      top: placement.top,
      child: Opacity(
        opacity: 0.96,
        child: Transform.rotate(
          angle: placement.rotation,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: SizedBox(
                  width: placement.width * 1.02,
                  height: placement.height * 1.02,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      tintColor.withValues(alpha: 0.40),
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
