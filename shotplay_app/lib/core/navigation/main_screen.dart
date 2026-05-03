import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../screens/sala_espera_screen.dart';
import '../theme/app_theme.dart';

/// Shell screen that owns the bottom navigation bar.
///
/// Each tab renders a different feature screen. The "Juegos" tab
/// shows the SalaEsperaScreen.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // "Juegos" active by default

  late final List<Widget> _screens = [
    const Center(
      child: Text(
        'Inicio',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    const SalaEsperaScreen(),
    const Center(
      child: Text(
        'Social',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        'Perfil',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
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
            top: BorderSide(
              color: AppTheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: _navItems
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
