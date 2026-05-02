import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key, required this.onCreateAccount});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes una cuenta? ',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFCEC2D9),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        GestureDetector(
          onTap: onCreateAccount,
          child: Text(
            'Crear cuenta',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFD7BAFF),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
