import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/auth_providers.dart';

class SettingsDashboardScreen extends ConsumerWidget {
  const SettingsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'SETTINGS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _sectionHeader('GAME PREFERENCES'),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Sound & Graphics Settings',
            subtitle: 'Adjust SFX, music volume and render quality',
            icon: Icons.sports_esports_rounded,
            onTap: () => context.push('/sound-graphics'),
          ),
          _menuTile(
            title: 'Notification Settings',
            subtitle: 'Toggle push alerts and match alarms',
            icon: Icons.notifications_active_rounded,
            onTap: () => context.push('/notif-settings'),
          ),
          const SizedBox(height: 20),
          _sectionHeader('ACCOUNT SECURITY'),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Two-Factor Authentication (2FA)',
            subtitle: 'Secure your cash balance and profile',
            icon: Icons.security_rounded,
            onTap: () => context.push('/two-factor-setup'),
          ),
          _menuTile(
            title: 'Change Account Password',
            subtitle: 'Update your login password',
            icon: Icons.lock_rounded,
            onTap: () => context.push('/security-settings'),
          ),
          const SizedBox(height: 20),
          _sectionHeader('SUPPORT & LEGAL'),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Help Center & FAQs',
            subtitle: 'Browse guides or open a support ticket',
            icon: Icons.help_center_rounded,
            onTap: () => context.push('/help-center'),
          ),
          _menuTile(
            title: 'Notification History',
            subtitle: 'View your alerts and system messages',
            icon: Icons.history_edu_rounded,
            onTap: () => context.push('/notification-center'),
          ),
          const SizedBox(height: 32),
          _logoutButton(context, ref),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Carrom Pro v1.4.2 (Production)',
              style: AppTypography.small.copyWith(color: AppColors.textSoft),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.small.copyWith(
        color: AppColors.teal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _menuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(icon, color: AppColors.purple, size: 20),
        ),
        title: Text(
          title,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.small.copyWith(color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSoft),
      ),
    );
  }

  Widget _logoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withOpacity(0.5)),
      ),
      child: TextButton.icon(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.line),
              ),
              title: const Text('Logout', style: AppTypography.h2),
              content: const Text(
                'Are you sure you want to log out of your account?',
                style: AppTypography.body,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('CANCEL', style: AppTypography.body.copyWith(color: AppColors.textSoft)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: Text('LOGOUT', style: AppTypography.body.copyWith(color: AppColors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded, color: AppColors.red, size: 18),
        label: Text(
          'LOG OUT ACCOUNT',
          style: AppTypography.button.copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
