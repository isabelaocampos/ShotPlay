import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginDivider extends StatelessWidget {
  const LoginDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFF4C4356), thickness: 1, height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF978DA2),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.27,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFF4C4356), thickness: 1, height: 1),
        ),
      ],
    );
  }
}
