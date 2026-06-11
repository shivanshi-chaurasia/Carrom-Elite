import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _profileLookupVisibility = true;
  bool _shareWinRate = true;
  bool _allowSpectators = true;
  bool _showMatchHistory = true;
  bool _shareVipStatus = false;

  void _showSavedSnackbar(String title, bool val) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.teal,
        duration: const Duration(seconds: 1),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.surface, size: 18),
            const SizedBox(width: 8),
            Text(
              '$title ${val ? "Enabled" : "Disabled"}',
              style: AppTypography.body.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'PRIVACY SETTINGS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildSectionHeader('PROFILE PRIVACY OPTIONS'),
            const SizedBox(height: 10),
            _buildPrivacySwitchList(),
            const SizedBox(height: 24),
            _buildDataSharingDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.small.copyWith(
        color: AppColors.teal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_rounded, color: AppColors.purple, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Control Your Privacy',
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set who can see your statistics, spectate your matches, or look up your profile during social challenges.',
                  style: AppTypography.small.copyWith(
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySwitchList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _privacySwitchRow(
            icon: Icons.person_search_rounded,
            title: 'Profile Discovery',
            subtitle: 'Allow other players to search you by username.',
            value: _profileLookupVisibility,
            onChanged: (val) {
              setState(() => _profileLookupVisibility = val);
              _showSavedSnackbar('Profile discovery', val);
            },
          ),
          const Divider(color: AppColors.line, height: 1),
          _privacySwitchRow(
            icon: Icons.analytics_rounded,
            title: 'Share Win-Rate',
            subtitle: 'Show your match win-rate stats on your public profile.',
            value: _shareWinRate,
            onChanged: (val) {
              setState(() => _shareWinRate = val);
              _showSavedSnackbar('Share win-rate', val);
            },
          ),
          const Divider(color: AppColors.line, height: 1),
          _privacySwitchRow(
            icon: Icons.visibility_rounded,
            title: 'Allow Spectators',
            subtitle: 'Let friends join and spectate your live cash battles.',
            value: _allowSpectators,
            onChanged: (val) {
              setState(() => _allowSpectators = val);
              _showSavedSnackbar('Spectator access', val);
            },
          ),
          const Divider(color: AppColors.line, height: 1),
          _privacySwitchRow(
            icon: Icons.history_edu_rounded,
            title: 'Match History Logs',
            subtitle: 'Make your past match results viewable to the community.',
            value: _showMatchHistory,
            onChanged: (val) {
              setState(() => _showMatchHistory = val);
              _showSavedSnackbar('Match history visibility', val);
            },
          ),
          const Divider(color: AppColors.line, height: 1),
          _privacySwitchRow(
            icon: Icons.stars_rounded,
            title: 'Show VIP Membership Status',
            subtitle: 'Display your current premium tier rank badge next to avatar.',
            value: _shareVipStatus,
            onChanged: (val) {
              setState(() => _shareVipStatus = val);
              _showSavedSnackbar('VIP badge visibility', val);
            },
          ),
        ],
      ),
    );
  }

  Widget _privacySwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.small.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.teal,
            activeTrackColor: AppColors.teal.withOpacity(0.3),
            inactiveThumbColor: AppColors.textSoft,
            inactiveTrackColor: AppColors.bg,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSharingDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security & Fair Play Note',
            style: AppTypography.small.copyWith(
              color: AppColors.textSoft,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Even when profile discovery is restricted, anti-fraud algorithms and match statistics remain shared with match lobby systems for matchmaking fair-play index ratings and anti-cheating logs verification.',
            style: AppTypography.small.copyWith(
              color: AppColors.textSoft,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
