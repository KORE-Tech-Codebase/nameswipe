import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/core/routing/route_names.dart';
import 'package:nameswipe/features/settings/viewmodel/settings_viewmodel.dart';
import 'package:nameswipe/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final isDarkMode = ref.watch(themeProvider);

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
            leading: Icon(Icons.favorite_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Favorites'),
            subtitle: Text('${settings.favoritesCount} names saved'),
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
