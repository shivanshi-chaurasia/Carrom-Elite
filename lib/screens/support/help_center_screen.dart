import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  String _activeCategory = 'All';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faqsProvider);

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
          'HELP & SUPPORT',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          _buildActionCards(),
          _buildSearchField(),
          _buildFilterRow(),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => Center(child: Text('Error loading FAQs: $err', style: AppTypography.body)),
              data: (faqs) {
                final filtered = faqs.where((faq) {
                  final matchesCat = _activeCategory == 'All' || faq.category.toLowerCase() == _activeCategory.toLowerCase();
                  final matchesSearch = _searchQuery.isEmpty ||
                      faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
                  return matchesCat && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, idx) {
                    final item = filtered[idx];
                    return _faqAccordionTile(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: _actionCard(
              title: 'Live Chat',
              desc: 'Chat with agent 24/7',
              icon: Icons.chat_bubble_rounded,
              color: AppColors.teal,
              onTap: () => context.push('/live-chat'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionCard(
              title: 'Raise Ticket',
              desc: 'Submit support request',
              icon: Icons.assignment_rounded,
              color: AppColors.purple,
              onTap: () => context.push('/raise-ticket'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 2),
            Text(desc, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        controller: _searchCtrl,
        style: AppTypography.body.copyWith(color: AppColors.text),
        decoration: InputDecoration(
          hintText: 'Search FAQ, rules, payout issues...',
          hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSoft, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSoft, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
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
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildFilterRow() {
    final categories = ['All', 'Gameplay', 'Wallet', 'Security', 'Tournament'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((cat) {
            final isSelected = _activeCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  cat == 'All' ? 'ALL FAQs' : cat.toUpperCase(),
                  style: AppTypography.small.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : AppColors.textSoft,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.gold,
                backgroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isSelected ? AppColors.gold : AppColors.line),
                ),
                onSelected: (val) {
                  if (val) {
                    setState(() => _activeCategory = cat);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _faqAccordionTile(var faq) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.gold,
          collapsedIconColor: AppColors.textSoft,
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(6)),
            child: Icon(
              faq.category == 'Wallet'
                  ? Icons.account_balance_wallet_rounded
                  : faq.category == 'Gameplay'
                      ? Icons.gamepad_rounded
                      : Icons.info_rounded,
              color: AppColors.purple,
              size: 16,
            ),
          ),
          title: Text(
            faq.question,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq.answer,
                style: AppTypography.body.copyWith(color: AppColors.textMuted, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline_rounded, color: AppColors.textSoft, size: 44),
            const SizedBox(height: 12),
            const Text('No match found', style: AppTypography.h3),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search queries or category filters.',
              style: AppTypography.body.copyWith(color: AppColors.textSoft),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
