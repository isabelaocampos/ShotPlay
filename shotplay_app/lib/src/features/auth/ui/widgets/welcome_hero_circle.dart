import 'package:flutter/material.dart';
import 'package:shotplay_app/src/core/resources/app_images.dart';

class WelcomeHeroCircle extends StatelessWidget {
  const WelcomeHeroCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 358,
      height: 358,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 358,
              height: 358,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0x198B5CF6),
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              width: 326,
              height: 326,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0x338B5CF6),
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 288,
              height: 288,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0x00FFFFFF),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 2,
                    color: Color(0x4C8B5CF6),
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x667F0DF2),
                    blurRadius: 25,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  SizedBox(
                    width: 363,
                    height: 303,
                    child: Image.asset(
                      AppImages.welcomeBg,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    left: 2,
                    top: 2,
                    child: Container(
                      width: 284,
                      height: 284,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.25, 1.00),
                          end: Alignment(0.89, 0.23),
                          colors: [
                            Color(0x7F121B2A),
                            Color(0x00191022),
                            Color(0x00191022),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
