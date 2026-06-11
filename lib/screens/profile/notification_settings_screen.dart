import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _push = true;
  bool _promo = false;
  bool _match = true;
  bool _reward = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.text),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.text),
            onPressed: () => context.push(AppRoutes.securitySettings),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: AppColors.gold, size: 24),
                      const SizedBox(width: 8),
                      const Text('Settings', style: AppTypography.h1),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _switchTile(
                    title: 'Push Notifications',
                    value: _push,
                    onChanged: (val) => setState(() => _push = val),
                  ),
                  const Divider(color: AppColors.line),
                  _switchTile(
                    title: 'Promotional Notifications',
                    value: _promo,
                    onChanged: (val) => setState(() => _promo = val),
                  ),
                  const Divider(color: AppColors.line),
                  _switchTile(
                    title: 'Match Alerts',
                    value: _match,
                    onChanged: (val) => setState(() => _match = val),
                  ),
                  const Divider(color: AppColors.line),
                  _switchTile(
                    title: 'Reward Alerts',
                    value: _reward,
                    onChanged: (val) => setState(() => _reward = val),
                  ),
                  const SizedBox(height: 28),
                  _gradientButton(
                    label: 'CONTINUE TO SECURITY',
                    onPressed: () => context.push(AppRoutes.securitySettings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.purple,
            inactiveThumbColor: AppColors.textSoft,
            inactiveTrackColor: AppColors.bg,
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({required String label, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
