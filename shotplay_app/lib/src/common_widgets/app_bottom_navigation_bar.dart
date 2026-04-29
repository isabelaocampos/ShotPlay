import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
    required this.onGamesTap,
    required this.onSocialTap,
    required this.onProfileTap,
  });

  final int currentIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onGamesTap;
  final VoidCallback onSocialTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          onHomeTap();
        } else if (index == 1) {
          onGamesTap();
        } else if (index == 2) {
          onSocialTap();
        } else if (index == 3) {
          onProfileTap();
        }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports_rounded),
          label: 'Juegos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_rounded),
          label: 'Social',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}