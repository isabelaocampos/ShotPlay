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
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF5F0F86)
              : const Color(0xFF2A1D35),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF5F0F86).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Center(
          child: isRolling
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  isMyTurn ? 'LANZAR EL DADO' : 'ESPERANDO TURNO...',
                  style: TextStyle(
                    color: enabled
                        ? Colors.white
                        : const Color(0xFF939393),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }
}
