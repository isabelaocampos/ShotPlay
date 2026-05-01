import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shotplay_app/src/features/signup/ui/widgets/signup_primary_button.dart';

class SignupFooter extends StatelessWidget {
  const SignupFooter({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onLoginTap,
  });

  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignupPrimaryButton(
          label: 'Crear cuenta',
          onPressed: onSubmit,
          isLoading: isLoading,
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onLoginTap,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '¿Ya tienes cuenta? ',
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFCEC2D9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
                TextSpan(
                  text: 'Inicia sesion',
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFBB8AFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
