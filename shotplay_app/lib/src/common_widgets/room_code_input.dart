import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/room_code_constants.dart';
import '../core/utils/upper_case_text_formatter.dart';

/// OTP-style room code input with integrated visuals and focus navigation.
class RoomCodeInput extends StatefulWidget {
  const RoomCodeInput({
    super.key,
    required this.enabled,
    this.onChanged,
    this.autofocus = false,
  });

  final bool enabled;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  State<RoomCodeInput> createState() => RoomCodeInputState();
}

class RoomCodeInputState extends State<RoomCodeInput> {
  static const int _length = RoomCodeConstants.length;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    debugPrint('[LIFECYCLE] Creating $_length FocusNodes');

    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (index) {
      final node = FocusNode(debugLabel: 'room_code_$index');
      node.addListener(_onFocusChanged);
      return node;
    });

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes.first.requestFocus();
      });
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    debugPrint('[LIFECYCLE] Disposing FocusNodes safely');
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.removeListener(_onFocusChanged);
      node.dispose();
    }
    super.dispose();
  }

  String get code => _controllers.map((c) => c.text).join();

  bool get isComplete => RoomCodeConstants.isValid(code);

  void _notifyChanged() {
    widget.onChanged?.call(code);
  }

  void _setDigit(int index, String value) {
    if (_controllers[index].text != value) {
      _controllers[index].text = value;
      _controllers[index].selection = TextSelection.collapsed(
        offset: value.length,
      );
    }
  }

  void _focusIndex(int index) {
    if (index < 0 || index >= _length) return;
    debugPrint('[FOCUS] Moving to index $index');
    _focusNodes[index].requestFocus();
  }

  void _handleInput(int index, String rawValue) {
    final cleaned = rawValue
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();

    if (cleaned.length > 1) {
      _distributeCode(cleaned);
      return;
    }

    final digit = cleaned.isNotEmpty ? cleaned[0] : '';
    _setDigit(index, digit);

    if (digit.isNotEmpty) {
      debugPrint('[ROOM_CODE] Digit entered at index $index');
      if (index < _length - 1) {
        _focusIndex(index + 1);
      }
    } else if (index > 0) {
      debugPrint('[FOCUS] Backspace -> index ${index - 1}');
      _focusIndex(index - 1);
    }

    _notifyChanged();
    setState(() {});
  }

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }

    // Only handle when this cell's TextField owns focus.
    if (!_focusNodes[index].hasFocus) {
      return KeyEventResult.ignored;
    }

    debugPrint('[ROOM_CODE] Backspace detected at index $index');

    if (_controllers[index].text.isNotEmpty) {
      // Let TextField clear the digit; onChanged will move focus backward.
      return KeyEventResult.ignored;
    }

    if (index > 0) {
      final previous = index - 1;
      debugPrint('[FOCUS] Backspace -> index $previous');
      _setDigit(previous, '');
      _focusIndex(previous);
      _notifyChanged();
      setState(() {});
      return KeyEventResult.handled;
    }

    return KeyEventResult.handled;
  }

  void _distributeCode(String rawCode) {
    final cleaned = rawCode
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();

    debugPrint('[ROOM_CODE] Pasting code (${cleaned.length} chars)');

    for (var i = 0; i < _length; i++) {
      _setDigit(i, i < cleaned.length ? cleaned[i] : '');
    }

    final lastFilled = (cleaned.length - 1).clamp(0, _length - 1);
    _focusIndex(lastFilled);
    _notifyChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_length, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < _length - 1 ? 10 : 0),
            child: _CodeCell(
              index: index,
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              isFocused: _focusNodes[index].hasFocus,
              onChanged: (value) => _handleInput(index, value),
              onKeyEvent: (event) => _handleKeyEvent(index, event),
            ),
          );
        }),
      ),
    );
  }
}

class _CodeCell extends StatelessWidget {
  const _CodeCell({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.isFocused,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool isFocused;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;

  Color _borderColor(bool hasValue) {
    if (isFocused) return const Color(0xFFA40EEA);
    if (hasValue) return const Color(0xFF7F0DF2);
    return const Color(0xFF334155);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;

    // Ancestor Focus intercepts key events from the focused TextField below.
    // The FocusNode is owned ONLY by TextField — never by this Focus wrapper.
    return Focus(
      onKeyEvent: (_, event) => onKeyEvent(event),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0x4C1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _borderColor(hasValue),
            width: 2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0x4C7F0DF2),
              blurRadius: isFocused ? 20 : 10,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          enableInteractiveSelection: false,
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            UpperCaseTextFormatter(),
          ],
          style: GoogleFonts.spaceGrotesk(
            color: hasValue ? const Color(0xFFA40EEA) : const Color(0xFF334155),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            filled: false,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            isCollapsed: true,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
