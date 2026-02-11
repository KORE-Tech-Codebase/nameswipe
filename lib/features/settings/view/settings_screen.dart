import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/core/routing/route_names.dart';
import 'package:nameswipe/features/settings/viewmodel/settings_viewmodel.dart';
import 'package:nameswipe/features/sync/viewmodel/sync_viewmodel.dart';
import 'package:nameswipe/providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(settingsViewModelProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsViewModelProvider);
    final isDarkMode = ref.watch(themeProvider);
    final syncState = ref.watch(syncViewModelProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),

          // APPEARANCE
          _SectionHeader('APPEARANCE'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Theme.of(context).colorScheme.primary),
            value: isDarkMode,
            onChanged: (_) => ref.read(settingsViewModelProvider.notifier).toggleTheme(),
          ),
          const Divider(),

          // DATA
          _SectionHeader('DATA'),
          ListTile(
            leading: Icon(Icons.storage_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Database Status'),
            subtitle: Text('${settings.totalNames} names available'),
            trailing: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          ),
          ListTile(
            leading: Icon(Icons.swipe_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Swipe History'),
            subtitle: Text('${settings.swipeCount} names swiped'),
          ),
          ListTile(
            leading: Icon(Icons.favorite_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Favorites'),
            subtitle: Text('${settings.favoritesCount} names saved'),
          ),
          ListTile(
            leading: Icon(Icons.cloud_sync_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Sync Status'),
            subtitle: Text(syncState.isSyncing ? 'Syncing...' : syncState.isComplete ? 'All data synced' : '${syncState.completedCategories}/${syncState.totalCategories} categories'),
            trailing: syncState.isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    icon: const Icon(Icons.sync_rounded),
                    onPressed: () => ref.read(syncViewModelProvider.notifier).startSync(),
                  ),
          ),
          const Divider(),

          // ACTIONS
          _SectionHeader('ACTIONS'),
          ListTile(
            leading: Icon(Icons.refresh_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Clear Swipe History'),
            subtitle: const Text('Start swiping from scratch'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _confirmClearHistory(context),
          ),
          const Divider(),

          // ABOUT
          _SectionHeader('ABOUT'),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RouteNames.privacyPolicy),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RouteNames.termsConditions),
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            title: const Text('About NameSwipe'),
            subtitle: const Text('Version 1.0.0'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Swipe History?'),
        content: const Text('This will let you re-swipe all names. Your favorites will be kept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsViewModelProvider.notifier).clearSwipeHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
      ),
    );
  }
}
