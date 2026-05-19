import 'package:flutter/material.dart';

class RollDiceButton extends StatelessWidget {
  const RollDiceButton({
    super.key,
    required this.isMyTurn,
    required this.isRolling,
    required this.onRoll,
  });

  final bool isMyTurn;
  final bool isRolling;
  final VoidCallback onRoll;

  @override
  Widget build(BuildContext context) {
    final enabled = isMyTurn && !isRolling;

    return GestureDetector(
      onTap: enabled ? onRoll : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? [const Color(0xFFB5179E), const Color(0xFF5F0F86)]
                : [const Color(0xFF2A1D35), const Color(0xFF1D1524)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF07FCFE).withValues(alpha: enabled ? 0.35 : 0.15)),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFB5179E).withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 0.5,
                  ),
                ]
              : const [],
        ),
        child: Center(
          child: isRolling
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  isMyTurn ? 'ROLL THE DICE' : 'WAITING FOR TURN',
                  style: TextStyle(
                    color: enabled ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
        ),
      ),
    );
  }
}
