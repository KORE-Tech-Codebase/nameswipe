import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/features/swipe/view/swipe_screen.dart';
import 'package:namora/features/favorites/view/favorites_screen.dart';
import 'package:namora/features/search/view/search_screen.dart';
import 'package:namora/features/settings/view/settings_screen.dart';
import 'package:namora/features/search/viewmodel/search_viewmodel.dart';
import 'package:namora/widgets/floating_nav_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    SwipeScreen(),
    FavoritesScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  void _onTabChanged(int index) {
    // Reset search state when leaving search tab
    if (_currentIndex == 2 && index != 2) {
      ref.read(searchViewModelProvider.notifier).resetSearch();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
            ),
          ),
        ],
      ),
    );
  }
}
