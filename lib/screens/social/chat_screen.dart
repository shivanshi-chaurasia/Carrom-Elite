import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../models/social_models.dart';
import '../../providers/social_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.friendId});

  final String friendId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatState();
}

class _ChatState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    var text = _msgController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(widget.friendId, text);
    _msgController.clear();
    
    // scroll bottom after frame builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      // scroll again after mock delay
      Future.delayed(const Duration(milliseconds: 1600), _scrollToBottom);
    });
  }

  void _acceptChallenge(String roomCode) {
    // Show connecting loading dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.line),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            CircularProgressIndicator(color: AppColors.gold),
            SizedBox(height: 18),
            Text('Connecting to match socket...', style: AppTypography.body),
            SizedBox(height: 6),
            Text('joining room...', style: AppTypography.small),
          ],
        ),
      ),
    );

    // Join room after 1.5 seconds mock delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context); // close connecting dialog
        // Navigate directly to the carrom game flow with roomCode query!
        context.push('/carrom-lobby?roomCode=$roomCode');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final friends = ref.watch(friendsProvider);
    
    // Find friend details
    final friend = friends.firstWhere(
      (f) => f.id == widget.friendId,
      orElse: () => FriendModel(id: widget.friendId, name: 'Player', avatar: 'PL', status: 'offline', lastSeen: 'offline'),
    );

    final messages = chatState.chatLogs[widget.friendId] ?? ref.read(chatProvider.notifier).getMessagesFor(widget.friendId);

    return AppScaffold(
      showBottomNav: false,
      child: Column(
        children: [
          GamingAppBar(
            title: friend.name,
            subtitle: friend.status == 'online' ? 'Active Now' : (friend.status == 'playing' ? 'In Game' : 'Offline'),
            onBack: context.pop,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                return _buildMessageBubble(messages[i]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg) {
    bool isMe = msg.isMe;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.purple : AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                ),
                border: Border.all(color: isMe ? AppColors.purple : AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: AppTypography.body.copyWith(
                      color: isMe ? AppColors.white : AppColors.text,
                    ),
                  ),
                  if (msg.challengeRoomCode != null) ...[
                    const SizedBox(height: 12),
                    _buildChallengeInviteCard(msg.challengeRoomCode!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              msg.time,
              style: AppTypography.small.copyWith(fontSize: 10, color: AppColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeInviteCard(String roomCode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: AppColors.gold, size: 18),
              const SizedBox(width: 6),
              Text(
                'CARROM DUEL INVITE',
                style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Room code: $roomCode',
            style: AppTypography.small.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _acceptChallenge(roomCode),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.bg,
              minimumSize: const Size.fromHeight(36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'ACCEPT & JOIN LOBBY',
              style: AppTypography.small.copyWith(fontWeight: FontWeight.bold, color: AppColors.bg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: TextField(
                controller: _msgController,
                style: const TextStyle(color: AppColors.text),
                onSubmitted: (_) => _handleSend(),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppColors.textSoft),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _handleSend,
            icon: const Icon(Icons.send_rounded, color: AppColors.teal),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.card,
              padding: const EdgeInsets.all(12),
              shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
            ),
          ),
        ],
      ),
    );
  }
}
