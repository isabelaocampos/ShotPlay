import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginSocialButton extends StatelessWidget {
  const LoginSocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      decoration: ShapeDecoration(
        color: const Color(0xFF2D2834),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFF4C4356),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: const Color(0xFFE9DFEF),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon!,
            if (icon != null) const SizedBox(width: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFE9DFEF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.27,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
