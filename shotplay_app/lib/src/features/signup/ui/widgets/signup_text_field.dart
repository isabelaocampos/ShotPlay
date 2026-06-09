import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupTextField extends StatelessWidget {
  const SignupTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
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
            filled: true,
            fillColor: const Color(0xFF1E1925),
            contentPadding: const EdgeInsets.only(
              top: 17,
              left: 20,
              right: 16,
              bottom: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x4C4C4356)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x4C4C4356)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7F0DF2)),
            ),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
