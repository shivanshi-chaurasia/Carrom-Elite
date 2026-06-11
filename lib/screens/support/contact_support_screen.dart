import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  ConsumerState<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends ConsumerState<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Wallet & Payments';
  File? _mockScreenshotFile;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Wallet & Payments',
    'Game Bugs',
    'Account & Security',
    'Tournament Queries',
    'Fair Play & Abuse',
    'General Queries',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
          'CONTACT SUPPORT',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.gold),
            onPressed: () => context.push('/ticket-history'),
            tooltip: 'View Ticket History',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormSection(),
                const SizedBox(height: 24),
                _buildAlternateContactMethods(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RAISE A SUPPORT TICKET',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdown(),
          const SizedBox(height: 16),
          _buildField(
            label: 'Subject',
            controller: _subjectCtrl,
            hint: 'e.g., Transaction pending for 12 hours',
            validator: (v) => v == null || v.isEmpty ? 'Subject is required' : null,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Detailed Description',
            controller: _descCtrl,
            hint: 'Please describe the steps to reproduce or details of the issue...',
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          _buildScreenshotUploader(),
          const SizedBox(height: 24),
          _submitButton(),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ISSUE CATEGORY',
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: AppColors.surface,
              isExpanded: true,
              style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.gold, size: 24),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.body.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildScreenshotUploader() {
    final attached = _mockScreenshotFile != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(
            attached ? Icons.check_circle_outline_rounded : Icons.photo_camera_back_rounded,
            color: attached ? AppColors.green : AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              attached ? 'screenshot_attached.png' : 'Attach Screenshot (Optional)',
              style: AppTypography.body.copyWith(
                color: attached ? AppColors.text : AppColors.textSoft,
                fontWeight: attached ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (attached) {
                  _mockScreenshotFile = null;
                } else {
                  _mockScreenshotFile = File('/mock/path/screenshot_2026.png');
                }
              });
            },
            child: Text(
              attached ? 'REMOVE' : 'ATTACH',
              style: AppTypography.small.copyWith(
                color: attached ? AppColors.red : AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitTicket,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          _isSubmitting ? 'SUBMITTING...' : 'SUBMIT SUPPORT TICKET',
          style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _submitTicket() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(ticketsProvider.notifier).raiseTicket(
            subject: _subjectCtrl.text,
            category: _selectedCategory,
            description: _descCtrl.text,
            screenshot: _mockScreenshotFile,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.teal,
            content: Text(
              'Ticket submitted successfully!',
              style: AppTypography.body.copyWith(color: AppColors.surface, fontWeight: FontWeight.bold),
            ),
          ),
        );
        context.pushReplacement('/ticket-history');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit ticket: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildAlternateContactMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTHER CHANNELS',
          style: AppTypography.small.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              _contactChannelRow(
                icon: Icons.mail_outline_rounded,
                title: 'Email Support',
                value: 'support@carromelite.com',
                color: AppColors.blue,
              ),
              const Divider(color: AppColors.line, height: 24),
              _contactChannelRow(
                icon: Icons.chat_outlined,
                title: 'WhatsApp Official Chat',
                value: '+1 (800) 555-ELITE',
                color: AppColors.green,
              ),
              const Divider(color: AppColors.line, height: 24),
              _contactChannelRow(
                icon: Icons.headset_mic_outlined,
                title: 'Phone Helpline (9 AM - 6 PM)',
                value: '+91 1800 212 9999',
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactChannelRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.small.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.body.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.open_in_new_rounded, color: AppColors.textSoft, size: 16),
      ],
    );
  }
}
