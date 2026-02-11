import 'package:flutter/material.dart';
import 'package:nameswipe/features/swipe/view/swipe_screen.dart';
import 'package:nameswipe/features/favorites/view/favorites_screen.dart';
import 'package:nameswipe/features/search/view/search_screen.dart';
import 'package:nameswipe/features/settings/view/settings_screen.dart';
import 'package:nameswipe/widgets/floating_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    SwipeScreen(),
    FavoritesScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
