import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/home_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class QuickMatchEntryScreen extends ConsumerStatefulWidget {
  const QuickMatchEntryScreen({super.key});

  @override
  ConsumerState<QuickMatchEntryScreen> createState() => _QuickMatchEntryScreenState();
}

class _QuickMatchEntryScreenState extends ConsumerState<QuickMatchEntryScreen> {
  int selectedFee = 25;
  String mode = '1v1';

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(quickMatchProvider).isLoading;
    ref.listen(quickMatchProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
      if (prev?.isLoading == true && !next.isLoading && !next.hasError) {
        final m = mode.toLowerCase();
        if (m == '1v1') {
          context.push('/carrom-lobby?fee=$selectedFee');
        } else if (m == 'private') {
          context.push('/carrom-lobby?mode=private');
        } else if (m == 'practice') {
          context.push('/carrom-match?mode=bot');
        }
      }
    });

    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(title: 'Quick match entry', subtitle: 'Choose stake and mode', onBack: context.pop),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              children: [
                _modePicker(),
                const SizedBox(height: 18),
                Text('Entry fee', style: AppTypography.h3),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [10, 25, 50, 99].map((fee) => _feeChip(fee)).toList(),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    'Server will validate move sync, wallet deduction, and anti-cheat before match start.',
                    style: AppTypography.body,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: loading
                      ? null
                      : () => ref.read(quickMatchProvider.notifier).enter(entryFee: selectedFee, mode: mode),
                  icon: loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.flash_on_rounded),
                  label: Text(loading ? 'Finding player' : 'Start quick match'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.bg,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modePicker() {
    final modes = ['1v1', 'Private', 'Practice'];
    return Row(
      children: modes.map((m) {
        final active = m == mode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(m),
              selected: active,
              onSelected: (_) => setState(() => mode = m),
              selectedColor: AppColors.gold,
              labelStyle: AppTypography.small.copyWith(color: active ? AppColors.bg : AppColors.textMuted),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _feeChip(int fee) {
    final active = fee == selectedFee;
    return ChoiceChip(
      label: Text('₹$fee'),
      selected: active,
      onSelected: (_) => setState(() => selectedFee = fee),
      selectedColor: AppColors.teal,
      labelStyle: AppTypography.h3.copyWith(color: active ? AppColors.bg : AppColors.text),
    );
  }
}
