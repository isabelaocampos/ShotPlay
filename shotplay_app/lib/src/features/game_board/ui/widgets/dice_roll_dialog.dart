import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class DiceRollDialog extends StatefulWidget {
  const DiceRollDialog({super.key, required this.value});

  final int value;

  @override
  State<DiceRollDialog> createState() => _DiceRollDialogState();
}

class _DiceRollDialogState extends State<DiceRollDialog>
    with SingleTickerProviderStateMixin {
  static const Duration _rollDuration = Duration(milliseconds: 1200);
  static const Duration _settleDuration = Duration(milliseconds: 700);

  final _random = math.Random();
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;
  late final Animation<double> _shake;

  Timer? _tickTimer;
  int _displayedValue = 1;
  bool _settling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _rollDuration + _settleDuration,
    )..forward();

    final scaleCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
    );
    final rotationCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
    );
    final shakeCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeInOut),
    );

    _scale = Tween<double>(begin: 0.72, end: 1).animate(scaleCurve);
    _rotation = Tween<double>(begin: -0.3, end: 0).animate(rotationCurve);
    _shake = Tween<double>(begin: -10, end: 10).animate(shakeCurve);

    _displayedValue = _random.nextInt(6) + 1;
    _tickTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsed = timer.tick * 90;
      if (elapsed >= _rollDuration.inMilliseconds) {
        setState(() {
          _settling = true;
          _displayedValue = widget.value;
        });
        timer.cancel();
        return;
      }

      setState(() {
        _displayedValue = _random.nextInt(6) + 1;
      });
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final rollingPhase = _controller.value < 0.85 && !_settling;
            final shakeOffset = rollingPhase ? _shake.value : 0.0;

            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: Transform.rotate(
                angle: _rotation.value * math.pi,
                child: Transform.scale(scale: _scale.value, child: child),
              ),
            );
          },
          child: Container(
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1227),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF5F0F86), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5F0F86).withValues(
                    alpha: _settling ? 0.45 : 0.30,
                  ),
                  blurRadius: _settling ? 34 : 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sacó',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 18),
                AspectRatio(
                  aspectRatio: 1,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 120),
                    transitionBuilder: (child, animation) {
                      final fade = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      );
                      return FadeTransition(
                        opacity: fade,
                        child: ScaleTransition(scale: fade, child: child),
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(_displayedValue),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF7B1FA2), Color(0xFF5F0F86)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.white24, width: 1.4),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: _settling ? 0.12 : 0.06,
                                      ),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _DicePipsFace(value: _displayedValue),
                          if (!_settling)
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.18),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    _settling
                        ? 'Resultado del lanzamiento'
                        : 'Rodando...',
                    key: ValueKey<String>(_settling ? 'final' : 'rolling'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DicePipsFace extends StatelessWidget {
  const _DicePipsFace({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    const double pipSize = 14;
    const pipColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final center = constraints.maxWidth / 2;
          final offset = constraints.maxWidth * 0.22;

          Offset pos(double dx, double dy) => Offset(center + dx, center + dy);

          final pips = <Offset>[];

          switch (value) {
            case 1:
              pips.add(pos(0, 0));
              break;
            case 2:
              pips.addAll([pos(-offset, -offset), pos(offset, offset)]);
              break;
            case 3:
              pips.addAll([
                pos(-offset, -offset),
                pos(0, 0),
                pos(offset, offset),
              ]);
              break;
            case 4:
              pips.addAll([
                pos(-offset, -offset),
                pos(offset, -offset),
                pos(-offset, offset),
                pos(offset, offset),
              ]);
              break;
            case 5:
              pips.addAll([
                pos(-offset, -offset),
                pos(offset, -offset),
                pos(0, 0),
                pos(-offset, offset),
                pos(offset, offset),
              ]);
              break;
            case 6:
            default:
              pips.addAll([
                pos(-offset, -offset),
                pos(offset, -offset),
                pos(-offset, 0),
                pos(offset, 0),
                pos(-offset, offset),
                pos(offset, offset),
              ]);
              break;
          }

          return Stack(
            children: [
              for (final pip in pips)
                Positioned(
                  left: pip.dx - (pipSize / 2),
                  top: pip.dy - (pipSize / 2),
                  child: Container(
                    width: pipSize,
                    height: pipSize,
                    decoration: BoxDecoration(
                      color: pipColor,
                      borderRadius: BorderRadius.circular(pipSize),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}