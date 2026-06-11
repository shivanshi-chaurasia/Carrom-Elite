import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/home_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class EventPopupScreen extends ConsumerWidget {
  const EventPopupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(title: 'Event popups', subtitle: 'Live notices and promos', onBack: context.pop),
          Expanded(
            child: state.when(
              loading: () => const Padding(padding: EdgeInsets.all(18), child: SkeletonLine(height: 220)),
              error: (err, stack) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.read(homeDashboardProvider.notifier).reload(),
              ),
              data: (data) => data.events.isEmpty
                  ? const AppEmptyView(subtitle: 'No events are active.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      itemBuilder: (ctx, i) {
                        final e = data.events[i];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.tag, style: AppTypography.small.copyWith(color: AppColors.teal)),
                              const SizedBox(height: 8),
                              Text(e.title, style: AppTypography.h2),
                              const SizedBox(height: 8),
                              Text(e.body, style: AppTypography.body),
                              const SizedBox(height: 14),
                              OutlinedButton(
                                onPressed: () {},
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                      itemCount: data.events.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
