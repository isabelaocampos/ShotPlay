import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePrimaryButton extends StatelessWidget {
  const WelcomePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: const Color(0xFF7F0DF2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x667F0DF2),
              blurRadius: 25,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFE5D0FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFE5D0FF),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
        ),
      ),
    );
  }
}
