import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class LinkedDevicesScreen extends StatefulWidget {
  const LinkedDevicesScreen({super.key});

  @override
  State<LinkedDevicesScreen> createState() => _LinkedDevicesScreenState();
}

class _LinkedDevicesScreenState extends State<LinkedDevicesScreen> {
  final List<Map<String, dynamic>> _sessions = [
    {
      'id': 'sess-01',
      'device': 'OnePlus 11 5G (This Device)',
      'os': 'Android 13.0',
      'location': 'Bengaluru, India',
      'time': 'Active Now',
      'isCurrent': true,
      'icon': Icons.phone_android_rounded,
    },
    {
      'id': 'sess-02',
      'device': 'Apple iPhone 15 Pro Max',
      'os': 'iOS 17.2',
      'location': 'Mumbai, India',
      'time': '10 June 2026, 08:34 PM',
      'isCurrent': false,
      'icon': Icons.phone_iphone_rounded,
    },
    {
      'id': 'sess-03',
      'device': 'Chrome Browser - Windows 11',
      'os': 'Web client',
      'location': 'Pune, India',
      'time': '04 June 2026, 11:20 AM',
      'isCurrent': false,
      'icon': Icons.desktop_windows_rounded,
    },
  ];

  void _revokeSession(int idx) {
    final session = _sessions[idx];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.line),
          ),
          title: Text(
            'REVOKE SESSION?',
            style: AppTypography.h3.copyWith(color: AppColors.white),
          ),
          content: Text(
            'This will log out the account on ${session['device']} immediately.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: AppTypography.body.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _sessions.removeAt(idx);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.red,
                    content: Text('Session on ${session['device']} revoked successfully.'),
                  ),
                );
              },
              child: Text(
                'REVOKE',
                style: AppTypography.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _revokeAllSessions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.red),
          ),
          title: Text(
            'REVOKE ALL OTHER SESSIONS?',
            style: AppTypography.h3.copyWith(color: AppColors.red),
          ),
          content: Text(
            'All sessions other than this current device will be signed out immediately.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: AppTypography.body.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _sessions.removeWhere((sess) => !sess['isCurrent']);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.red,
                    content: Text('All other active device sessions have been revoked.'),
                  ),
                );
              },
              child: Text(
                'REVOKE ALL',
                style: AppTypography.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
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
          'LINKED DEVICES',
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
            _buildInfoBanner(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVE LOGIN SESSIONS',
                  style: AppTypography.small.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                if (_sessions.length > 1)
                  TextButton(
                    onPressed: _revokeAllSessions,
                    child: Text(
                      'REVOKE ALL OTHER',
                      style: AppTypography.small.copyWith(
                        color: AppColors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSessionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_update_warning_rounded, color: AppColors.gold, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-Device Security',
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'If you notice any device you do not recognize, click Revoke immediately to secure your wallet balance.',
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

  Widget _buildSessionsList() {
    return Column(
      children: _sessions.asMap().entries.map((entry) {
        final idx = entry.key;
        final sess = entry.value;
        final isCurr = sess['isCurrent'] as bool;
        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCurr ? AppColors.purple.withOpacity(0.5) : AppColors.line,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCurr ? AppColors.purple.withOpacity(0.1) : AppColors.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    sess['icon'] as IconData,
                    color: isCurr ? AppColors.purple : AppColors.textSoft,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sess['device'] as String,
                              style: AppTypography.body.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurr)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CURRENT',
                                style: AppTypography.small.copyWith(
                                  color: AppColors.teal,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'OS: ${sess['os']} • Location: ${sess['location']}',
                        style: AppTypography.small.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last Active: ${sess['time']}',
                        style: AppTypography.small.copyWith(
                          color: isCurr ? AppColors.teal : AppColors.textSoft,
                          fontSize: 10,
                          fontWeight: isCurr ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCurr)
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.red, size: 20),
                    tooltip: 'Revoke Access',
                    onPressed: () => _revokeSession(idx),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
