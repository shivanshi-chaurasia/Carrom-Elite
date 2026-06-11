import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../models/social_models.dart';
import '../../providers/social_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class FriendsListScreen extends ConsumerStatefulWidget {
  const FriendsListScreen({super.key});

  @override
  ConsumerState<FriendsListScreen> createState() => _FriendsListState();
}

class _FriendsListState extends ConsumerState<FriendsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.line),
        ),
        title: const Text('Add Friend', style: AppTypography.h2),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter player username...',
            hintStyle: TextStyle(color: AppColors.textSoft),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.line)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.purple)),
          ),
          style: const TextStyle(color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSoft)),
          ),
          ElevatedButton(
            onPressed: () {
              var name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(friendsProvider.notifier).addFriend(name);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added friend $name!'), backgroundColor: AppColors.teal),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _showChallengeDialog(FriendModel friend) {
    int selectedFee = 25;
    final fees = [10, 25, 50, 100];

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.line),
            ),
            title: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('Challenge ${friend.name}', style: AppTypography.h2),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Challenge Entry Fee:', style: AppTypography.body),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: fees.map((fee) {
                    var isSelected = fee == selectedFee;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => selectedFee = fee),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.gold : AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSelected ? AppColors.gold : AppColors.line),
                          ),
                          child: Center(
                            child: Text(
                              '₹$fee',
                              style: AppTypography.small.copyWith(
                                color: isSelected ? AppColors.bg : AppColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Winning prize: ₹${(selectedFee * 1.8).toStringAsFixed(0)}',
                  style: AppTypography.small.copyWith(color: AppColors.teal),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL', style: TextStyle(color: AppColors.textSoft)),
              ),
              ElevatedButton(
                onPressed: () {
                  var code = 'ROOM${100 + Random().nextInt(899)}X';
                  
                  // Challenge friend in friends provider state
                  ref.read(friendsProvider.notifier).challengeFriend(friend.id, code);

                  // Send challenge message into the chat channel!
                  ref.read(chatProvider.notifier).sendMessage(
                        friend.id,
                        '⚔️ CHALLENGE: Sent custom table invite with entry ₹$selectedFee! Join room.',
                        challengeCode: code,
                      );

                  Navigator.pop(ctx);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Challenge sent to ${friend.name}!'),
                      backgroundColor: AppColors.teal,
                    ),
                  );

                  // Go to the chat screen
                  context.push('/chat/${friend.id}');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.bg),
                child: const Text('SEND CHALLENGE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);

    return AppScaffold(
      showBottomNav: false,
      child: Column(
        children: [
          GamingAppBar(
            title: 'FRIENDS & CHAT',
            subtitle: 'Compete and chat with friends',
            onBack: context.pop,
          ),
          _buildToolBar(),
          Expanded(
            child: friends.isEmpty
                ? const Center(child: Text('No friends found', style: TextStyle(color: AppColors.textSoft)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (ctx, i) => _buildFriendRow(friends[i]),
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                    itemCount: friends.length,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textSoft, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.text),
                      onChanged: (val) {
                        ref.read(friendsProvider.notifier).searchFriends(val);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search friends...',
                        hintStyle: TextStyle(color: AppColors.textSoft),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _showAddFriendDialog,
            icon: const Icon(Icons.person_add_rounded, color: AppColors.teal),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.line),
              ),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendRow(FriendModel friend) {
    Color statusCol;
    String statusLabel = friend.status;

    if (friend.status == 'online') {
      statusCol = AppColors.teal;
      statusLabel = 'Online';
    } else if (friend.status == 'playing') {
      statusCol = AppColors.purple;
      statusLabel = 'In Game';
    } else {
      statusCol = AppColors.textSoft;
      statusLabel = friend.lastSeen;
    }

    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      child: ListTile(
        onTap: () => context.push('/chat/${friend.id}'),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.purple.withValues(alpha: 0.2),
              child: Text(
                friend.avatar,
                style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusCol,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.card, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        title: Text(friend.name, style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold)),
        subtitle: Text(statusLabel, style: AppTypography.small),
        trailing: ElevatedButton.icon(
          onPressed: friend.status == 'offline' ? null : () => _showChallengeDialog(friend),
          icon: const Icon(Icons.flash_on_rounded, size: 14),
          label: const Text('DUEL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: friend.isChallenged ? AppColors.surface2 : AppColors.gold,
            foregroundColor: AppColors.bg,
            disabledBackgroundColor: AppColors.surface2,
            disabledForegroundColor: AppColors.textSoft,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }
}
