import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
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
          'FREQUENTLY ASKED QUESTIONS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchField(),
            _buildFilterRow(),
            Expanded(
              child: state.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
                error: (err, stack) => Center(
                  child: Text('Error loading FAQs: $err', style: AppTypography.body),
                ),
                data: (faqs) {
                  final filtered = faqs.where((faq) {
                    final faqCat = faq.category.toLowerCase();
                    // Match category
                    bool matchesCat = _activeCategory == 'All';
                    if (!matchesCat) {
                      if (_activeCategory == 'Wallet') {
                        matchesCat = faqCat.contains('wallet') || faqCat.contains('withdraw');
                      } else if (_activeCategory == 'Security') {
                        matchesCat = faqCat.contains('security') || faqCat.contains('account');
                      } else {
                        matchesCat = faqCat == _activeCategory.toLowerCase();
                      }
                    }
                    // Match search query
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
            _buildSupportFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchCtrl,
        style: AppTypography.body.copyWith(color: AppColors.text),
        decoration: InputDecoration(
          hintText: 'Search FAQ topics, gameplay rules...',
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
    final categories = ['All', 'Gameplay', 'Wallet', 'Security', 'Tournaments'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 12),
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
              faq.category.toString().toLowerCase().contains('wallet')
                  ? Icons.account_balance_wallet_rounded
                  : faq.category.toString().toLowerCase().contains('gameplay')
                      ? Icons.gamepad_rounded
                      : faq.category.toString().toLowerCase().contains('security')
                          ? Icons.security_rounded
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
            const Text('No FAQs found', style: AppTypography.h3),
            const SizedBox(height: 4),
            Text(
              'Try typing different terms or resetting filters.',
              style: AppTypography.body.copyWith(color: AppColors.textSoft),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Still need assistance? We're available 24/7",
            style: AppTypography.small.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: Text(
                    'LIVE CHAT',
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context.push('/live-chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.assignment_rounded, size: 18),
                  label: Text(
                    'SUBMIT TICKET',
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context.push('/raise-ticket'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
