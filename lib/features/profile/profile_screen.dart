import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final selectedThemeMode = ref.watch(appThemeModeProvider);
    final themeLabel = selectedThemeMode.label;
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          scrolledUnderElevation: 0,
          titleSpacing: 20,
          title: const Text('Profile'),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 8),
            _ProfileHeader(
              name: user?.displayName ?? 'Investor',
              email: user?.email ?? 'Not signed in',
            ),
            const SizedBox(height: 24),
            _SettingsGroup(
              title: 'Account',
              tiles: [
                _SettingsTileData(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () {},
                ),
                _SettingsTileData(
                  icon: Icons.verified_user_outlined,
                  label: 'KYC Status',
                  trailing: const _StatusBadge(label: 'Verified', isGreen: true),
                  onTap: () {},
                ),
                _SettingsTileData(
                  icon: Icons.account_balance_outlined,
                  label: 'Linked Bank',
                  onTap: () {},
                ),
                _SettingsTileData(
                  icon: Icons.history_rounded,
                  label: 'Transaction History',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Preferences',
              tiles: [
                _SettingsTileData(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {},
                ),
                _SettingsTileData(
                  icon: Icons.dark_mode_outlined,
                  label: 'App Theme',
                  trailing: Text(
                    themeLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: 'Inter',
                    ),
                  ),
                  onTap: () => _showThemeModeSheet(context, ref),
                ),
                _SettingsTileData(
                  icon: Icons.language_outlined,
                  label: 'Language',
                  trailing: Text(
                    'English',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: 'Inter',
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Support',
              tiles: [
                _SettingsTileData(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () {},
                ),
                _SettingsTileData(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                _SettingsTileData(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  onTap: () {},
                ),
                _SettingsTileData(
                  icon: Icons.star_outline_rounded,
                  label: 'Rate the App',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: '',
              tiles: [
                _SettingsTileData(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  textColor: AppColors.tertiary,
                  iconColor: AppColors.tertiary,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Ledger v1.0.0  ·  Build 1',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 100),
          ]),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
            },
            style:
                TextButton.styleFrom(foregroundColor: AppColors.tertiary),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showThemeModeSheet(BuildContext context, WidgetRef ref) {
    final selected = ref.read(appThemeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...AppThemeMode.values.map((mode) {
                final isSelected = mode == selected;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await ref.read(appThemeModeProvider.notifier).setMode(mode);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          mode.label,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'I';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                    color: colorScheme.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Plus Jakarta Sans',
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gainBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✓ KYC Verified',
                    style: TextStyle(
                      color: AppColors.gain,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                color: colorScheme.onSurfaceVariant, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ─── Settings Group ───────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsTileData> tiles;

  const _SettingsGroup({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: tiles.asMap().entries.map((e) {
                final i = e.key;
                final tile = e.value;
                return _SettingsTile(
                  data: tile,
                  isLast: i == tiles.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTileData {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsTileData({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
  });
}

class _SettingsTile extends StatelessWidget {
  final _SettingsTileData data;
  final bool isLast;

  const _SettingsTile({required this.data, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            data.onTap?.call();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  data.icon,
                  size: 20,
                  color: data.iconColor ?? colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    data.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: data.textColor ?? colorScheme.onSurface,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                if (data.trailing != null) ...[
                  data.trailing!,
                  const SizedBox(width: 6),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 50,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isGreen;

  const _StatusBadge({required this.label, required this.isGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            isGreen ? AppColors.gainBackground : AppColors.lossBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isGreen ? AppColors.gain : AppColors.loss,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}








