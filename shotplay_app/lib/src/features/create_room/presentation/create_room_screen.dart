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
  bool _initializedGame = false;

  @override
  void initState() {
    super.initState();
    _roomNameController = TextEditingController(text: 'Ej: Los Guerreros del Cubalibre');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedGame) {
      return;
    }

    context.read<CreateRoomController>().selectGame(widget.selectedGame);
    _initializedGame = true;
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CreateRoomController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final errorMessage = controller.errorMessage;
      if (errorMessage != null && mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
        controller.clearErrorMessage();
      }

      final createdRoom = controller.createdRoom;
      if (!controller.isLoading && createdRoom != null && mounted) {
        controller.clearCreatedRoom();
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.waitingRoom,
          arguments: createdRoom,
        );
      }
    });

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
        currentIndex: 1,
        onHomeTap: () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.gameDetails);
        },
        onGamesTap: () {},
        onSocialTap: () {},
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            game.accentColor.withOpacity(0.28),
            const Color(0xFF1C1230),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: 0,
            top: 0,
            child: Text(
              game.badge,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: game.accentColor,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                game.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaxPlayersSection extends StatelessWidget {
  const _MaxPlayersSection({required this.maxPlayers, required this.onChanged});

  final int maxPlayers;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConfigCard(
      title: 'Máximo de jugadores',
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Elige el límite',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF01FFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$maxPlayers jugadores',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List<int>.generate(9, (index) => index + 2)
                .map(
                  (value) => ChoiceChip(
                    label: Text('$value'),
                    selected: maxPlayers == value,
                    onSelected: (_) => onChanged(value),
                  ),
                )
                .toList(),
          ),
        ],
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