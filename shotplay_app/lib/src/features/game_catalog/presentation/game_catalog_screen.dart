import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/resources/app_images.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/ui/game_option_ui.dart';
import '../../../domain/entities/game_option.dart';
import 'game_catalog_controller.dart';

class GameCatalogScreen extends StatefulWidget {
  const GameCatalogScreen({super.key});

  @override
  State<GameCatalogScreen> createState() => _GameCatalogScreenState();
}

class _GameCatalogScreenState extends State<GameCatalogScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<GameCatalogController>().loadGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameCatalogController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(AppImages.welcomeBg, width: 28, height: 28),
            const SizedBox(width: 10),
            const Text('ShotPlay'),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
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
          child: _buildBody(context, controller),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GameCatalogController controller) {
    switch (controller.status) {
      case GameCatalogStatus.initial:
      case GameCatalogStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case GameCatalogStatus.error:
        return _ErrorState(
          message: controller.errorMessage ?? 'Error desconocido',
          onRetry: controller.loadGames,
        );
      case GameCatalogStatus.loaded:
        return _CatalogList(controller: controller);
    }
  }
}

class _CatalogList extends StatelessWidget {
  const _CatalogList({required this.controller});

  final GameCatalogController controller;

  static const Set<String> _visibleGameIds = <String>{
    'snakes_ladders',
    'impostor',
  };

  @override
  Widget build(BuildContext context) {
    final games = controller.games
        .where((game) => _visibleGameIds.contains(game.id))
        .toList(growable: false);

    if (games.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aún no hay juegos disponibles. Vuelve más tarde.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadGames,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          Text(
            'Juegos populares',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Elige uno de los modos disponibles y crea tu sala.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: games.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, index) {
              final game = games[index];
              final isSelected = controller.selectedGame?.id == game.id;
              return _GameCard(
                game: game,
                isSelected: isSelected,
                onTap: () {
                  controller.selectGame(game);
                  Navigator.of(context).pushNamed(
                    AppRoutes.gameDetails,
                    arguments: game,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.isSelected,
    required this.onTap,
  });

  final GameOption game;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1227),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected ? game.accentColor : Colors.white.withOpacity(0.06),
            width: isSelected ? 2 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    game.accentColor.withOpacity(0.18),
                    const Color(0xFF1A1227),
                  ],
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 136,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(game.heroImagePath, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.62),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: game.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        game.badge,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          game.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          game.subtitle,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white70,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${game.minPlayers}-${game.maxPlayers} jugadores',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white60,
                          letterSpacing: 0.4,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.durationLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white60,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.white54),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
