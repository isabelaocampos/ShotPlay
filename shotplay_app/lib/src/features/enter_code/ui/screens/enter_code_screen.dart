import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shotplay_app/src/core/constants/room_code_constants.dart';
import 'package:shotplay_app/src/core/routing/app_routes.dart';
import 'package:shotplay_app/src/core/utils/supabase_safe.dart';
import 'package:shotplay_app/src/domain/entities/room_entry_destination.dart';
import 'package:shotplay_app/src/core/utils/upper_case_text_formatter.dart';
import 'package:shotplay_app/src/features/enter_code/ui/bloc/enter_code_bloc.dart';

/// Bottom-sheet modal that lets a user enter a 6-character room code.
class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({
    super.key,
    required this.gameName,
    this.expectedGameId,
  });

  final String gameName;
  final int? expectedGameId;

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  static const int _codeLength = RoomCodeConstants.length;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  String get _fullCode => _controllers.map((c) => c.text).join();

  bool get _isComplete => RoomCodeConstants.isValid(_fullCode);

  @override
  void initState() {
    super.initState();
    final userId = safeCurrentUserId();
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

  /// Handles single-character input (typing) or multi-character input (paste).
  ///
  /// When the user pastes a full code, [value] will contain all characters;
  /// they are distributed across the individual controllers and focus is moved
  /// to the last filled slot (or the submit button equivalent).
  void _onCodeInput(int index, String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();

    if (cleaned.length > 1) {
      // Distribute pasted code starting from position 0.
      _distributeCode(cleaned);
      return;
    }

    // Single character typed: keep exactly one char in this controller.
    final single = cleaned.isNotEmpty ? cleaned[0] : '';
    if (_controllers[index].text != single) {
      _controllers[index].text = single;
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: single.length),
      );
    }

    if (single.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (single.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
  }

  /// Fills all code slots with [code], starting from the first slot.
  void _distributeCode(String code) {
    for (int i = 0; i < _codeLength; i++) {
      _controllers[i].text = i < code.length ? code[i] : '';
    }
    // Move focus to the last filled slot.
    final lastIndex = (code.length - 1).clamp(0, _codeLength - 1);
    _focusNodes[lastIndex].requestFocus();
    setState(() {});
  }

  void _joinRoom() {
    if (!_isComplete) return;

    context.read<EnterCodeBloc>().add(
          EnterCodeJoinRequested(
            roomCode: RoomCodeConstants.normalize(_fullCode),
            expectedGameId: widget.expectedGameId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnterCodeBloc, EnterCodeState>(
      listener: (context, state) {
        if (state is EnterCodeJoinSuccess) {
          final navigator = Navigator.of(context);
          final result = state.result;
          final currentUserId = safeCurrentUserId();
          final isAdmin = currentUserId != null &&
              currentUserId == result.room.adminId;

          navigator.pop();

          switch (result.destination) {
            case RoomEntryDestination.waitingRoom:
              navigator.pushNamed(
                AppRoutes.waitingRoom,
                arguments: result.room,
              );
            case RoomEntryDestination.gameBoard:
              debugPrint(
                '[NAVIGATION] Navigating to GameScreen '
                '(${result.room.roomCode})',
              );
              navigator.pushNamed(
                AppRoutes.gameBoard,
                arguments: <String, dynamic>{
                  'room': result.room,
                  'players': result.players,
                  'isAdmin': isAdmin,
                  'isReconnect': result.isReconnect,
                  'persistedGameState': result.persistedGameState,
                },
              );
            case RoomEntryDestination.roomFinished:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Esta partida ya finalizó.'),
                ),
              );
          }
        } else if (state is EnterCodeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<EnterCodeBloc, EnterCodeState>(
        builder: (context, state) {
          final joining = state is EnterCodeJoining;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
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
                    const Icon(Icons.ios_share,
                        color: Color(0xFFF1F5F9), size: 20),
                  ],
                ),
              ),
              const Divider(color: Color(0x197F0DF2), height: 16),
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
                    _buildCodeInputs(joining: joining),
                    const SizedBox(height: 32),
                    _buildJoinButton(joining: joining),
                    const SizedBox(height: 24),
                    _buildPlayerChip(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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
          'Ingresa el código de 6 caracteres que te\ncompartió tu amigo',
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

  Widget _buildCodeInputs({required bool joining}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_codeLength, (index) {
          final bool isFocused = _focusNodes[index].hasFocus;
          final bool hasValue = _controllers[index].text.isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(right: index < _codeLength - 1 ? 10 : 0),
            child: _buildSingleInput(index, isFocused, hasValue, joining: joining),
          );
        }),
      ),
    );
  }

  Widget _buildSingleInput(
    int index,
    bool isFocused,
    bool hasValue, {
    required bool joining,
  }) {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0x4C1E293B),
        borderRadius: BorderRadius.circular(14),
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
          // maxLength is intentionally omitted so that the OS does not
          // truncate pasted text before onChanged receives it.
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          enabled: !joining,
          inputFormatters: [
            // Allow raw input; sanitisation is handled in _onCodeInput.
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            UpperCaseTextFormatter(),
          ],
          style: GoogleFonts.spaceGrotesk(
            color: hasValue ? const Color(0xFFA40EEA) : const Color(0xFF334155),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => _onCodeInput(index, value),
        ),
      ),
    );
  }

  Widget _buildJoinButton({required bool joining}) {
    final enabled = _isComplete && !joining;

    return GestureDetector(
      onTap: enabled ? _joinRoom : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFA40EEA)
              : const Color(0xFFA40EEA).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? const [
                  BoxShadow(
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
            if (joining) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              joining ? 'Uniéndose...' : 'Unirse a la sala',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!joining) ...[
              const SizedBox(width: 8),
              const Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerChip() {
    return BlocBuilder<EnterCodeBloc, EnterCodeState>(
      builder: (context, state) {
        final String chipUsername = switch (state) {
          EnterCodeLoaded(:final user) => user.username,
          EnterCodeJoining(:final user) => user.username,
          _ => 'Usuario',
        };

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
