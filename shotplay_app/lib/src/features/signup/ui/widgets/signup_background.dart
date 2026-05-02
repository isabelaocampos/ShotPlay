import 'package:flutter/material.dart';

class SignupBackground extends StatelessWidget {
  const SignupBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFF16111C)),
          ),
        ),
        Positioned(
          left: 214,
          top: 199.25,
          child: Container(
            width: 256,
            height: 256,
            decoration: ShapeDecoration(
              color: const Color(0x197F0DF2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
        Positioned(
          left: -80,
          top: 242.75,
          child: Container(
            width: 256,
            height: 256,
            decoration: ShapeDecoration(
              color: const Color(0x0CFFB693),
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
