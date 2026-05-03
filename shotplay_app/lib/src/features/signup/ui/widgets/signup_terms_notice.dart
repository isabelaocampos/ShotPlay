import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupTermsNotice extends StatelessWidget {
  const SignupTermsNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Al registrarte, aceptas nuestros ',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0x7F978DA2),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.63,
              ),
            ),
            TextSpan(
              text: 'Terminos de Servicio',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0x7F978DA2),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                height: 1.63,
              ),
            ),
            TextSpan(
              text: ' y ',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0x7F978DA2),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.63,
              ),
            ),
            TextSpan(
              text: 'Politica de Privacidad',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0x7F978DA2),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                height: 1.63,
              ),
            ),
            TextSpan(
              text: '. ShotPlay utiliza encriptacion de grado militar para tus datos.',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0x7F978DA2),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.63,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
