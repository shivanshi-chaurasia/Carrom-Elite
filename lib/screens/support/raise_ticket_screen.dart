import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class RaiseTicketScreen extends ConsumerStatefulWidget {
  const RaiseTicketScreen({super.key});

  @override
  ConsumerState<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends ConsumerState<RaiseTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'General Query';
  String? _mockScreenshotPath;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Query',
    'Wallet & Payments',
    'Game Bugs',
    'Account Issues',
    'Abuse/Fair Play Report',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);

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
          'SUBMIT TICKET',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
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
                const SizedBox(height: 28),
                _sectionHeader('YOUR ACTIVE TICKETS'),
                const SizedBox(height: 10),
                _buildTicketsList(ticketsState),
              ],
            ),
          ),
        ),
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

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Describe Your Issue',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          const SizedBox(height: 16),
          _buildDropdown(),
          const SizedBox(height: 16),
          _buildField(
            label: 'Subject',
            controller: _subjectCtrl,
            hint: 'e.g. Lost coins in carrom match',
            validator: (v) => v == null || v.isEmpty ? 'Subject is required' : null,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Detailed Description',
            controller: _descCtrl,
            hint: 'Tell us exactly what went wrong and when it occurred.',
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          _buildScreenshotUploader(),
          const SizedBox(height: 24),
          _gradientButton(),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATEGORY', style: AppTypography.small.copyWith(color: AppColors.textSoft)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
              style: AppTypography.body.copyWith(color: AppColors.text),
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.gold),
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
        Text(label.toUpperCase(), style: AppTypography.small.copyWith(color: AppColors.textSoft)),
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
    final attached = _mockScreenshotPath != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(
            attached ? Icons.check_circle_outline_rounded : Icons.add_photo_alternate_rounded,
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
                  _mockScreenshotPath = null;
                } else {
                  _mockScreenshotPath = '/mock/path/screenshot_2026.png';
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

  Widget _gradientButton() {
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
        onPressed: _isSubmitting
            ? null
            : () async {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() => _isSubmitting = true);
                  try {
                    await ref.read(ticketsProvider.notifier).raiseTicket(
                          subject: _subjectCtrl.text,
                          category: _selectedCategory,
                          description: _descCtrl.text,
                          screenshotPath: _mockScreenshotPath,
                        );

                    _subjectCtrl.clear();
                    _descCtrl.clear();
                    setState(() {
                      _mockScreenshotPath = null;
                      _selectedCategory = 'General Query';
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Support ticket raised successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Submission failed: $e')),
                      );
                    }
                  } finally {
                    setState(() => _isSubmitting = false);
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _isSubmitting ? 'SUBMITTING...' : 'SUBMIT SUPPORT TICKET',
          style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTicketsList(AsyncValue<List<dynamic>> state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (e, s) => Center(child: Text('Error loading tickets: $e', style: AppTypography.body)),
      data: (tickets) {
        if (tickets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No tickets raised yet.',
                style: AppTypography.body.copyWith(color: AppColors.textSoft),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tickets.length,
          itemBuilder: (ctx, idx) {
            final t = tickets[idx];
            return _ticketCard(t);
          },
        );
      },
    );
  }

  Widget _ticketCard(var t) {
    Color statusColor;
    String statusLabel = t.status.replaceAll('_', ' ').toUpperCase();

    switch (t.status.toLowerCase()) {
      case 'open':
        statusColor = AppColors.gold;
        break;
      case 'in_progress':
        statusColor = AppColors.blue;
        break;
      case 'resolved':
        statusColor = AppColors.green;
        break;
      default:
        statusColor = AppColors.textSoft;
    }

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.id,
                  style: AppTypography.body.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor, width: 0.8),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTypography.small.copyWith(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(t.subject, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 4),
            Text(t.description, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
            const Divider(color: AppColors.line, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.category, style: AppTypography.small.copyWith(color: AppColors.purple, fontWeight: FontWeight.bold)),
                Text(
                  '${t.createdAt.day}/${t.createdAt.month}/${t.createdAt.year}',
                  style: AppTypography.small.copyWith(color: AppColors.textSoft),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
