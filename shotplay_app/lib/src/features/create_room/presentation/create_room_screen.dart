import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/app_bottom_navigation_bar.dart';
import '../../../common_widgets/config_card.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../core/routing/app_routes.dart';
import '../../../domain/entities/game_option.dart';
import 'create_room_controller.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key, required this.selectedGame});

  final GameOption selectedGame;

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  late final TextEditingController _roomNameController;
  late final CreateRoomController _controller;

  @override
  void initState() {
    super.initState();
    _roomNameController = TextEditingController(text: 'Ej: Los Guerreros del Cubalibre');
    _controller = context.read<CreateRoomController>();
    _controller.addListener(_handleControllerUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _controller.initialize(widget.selectedGame);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    _roomNameController.dispose();
    super.dispose();
  }

  void _handleControllerUpdate() {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final errorMessage = _controller.errorMessage;
      if (errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
        _controller.clearErrorMessage();
      }

      final createdRoom = _controller.createdRoom;
      if (!_controller.isLoading && createdRoom != null) {
        _controller.clearCreatedRoom();
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.waitingRoom,
          arguments: createdRoom,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CreateRoomController>();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Configurar Partida'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF140B22), Color(0xFF09070F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ConfigHero(game: widget.selectedGame),
                const SizedBox(height: 18),
                _MaxPlayersSection(
                  maxPlayers: controller.maxPlayers,
                  minPlayers: controller.selectedGame.minPlayers,
                  maxAllowed: controller.selectedGame.maxPlayers,
                  onChanged: controller.updateMaxPlayers,
                ),
                const SizedBox(height: 14),
                Text(
                  'Configuración de Juego',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                _SwitchCard(
                  icon: Icons.flash_on_rounded,
                  title: 'Modo Rápido',
                  subtitle: 'Dados dobles para partidas más veloces.',
                  value: controller.isFastMode,
                  onChanged: controller.updateFastMode,
                ),
                const SizedBox(height: 12),
                _SwitchCard(
                  icon: Icons.lock_rounded,
                  title: 'Sala Privada',
                  subtitle: 'Solo usuarios con el código podrán entrar.',
                  value: controller.isPrivateRoom,
                  onChanged: controller.updatePrivateRoom,
                ),
                const SizedBox(height: 18),
                Text(
                  'NOMBRE DE LA SALA',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFB427F5),
                        letterSpacing: 1.1,
                      ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _roomNameController,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Los Guerreros del Cubalibre',
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Crear Sala',
                  isLoading: controller.isLoading,
                  onPressed: () {
                    controller.createRoom(roomName: _roomNameController.text);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Al crear la sala, te convertirás en el administrador de la partida.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onGamesTap: () {},
        onProfileTap: () {},
      ),
    );
  }
}

class _ConfigHero extends StatelessWidget {
  const _ConfigHero({required this.game});

  final GameOption game;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 224,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                game.heroImagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Colors.black.withOpacity(0.62),
                    Colors.black.withOpacity(0.42),
                    Colors.transparent,
                  ],
                  stops: const <double>[0.0, 0.68, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Text(
              game.badge,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFB427F5),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'JUEGO SELECCIONADO',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white54,
                        letterSpacing: 1.1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 0.95,
                      ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: Text(
                    game.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaxPlayersSection extends StatelessWidget {
  const _MaxPlayersSection({
    required this.maxPlayers,
    required this.minPlayers,
    required this.maxAllowed,
    required this.onChanged,
  });

  final int maxPlayers;
  final int minPlayers;
  final int maxAllowed;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrement = maxPlayers > minPlayers;
    final canIncrement = maxPlayers < maxAllowed;

    return ConfigCard(
      title: 'Número de jugadores',
      subtitle: 'Permitido: $minPlayers - $maxAllowed personas',
      child: Row(
        children: <Widget>[
          _StepperButton(
            icon: Icons.remove_rounded,
            enabled: canDecrement,
            onTap: () => onChanged(maxPlayers - 1),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$maxPlayers',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            enabled: canIncrement,
            onTap: () => onChanged(maxPlayers + 1),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF01FFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$maxAllowed Jugadores',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: const Color(0xFFB427F5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1227),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2A193E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFB427F5)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}