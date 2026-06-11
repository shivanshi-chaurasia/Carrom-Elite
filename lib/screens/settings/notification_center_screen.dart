import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  String _activeCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

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
          'NOTIFICATIONS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_rounded, color: AppColors.gold, size: 20),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read.')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(notificationsProvider.notifier).load(),
              color: AppColors.gold,
              backgroundColor: AppColors.surface,
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $err', style: AppTypography.body),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(notificationsProvider.notifier).load(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
                data: (notifications) {
                  final filtered = notifications.where((n) {
                    if (_activeCategory == 'All') return true;
                    return n.type.toLowerCase() == _activeCategory.toLowerCase();
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) {
                      final item = filtered[idx];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_rounded, color: AppColors.white),
                        ),
                        onDismissed: (_) {
                          ref.read(notificationsProvider.notifier).delete(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${item.title}" deleted')),
                          );
                        },
                        child: _notificationTile(item),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final categories = ['All', 'Match', 'System', 'Reward'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((cat) {
          final isSelected = _activeCategory == cat;
          return ChoiceChip(
            label: Text(
              cat == 'All' ? 'ALL' : '${cat.toUpperCase()}S',
              style: AppTypography.small.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : AppColors.textSoft,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.gold,
            backgroundColor: AppColors.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isSelected ? AppColors.gold : AppColors.line),
            ),
            onSelected: (val) {
              if (val) {
                setState(() => _activeCategory = cat);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _notificationTile(var item) {
    IconData icon;
    Color iconColor;

    switch (item.type.toLowerCase()) {
      case 'match':
        icon = Icons.sports_esports_rounded;
        iconColor = AppColors.teal;
        break;
      case 'reward':
        icon = Icons.emoji_events_rounded;
        iconColor = AppColors.gold;
        break;
      case 'system':
      default:
        icon = Icons.settings_rounded;
        iconColor = AppColors.purple;
        break;
    }

    return Card(
      color: item.isRead ? AppColors.surface.withOpacity(0.7) : AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: item.isRead ? AppColors.line.withOpacity(0.5) : AppColors.purple.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          if (!item.isRead) {
            ref.read(notificationsProvider.notifier).markAsRead(item.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: item.isRead ? AppColors.textMuted : AppColors.text,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: AppTypography.small.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(item.createdAt),
                      style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.line)),
            child: const Icon(Icons.notifications_off_rounded, color: AppColors.textSoft, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('No alerts found', style: AppTypography.h3),
          const SizedBox(height: 6),
          Text(
            'We will notify you here when you have updates.',
            style: AppTypography.body.copyWith(color: AppColors.textSoft),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
