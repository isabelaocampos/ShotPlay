import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shotplay_app/src/features/login/ui/widgets/login_primary_button.dart';
import 'package:shotplay_app/src/features/login/ui/widgets/login_text_field.dart';

class LoginFormSection extends StatelessWidget {
  const LoginFormSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoginTextField(
          label: 'CORREO ELECTRONICO',
          hintText: 'nombre@ejemplo.com',
          controller: emailController,
          textInputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        LoginTextField(
          label: 'CONTRASENA',
          hintText: '••••••••',
          controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: onForgotPassword,
            child: Text(
              '¿Olvidaste tu contrasena?',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFD7BAFF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.27,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        LoginPrimaryButton(
          label: 'INICIAR SESION',
          onPressed: onSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
