import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shotplay_app/src/features/enter_code/ui/bloc/enter_code_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bottom-sheet modal that lets a user enter a 4-character room code.
///
/// Receives [gameName] from the calling screen so the header title is dynamic
/// instead of hardcoded to a specific game.
class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key, required this.gameName});

  /// Name of the game the user selected (e.g. "Escaleras y Serpientes").
  final String gameName;

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  String get _fullCode => _controllers.map((c) => c.text).join();

  bool get _isComplete => _fullCode.length == 4;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<EnterCodeBloc>().add(EnterCodeLoadRequested(userId));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onKeyChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _joinRoom() {
    if (!_isComplete) return;
    // TODO: connect to waiting room with _fullCode
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Drag handle ─────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(99),
          ),
        ),

        // ── Game name header ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.gameName,
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFF1F5F9),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const Icon(Icons.ios_share, color: Color(0xFFF1F5F9), size: 20),
            ],
          ),
        ),

        const Divider(color: Color(0x197F0DF2), height: 16),

        // ── Content ─────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            children: [
              _buildTitleSection(),
              const SizedBox(height: 32),
              _buildCodeInputs(),
              const SizedBox(height: 32),
              _buildJoinButton(),
              const SizedBox(height: 24),
              _buildPlayerChip(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Unirse a una sala',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFF1F5F9),
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.65,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ingresa el código de 4 dígitos que te\ncompartió tu amigo',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final bool isFocused = _focusNodes[index].hasFocus;
        final bool hasValue = _controllers[index].text.isNotEmpty;

        return Padding(
          padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
          child: _buildSingleInput(index, isFocused, hasValue),
        );
      }),
    );
  }

  Widget _buildSingleInput(int index, bool isFocused, bool hasValue) {
    return Container(
      width: 64,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0x4C1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? const Color(0xFFA40EEA)
              : hasValue
                  ? const Color(0xFF7F0DF2)
                  : const Color(0xFF334155),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x4C7F0DF2),
            blurRadius: isFocused ? 20 : 10,
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          maxLength: 1,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(1),
          ],
          style: GoogleFonts.spaceGrotesk(
            color: hasValue ? const Color(0xFFA40EEA) : const Color(0xFF334155),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => _onKeyChanged(index, value),
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return GestureDetector(
      onTap: _isComplete ? _joinRoom : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _isComplete
              ? const Color(0xFFA40EEA)
              : const Color(0xFFA40EEA).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isComplete
              ? [
                  const BoxShadow(
                    color: Color(0x337F0DF2),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Unirse a la sala',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerChip() {
    return BlocBuilder<EnterCodeBloc, EnterCodeState>(
      builder: (context, state) {
        final String chipUsername =
            state is EnterCodeLoaded ? state.user.username : 'Usuario';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x661E293B),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: const Color(0x7F334155)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE967),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.person, color: Colors.black54, size: 16),
              ),
              const SizedBox(width: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Jugando como ',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFFE2E8F0),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: chipUsername,
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFFFF6B00),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.edit_outlined,
                  color: Color(0xFF64748B), size: 14),
            ],
          ),
        );
      },
    );
  }
}
