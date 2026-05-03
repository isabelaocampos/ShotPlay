import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
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
    // Use Future.microtask so the first notifyListeners() inside loadGames()
    // fires after the full build pipeline has completed, avoiding the
    // "setState called during build" error.
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
        title: const Text('Juegos'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
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

  @override
  Widget build(BuildContext context) {
    final games = controller.games;
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
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1227),
          borderRadius: BorderRadius.circular(24),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    game.accentColor.withOpacity(0.55),
                    game.secondaryColor.withOpacity(0.45),
                  ],
                ),
              ),
              child: Icon(game.icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: game.accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          game.badge,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: game.accentColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${game.subtitle.toUpperCase()} • ${game.minPlayers}-${game.maxPlayers} JUGADORES',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white60,
                          letterSpacing: 0.4,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: isSelected ? game.accentColor : Colors.white54,
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
