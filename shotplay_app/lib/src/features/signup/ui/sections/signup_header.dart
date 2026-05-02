import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Unete a la Arena',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFE9DFEF),
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Crea tu perfil de ',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFCEC2D9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: 'Jugador',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFFFB693),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' y empieza a competir.',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFCEC2D9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
