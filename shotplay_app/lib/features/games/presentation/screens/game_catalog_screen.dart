import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_theme.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/entities/game.dart';
import '../cubits/game_catalog_cubit.dart';
import '../widgets/game_card.dart';

class GameCatalogScreen extends StatelessWidget {
  const GameCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCatalogCubit(
        GameRepositoryImpl(Supabase.instance.client),
      )..loadGames(),
      child: const _GameCatalogView(),
    );
  }
}

class _GameCatalogView extends StatelessWidget {
  const _GameCatalogView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Juegos',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
            tooltip: 'Buscar',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<GameCatalogCubit, GameCatalogState>(
        builder: (context, state) {
          switch (state.status) {
            case GameCatalogStatus.initial:
            case GameCatalogStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case GameCatalogStatus.error:
              return _ErrorState(
                message: state.errorMessage ?? 'Error desconocido',
                onRetry: () => context.read<GameCatalogCubit>().loadGames(),
              );
            case GameCatalogStatus.loaded:
              return _GamesList(state: state);
          }
        },
      ),
      bottomNavigationBar: const _ShotPlayBottomNav(currentIndex: 1),
    );
  }
}

class _GamesList extends StatelessWidget {
  final GameCatalogState state;
  const _GamesList({required this.state});

  @override
  Widget build(BuildContext context) {
    final available = state.games.where((g) => g.isAvailable).toList();
    final comingSoon = state.games.where((g) => !g.isAvailable).toList();

    if (available.isEmpty && comingSoon.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<GameCatalogCubit>().loadGames(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const _SectionHeader(title: 'Destacados'),
          const SizedBox(height: 12),
          ...available.map((game) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GameCard(
                  game: game,
                  isSelected: state.selectedGame?.id == game.id,
                  onTap: () => _onGameTap(context, game),
                ),
              )),
          if (comingSoon.isNotEmpty) ...[
            const SizedBox(height: 8),
            const _SectionHeader(title: 'Muy pronto'),
            const SizedBox(height: 12),
            ...comingSoon.map((game) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GameCard(game: game, disabled: true),
                )),
          ],
        ],
      ),
    );
  }

  void _onGameTap(BuildContext context, Game game) {
    context.read<GameCatalogCubit>().selectGame(game);
    context.pushNamed('gameDetail', pathParameters: {'id': game.id}, extra: game);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aún no hay juegos disponibles. Vuelve más tarde.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
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

class _ShotPlayBottomNav extends StatelessWidget {
  final int currentIndex;
  const _ShotPlayBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Inicio'),
            BottomNavigationBarItem(
                icon: Icon(Icons.sports_esports_outlined), label: 'Juegos'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined), label: 'Social'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
