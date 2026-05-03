import 'package:flutter/material.dart';
import 'package:shotplay_app/src/features/login/ui/widgets/login_divider.dart';
import 'package:shotplay_app/src/features/login/ui/widgets/login_social_button.dart';

class LoginSocialSection extends StatelessWidget {
  const LoginSocialSection({
    super.key,
    required this.onGoogle,
    required this.onDiscord,
  });

  final VoidCallback onGoogle;
  final VoidCallback onDiscord;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LoginDivider(label: 'O CONTINUAR CON'),
        const SizedBox(height: 16),
        LoginSocialButton(
          label: 'Google',
          onPressed: onGoogle,
          icon: const Icon(Icons.g_mobiledata, size: 20, color: Colors.white),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        const SizedBox(height: 12),
        LoginSocialButton(
          label: 'Discord',
          onPressed: onDiscord,
          icon: const Icon(Icons.gamepad, size: 20, color: Colors.white),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ],
    );
  }
}
