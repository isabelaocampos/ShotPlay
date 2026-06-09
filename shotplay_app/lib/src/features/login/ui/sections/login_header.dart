import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: -0.10,
                  child: Container(
                    width: 70.34,
                    height: 70.34,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF7F0DF2),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: Colors.white.withOpacity(0.20),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x997F0DF2),
                          blurRadius: 30,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      // Icon container: centered so it never clips on rotation.
                      child: SvgPicture.asset(
                        'assets/images/Icon_controler.svg',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'SHOTPLAY',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFE9DFEF),
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.75,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bienvenido de nuevo',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFD7BAFF),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Opacity(
          opacity: 0.8,
          child: Text(
            'Inicia sesion para volver a jugar',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFCEC2D9),
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
