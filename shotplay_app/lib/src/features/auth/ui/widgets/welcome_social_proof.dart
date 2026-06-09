import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shotplay_app/src/core/resources/app_images.dart';

class WelcomeSocialProof extends StatelessWidget {
  const WelcomeSocialProof({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AvatarCircle(imagePath: AppImages.firstAvatar),
            const SizedBox(width: 8),
            const _AvatarCircle(imagePath: AppImages.secondAvatar),
            const SizedBox(width: 8),
            const _AvatarCircle(imagePath: AppImages.thirdAvatar),
            const SizedBox(width: 8),
            _AvatarCount(count: '+9k'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 191.5,
          height: 48,
          child: Text(
            'Unete a miles de\njugadores en tiempo real',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xCCCEC2D9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.fill,
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 2,
            color: Color(0xFF191022),
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }
}

class _AvatarCount extends StatelessWidget {
  const _AvatarCount({required this.count});

  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: ShapeDecoration(
        color: const Color(0xFF2D2834),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 2,
            color: Color(0xFF191022),
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Center(
        child: Text(
          count,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFE9DFEF),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
