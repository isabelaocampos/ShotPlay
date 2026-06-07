import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routing/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/supabase_safe.dart';
import '../../features/game_catalog/presentation/game_catalog_screen.dart';
import '../../features/profile/domain/repository/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/ui/bloc/profile_bloc.dart';
import '../../features/profile/ui/screens/profile_screen.dart';

/// Shell screen that owns the bottom navigation bar.
///
/// Each tab renders a different feature screen. The [ProfileBloc] is scoped
/// here so it stays alive for the lifetime of the shell rather than being
/// recreated on every tab switch.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !isSupabaseReady()) return;
      if (safeCurrentUserId() == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      }
    });
  }

  late final List<Widget> _screens = [
    const Center(
      child: Text(
        'Inicio',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    const GameCatalogScreen(),
    const Center(
      child: Text(
        'Social',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    BlocProvider(
      create: (ctx) => ProfileBloc(
        GetProfileUsecase(ctx.read<ProfileRepository>()),
      ),
      child: const ProfileScreen(),
    ),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Inicio'),
    _NavItem(icon: Icons.sports_esports_rounded, label: 'Juegos'),
    _NavItem(icon: Icons.people_alt_rounded, label: 'Social'),
    _NavItem(icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.primary.withOpacity(0.2), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items:
              _navItems
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
          selectedLabelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 10),
        ),
      ),
    );
  }
}

/// Data class for a single bottom navigation bar entry.
class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
