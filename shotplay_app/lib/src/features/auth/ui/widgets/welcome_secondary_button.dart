import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeSecondaryButton extends StatelessWidget {
  const WelcomeSecondaryButton({
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
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: const Color(0x19A50EEB),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 2,
              color: Color(0x66A50EEB),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            foregroundColor: const Color(0xFFA40EEA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFA40EEA),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
