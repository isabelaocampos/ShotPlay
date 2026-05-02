import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_theme.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/entities/game.dart';
import '../cubits/configure_game_cubit.dart';

class ConfigureGameScreen extends StatelessWidget {
  final Game game;

  const ConfigureGameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConfigureGameCubit(
        GameRepositoryImpl(Supabase.instance.client),
        game,
      ),
      child: _ConfigureGameView(game: game),
    );
  }
}

class _ConfigureGameView extends StatefulWidget {
  final Game game;
  const _ConfigureGameView({required this.game});

  @override
  State<_ConfigureGameView> createState() => _ConfigureGameViewState();
}

class _ConfigureGameViewState extends State<_ConfigureGameView> {
  final _roomNameController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Configurar Partida',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocConsumer<ConfigureGameCubit, ConfigureGameState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.status == ConfigureGameStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ));
            context.read<ConfigureGameCubit>().clearError();
          }
          if (state.status == ConfigureGameStatus.created &&
              state.createdRoom != null) {
            context.pushReplacementNamed(
              'waitingRoom',
              pathParameters: {'roomId': state.createdRoom!.id},
              extra: state.createdRoom,
            );
          }
        },
        builder: (context, state) {
          final canDecrement = state.playerCount > widget.game.minPlayers;
          final canIncrement = state.playerCount < widget.game.maxPlayers;
          final isCreating = state.status == ConfigureGameStatus.creating;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SelectedGameBanner(game: widget.game),
                const SizedBox(height: 24),
                const _SectionTitle('Número de Jugadores'),
                const SizedBox(height: 12),
                _PlayerCountSelector(
                  count: state.playerCount,
                  maxLabel: widget.game.maxPlayers,
                  canDecrement: canDecrement,
                  canIncrement: canIncrement,
                  onDecrement: () =>
                      context.read<ConfigureGameCubit>().decrement(),
                  onIncrement: () =>
                      context.read<ConfigureGameCubit>().increment(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mín ${widget.game.minPlayers} • Máx ${widget.game.maxPlayers}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Configuración de Juego'),
                const SizedBox(height: 12),
                _ToggleRow(
                  icon: Icons.lightbulb_outline,
                  title: 'Pistas',
                  subtitle: 'Mostrar pistas durante la partida',
                  value: state.hintsEnabled,
                  onChanged: (_) =>
                      context.read<ConfigureGameCubit>().toggleHints(),
                ),
                const SizedBox(height: 10),
                _ToggleRow(
                  icon: Icons.lock_outline,
                  title: 'Sala Privada',
                  subtitle: 'Solo accesible con código',
                  value: state.isPrivate,
                  onChanged: (_) =>
                      context.read<ConfigureGameCubit>().togglePrivate(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'NOMBRE DE LA SALA',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _roomNameController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    hintText: 'Ej. Partida del viernes',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isCreating
                      ? null
                      : () => context
                          .read<ConfigureGameCubit>()
                          .createRoom(_roomNameController.text),
                  child: isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crear sala'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SelectedGameBanner extends StatelessWidget {
  final Game game;
  const _SelectedGameBanner({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primarySoft, width: 1.2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: game.imageUrl != null && game.imageUrl!.isNotEmpty
                  ? Image.network(
                      game.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradientFallback(),
                    )
                  : _gradientFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JUEGO SELECCIONADO',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${game.category.toUpperCase()} • ${game.playersLabel}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySoft, AppColors.primary],
        ),
      ),
      child: const Icon(Icons.casino_outlined, color: Colors.white70),
    );
  }
}

class _PlayerCountSelector extends StatelessWidget {
  final int count;
  final int maxLabel;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _PlayerCountSelector({
    required this.count,
    required this.maxLabel,
    required this.canDecrement,
    required this.canIncrement,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _RoundButton(
            icon: Icons.remove_rounded,
            enabled: canDecrement,
            onTap: onDecrement,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _RoundButton(
            icon: Icons.add_rounded,
            enabled: canIncrement,
            onTap: onIncrement,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.badge,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$maxLabel Jugadores',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
