import 'package:flutter/material.dart';
import 'package:shotplay_app/src/features/signup/ui/widgets/signup_text_field.dart';

class SignupFormSection extends StatelessWidget {
  const SignupFormSection({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.birthdateController,
    required this.isPasswordObscured,
    required this.onTogglePassword,
    required this.onPickBirthdate,
    required this.usernameValidator,
    required this.emailValidator,
    required this.passwordValidator,
    required this.birthdateValidator,
  });

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController birthdateController;
  final bool isPasswordObscured;
  final VoidCallback onTogglePassword;
  final VoidCallback onPickBirthdate;
  final String? Function(String?) usernameValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;
  final String? Function(String?) birthdateValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignupTextField(
          label: 'USERNAME',
          hintText: 'GamerTag2024',
          controller: usernameController,
          validator: usernameValidator,
        ),
        const SizedBox(height: 20),
        SignupTextField(
          label: 'EMAIL',
          hintText: 'nombre@ejemplo.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: emailValidator,
        ),
        const SizedBox(height: 20),
        SignupTextField(
          label: 'PASSWORD',
          hintText: '••••••••',
          controller: passwordController,
          obscureText: isPasswordObscured,
          validator: passwordValidator,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              isPasswordObscured ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF978DA2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SignupTextField(
          label: 'FECHA DE NACIMIENTO',
          hintText: 'mm / dd / yyyy',
          controller: birthdateController,
          readOnly: true,
          onTap: onPickBirthdate,
          validator: birthdateValidator,
          suffix: const Icon(Icons.calendar_month, color: Color(0xFF978DA2)),
        ),
      ],
    );
  }
}
