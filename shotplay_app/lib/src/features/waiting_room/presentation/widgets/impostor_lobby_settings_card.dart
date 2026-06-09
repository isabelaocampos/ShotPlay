import 'package:flutter/material.dart';

import '../../../../core/routing/game_mode.dart';
import '../../../../core/ui/game_option_ui.dart';
import '../../../../domain/entities/game_option.dart';
import '../../../../domain/entities/lobby_settings.dart';
import '../../../../domain/lobby/lobby_settings_validator.dart';
import '../waiting_room_controller.dart';

class ImpostorLobbySettingsCard extends StatelessWidget {
  const ImpostorLobbySettingsCard({
    super.key,
    required this.controller,
    required this.isAdmin,
    required this.game,
  });

  final WaitingRoomController controller;
  final bool isAdmin;
  final GameOption game;

  @override
  Widget build(BuildContext context) {
    if (controller.gameMode != GameMode.impostor) {
      return const SizedBox.shrink();
    }

    final impostorCount = controller.lobbySettings.impostor.impostorCount;
    final maxCount = LobbySettingsValidator.maxImpostorCount(
      controller.players.length,
    );
    final accent = game.accentColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1228),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.groups_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Configuración del Impostor',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Número de impostores',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 10),
          if (isAdmin)
            _HostImpostorStepper(
              value: impostorCount,
              min: ImpostorLobbySettings.minImpostorCount,
              max: maxCount,
              accent: accent,
              enabled: controller.players.length >= 2,
              isUpdating: controller.isUpdatingSettings,
              onChanged: controller.updateImpostorCount,
            )
          else
            _ReadOnlyImpostorValue(
              value: impostorCount,
              accent: accent,
            ),
          if (controller.settingsError != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              controller.settingsError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.redAccent,
                  ),
            ),
          ],
          if (!isAdmin) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Solo el anfitrión puede cambiar la configuración.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HostImpostorStepper extends StatelessWidget {
  const _HostImpostorStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.accent,
    required this.enabled,
    required this.isUpdating,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final Color accent;
  final bool enabled;
  final bool isUpdating;
  final Future<bool> Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrease = enabled && !isUpdating && value > min;
    final canIncrease = enabled && !isUpdating && max >= min && value < max;

    return Row(
      children: <Widget>[
        _RoundIconButton(
          icon: Icons.remove_rounded,
          accent: accent,
          enabled: canDecrease,
          onPressed: canDecrease ? () => onChanged(value - 1) : null,
        ),
        Expanded(
          child: Center(
            child: isUpdating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                : Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
          ),
        ),
        _RoundIconButton(
          icon: Icons.add_rounded,
          accent: accent,
          enabled: canIncrease,
          onPressed: canIncrease ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _ReadOnlyImpostorValue extends StatelessWidget {
  const _ReadOnlyImpostorValue({
    required this.value,
    required this.accent,
  });

  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$value impostor${value == 1 ? '' : 'es'}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.accent,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final Color accent;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? accent.withValues(alpha: 0.18) : Colors.white10,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: enabled ? accent : Colors.white24,
          ),
        ),
      ),
    );
  }
}
