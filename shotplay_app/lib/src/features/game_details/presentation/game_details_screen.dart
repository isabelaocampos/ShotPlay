import 'package:flutter/material.dart';

import '../../../common_widgets/app_bottom_navigation_bar.dart';
import '../../../core/routing/app_routes.dart';
import '../../../domain/entities/game_option.dart';

class GameDetailsScreen extends StatefulWidget {
  const GameDetailsScreen({super.key, this.initialGame});

  final GameOption? initialGame;

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late GameOption _selectedGame;

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.initialGame ?? defaultGameOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Navigator.of(context).canPop()
              ? () => Navigator.of(context).pop()
              : null,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Detalles del Juego'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF140B22), Color(0xFF0B0810)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _GameHero(game: _selectedGame),
                const SizedBox(height: 14),
                Text(
                  _selectedGame.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedGame.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _StatsCard(
                        label: 'JUGADORES',
                        value: _selectedGame.playersLabel,
                        icon: Icons.people_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatsCard(
                        label: 'DURACIÓN',
                        value: _selectedGame.durationLabel,
                        icon: Icons.schedule_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Juegos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final game = defaultGameOptions[index];
                      final isSelected = game.id == _selectedGame.id;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedGame = game),
                        child: Container(
                          width: 168,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? game.accentColor.withOpacity(0.18)
                                : const Color(0xFF1A1227),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected
                                  ? game.accentColor
                                  : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(game.icon, color: game.accentColor),
                              const Spacer(),
                              Text(
                                game.title,
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                game.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: defaultGameOptions.length,
                  ),
                ),
                const SizedBox(height: 18),
                _ActionTile(
                  label: 'Crear sala',
                  icon: Icons.add_circle_outline_rounded,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.configureRoom,
                      arguments: _selectedGame,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionTile(
                  label: 'Unirse a sala',
                  icon: Icons.login_rounded,
                  isSecondary: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unirse a sala todavía no está conectado.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1,
        onHomeTap: () {},
        onGamesTap: () {},
        onSocialTap: () {},
        onProfileTap: () {},
      ),
    );
  }
}

class _GameHero extends StatelessWidget {
  const _GameHero({required this.game});

  final GameOption game;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            game.accentColor.withOpacity(0.32),
            game.secondaryColor.withOpacity(0.2),
            const Color(0xFF241333),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -24,
            top: 18,
            child: _DecorativeChip(color: game.accentColor),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: _DecorativeChip(color: game.secondaryColor, large: true),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            top: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    game.badge,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: game.secondaryColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  'JUEGO SELECCIONADO',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
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
                const SizedBox(height: 6),
                Text(
                  game.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
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

class _DecorativeChip extends StatelessWidget {
  const _DecorativeChip({required this.color, this.large = false});

  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: large ? 156 : 116,
      height: large ? 156 : 116,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        border: Border.all(color: color.withOpacity(0.35), width: 10),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1228),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 20),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSecondary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSecondary ? const Color(0xFF1A1227) : const Color(0xFFB427F5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSecondary ? Colors.white.withOpacity(0.08) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
