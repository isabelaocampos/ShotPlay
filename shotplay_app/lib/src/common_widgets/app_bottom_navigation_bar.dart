import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onGamesTap,
    required this.onProfileTap,
  });

  final int currentIndex;
  final VoidCallback onGamesTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          onGamesTap();
        } else if (index == 1) {
          onProfileTap();
        }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports_rounded),
          label: 'Juegos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}