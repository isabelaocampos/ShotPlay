import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.00, 0.00),
                radius: 1.41,
                colors: [Color(0x267F0DF2), Color(0x007F0DF2)],
              ),
            ),
          ),
        ),
        Positioned(
          left: -39,
          top: -88.39,
          child: Container(
            width: 156,
            height: 353.59,
            decoration: ShapeDecoration(
              color: const Color(0x19D7BAFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
        Positioned(
          left: 273,
          top: 618.80,
          child: Container(
            width: 156,
            height: 353.59,
            decoration: ShapeDecoration(
              color: const Color(0x19FE6B00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
