import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isGoogleConnected = true;
  bool _isFacebookConnected = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = 'shiva.k@gmail.com';
    _phoneCtrl.text = '+91 9876543210';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _updateEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to new email to verify changes.')),
    );
  }

  void _updatePhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP verification code sent to new phone number.')),
    );
  }

  void _showDeleteAccountDialog() {
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.red),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.red),
              const SizedBox(width: 10),
              Text(
                'DELETE ACCOUNT',
                style: AppTypography.h3.copyWith(color: AppColors.red),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action is irreversible. All your wallet balance (winnings + deposits), coins, game logs, and achievements will be permanently deleted.',
                style: AppTypography.body.copyWith(color: AppColors.text, height: 1.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Type "DELETE" below to confirm:',
                style: AppTypography.small.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmCtrl,
                style: AppTypography.body.copyWith(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.red),
                  ),
                ),
              ),
            ],
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
                if (confirmCtrl.text.trim().toUpperCase() == 'DELETE') {
                  Navigator.pop(context);
                  // Direct to onboarding / log out
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.red,
                      content: Text('Account successfully queued for deletion.'),
                    ),
                  );
                  context.go('/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect confirmation text.')),
                  );
                }
              },
              child: Text(
                'DELETE PERMANENTLY',
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
          'ACCOUNT SETTINGS',
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
            _buildSectionHeader('VERIFIED CONTACT INFO'),
            const SizedBox(height: 10),
            _buildVerificationInputs(),
            const SizedBox(height: 24),
            _buildSectionHeader('LINKED SOCIAL ACCOUNTS'),
            const SizedBox(height: 10),
            _buildSocialAccounts(),
            const SizedBox(height: 24),
            _buildSectionHeader('SESSION & DEVICE MANAGEMENT'),
            const SizedBox(height: 10),
            _buildDeviceSection(),
            const SizedBox(height: 36),
            _buildDangerZone(),
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

  Widget _buildVerificationInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _verificationRow(
            label: 'EMAIL ADDRESS',
            controller: _emailCtrl,
            onUpdate: _updateEmail,
            isVerified: true,
          ),
          const Divider(color: AppColors.line, height: 24),
          _verificationRow(
            label: 'MOBILE NUMBER',
            controller: _phoneCtrl,
            onUpdate: _updatePhone,
            isVerified: true,
          ),
        ],
      ),
    );
  }

  Widget _verificationRow({
    required String label,
    required TextEditingController controller,
    required VoidCallback onUpdate,
    required bool isVerified,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold)),
            if (isVerified)
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppColors.teal, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'VERIFIED',
                    style: AppTypography.small.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.purple),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: onUpdate,
              child: Text(
                'UPDATE',
                style: AppTypography.body.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSocialAccounts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _socialRow(
            platform: 'Google Account',
            isConnected: _isGoogleConnected,
            icon: Icons.g_mobiledata_rounded,
            iconColor: AppColors.red,
            onAction: () {
              setState(() {
                _isGoogleConnected = !_isGoogleConnected;
              });
            },
          ),
          const Divider(color: AppColors.line, height: 24),
          _socialRow(
            platform: 'Facebook',
            isConnected: _isFacebookConnected,
            icon: Icons.facebook_rounded,
            iconColor: AppColors.blue,
            onAction: () {
              setState(() {
                _isFacebookConnected = !_isFacebookConnected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _socialRow({
    required String platform,
    required bool isConnected,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onAction,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                platform,
                style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
              ),
              Text(
                isConnected ? 'Connected' : 'Not Linked',
                style: AppTypography.small.copyWith(
                  color: isConnected ? AppColors.teal : AppColors.textSoft,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: isConnected ? AppColors.red : AppColors.gold,
            side: BorderSide(color: isConnected ? AppColors.red : AppColors.gold),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onAction,
          child: Text(
            isConnected ? 'DISCONNECT' : 'CONNECT',
            style: AppTypography.small.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.devices_rounded, color: AppColors.purple, size: 24),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Devices (2)',
                    style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Manage active session list',
                    style: AppTypography.small.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () => context.push('/linked-devices'),
            child: Row(
              children: [
                Text(
                  'MANAGE',
                  style: AppTypography.body.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.teal, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DANGER ZONE',
          style: AppTypography.small.copyWith(
            color: AppColors.red,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.red.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Close Account',
                style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Permanently close your account and flush all personal data from our servers.',
                style: AppTypography.small.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: _showDeleteAccountDialog,
                child: Text(
                  'DELETE ACCOUNT PERMANENTLY',
                  style: AppTypography.small.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
