import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../models/social_models.dart';
import '../../providers/social_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends ConsumerState<CommunityFeedScreen> {
  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _handlePostSubmit() {
    var text = _postController.text.trim();
    if (text.isEmpty) return;

    ref.read(communityFeedProvider.notifier).addPost(text);
    _postController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post published successfully!'), backgroundColor: AppColors.teal),
    );
  }

  void _showCommentsSheet(FeedItemModel item) {
    final commentController = TextEditingController();
    // mock list of comments
    final comments = [
      CommentModel(id: 'c1', username: 'StrikerKing', text: 'Congrats on the awesome performance!', timeAgo: '1 hr ago'),
      CommentModel(id: 'c2', username: 'PocketPro', text: 'That is crazy! GG', timeAgo: '45m ago'),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Comments (${comments.length})', style: AppTypography.h3),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: AppColors.textSoft),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.line),
                  const SizedBox(height: 8),
                  if (comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No comments yet. Be the first!', style: TextStyle(color: AppColors.textSoft))),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        separatorBuilder: (c, idx) => const Divider(color: AppColors.line, height: 16),
                        itemBuilder: (c, idx) {
                          var comment = comments[idx];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.purple.withValues(alpha: 0.2),
                                child: Text(comment.username.substring(0, 1), style: const TextStyle(fontSize: 10, color: AppColors.white)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(comment.username, style: AppTypography.small.copyWith(color: AppColors.text, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 6),
                                        Text(comment.timeAgo, style: AppTypography.small.copyWith(fontSize: 10)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(comment.text, style: AppTypography.body.copyWith(color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const Divider(color: AppColors.line),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                              controller: commentController,
                              style: const TextStyle(color: AppColors.text),
                              decoration: const InputDecoration(
                                hintText: 'Write a comment...',
                                hintStyle: TextStyle(color: AppColors.textSoft),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            var text = commentController.text.trim();
                            if (text.isNotEmpty) {
                              setSheetState(() {
                                comments.add(
                                  CommentModel(
                                    id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                                    username: 'You',
                                    text: text,
                                    timeAgo: 'Just now',
                                  ),
                                );
                              });
                              commentController.clear();
                            }
                          },
                          icon: const Icon(Icons.send_rounded, color: AppColors.teal),
                          style: IconButton.styleFrom(backgroundColor: AppColors.card),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(communityFeedProvider);
    final notifier = ref.read(communityFeedProvider.notifier);

    return AppScaffold(
      showBottomNav: false,
      child: Column(
        children: [
          GamingAppBar(
            title: 'COMMUNITY FEED',
            subtitle: 'Player achievements & social',
            onBack: context.pop,
          ),
          _buildPostCreator(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemBuilder: (ctx, i) => _buildFeedCard(feed[i], notifier),
              separatorBuilder: (ctx, idx) => const SizedBox(height: 14),
              itemCount: feed.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCreator() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                hintText: 'Share a win or general strategy...',
                hintStyle: TextStyle(color: AppColors.textSoft),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _handlePostSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.text,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('POST', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(FeedItemModel item, CommunityFeedNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.purple.withValues(alpha: 0.15),
                child: Text(
                  item.playerAvatar,
                  style: AppTypography.small.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.playerName, style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(item.tag, style: AppTypography.small.copyWith(color: AppColors.purple, fontSize: 8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(item.time, style: AppTypography.small.copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.content, style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          const Divider(color: AppColors.line, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => notifier.likePost(item.id),
                    icon: Icon(
                      item.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: item.isLiked ? AppColors.red : AppColors.textSoft,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 6),
                  Text('${item.likesCount} Likes', style: AppTypography.small),
                ],
              ),
              GestureDetector(
                onTap: () => _showCommentsSheet(item),
                child: Row(
                  children: [
                    const Icon(Icons.comment_rounded, color: AppColors.textSoft, size: 20),
                    const SizedBox(width: 6),
                    Text('${item.commentsCount} Comments', style: AppTypography.small),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommentModel {
  final String id;
  final String username;
  final String text;
  final String timeAgo;

  CommentModel({required this.id, required this.username, required this.text, required this.timeAgo});
}
