import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class LiveChatScreen extends ConsumerStatefulWidget {
  const LiveChatScreen({super.key});

  @override
  ConsumerState<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends ConsumerState<LiveChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(liveChatProvider);
    final messages = chatState.messages;
    final showAgentTyping = chatState.isTyping;
    final notifier = ref.read(liveChatProvider.notifier);

    // Auto-scroll when new messages arrive
    ref.listen<ChatState>(liveChatProvider, (prev, next) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.purple,
                  child: Icon(Icons.headset_mic_rounded, color: AppColors.white, size: 18),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUPPORT AGENT',
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                Text(
                  'Online • Ready to Help',
                  style: AppTypography.small.copyWith(color: AppColors.green, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: messages.length,
                itemBuilder: (ctx, idx) {
                  final msg = messages[idx];
                  final isUser = msg.sender == 'user';
                  return _buildChatBubble(msg.text, isUser, msg.createdAt);
                },
              ),
            ),
            if (showAgentTyping) _buildTypingIndicator(),
            _buildInputRow(notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, DateTime time) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.purple : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: isUser ? null : Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: AppTypography.body.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                style: AppTypography.small.copyWith(
                  color: isUser ? AppColors.textMuted.withOpacity(0.8) : AppColors.textSoft,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.more_horiz_rounded, color: AppColors.gold, size: 16),
          const SizedBox(width: 6),
          Text(
            'Agent is typing...',
            style: AppTypography.small.copyWith(color: AppColors.textSoft, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(LiveChatNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: AppTypography.body.copyWith(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
                filled: true,
                fillColor: AppColors.bg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.purple),
                ),
              ),
              onSubmitted: (_) {
                if (_msgCtrl.text.trim().isNotEmpty) {
                  notifier.sendMessage(_msgCtrl.text);
                  _msgCtrl.clear();
                  _scrollToBottom();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.gold,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
              onPressed: () {
                if (_msgCtrl.text.trim().isNotEmpty) {
                  notifier.sendMessage(_msgCtrl.text);
                  _msgCtrl.clear();
                  _scrollToBottom();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
