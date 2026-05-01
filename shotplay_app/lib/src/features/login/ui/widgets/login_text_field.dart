import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.textInputType,
    this.suffix,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? textInputType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
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
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            color: const Color(0xFF1E1925),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFF4C4356),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: textInputType,
            obscureText: obscureText,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFE9DFEF),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.spaceGrotesk(
                color: const Color(0x7F978DA2),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.only(
                top: 17,
                left: 20,
                right: 16,
                bottom: 18,
              ),
              border: InputBorder.none,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
