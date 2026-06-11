import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class EmojiChatPanel extends StatelessWidget {
  const EmojiChatPanel({super.key, required this.onEmojiSelected});

  final ValueChanged<String> onEmojiSelected;

  static void show(BuildContext context, {required ValueChanged<String> onEmojiSelected}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => EmojiChatPanel(onEmojiSelected: onEmojiSelected),
    );
  }

  final List<String> _emojis = const [
    '😂', '🔥', '👏', '😤',
    '🤝', '🏆', '😎', '💪',
    '🎯', '🙏', '😅', '👑'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.96),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'QUICK EMOJIS',
            style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 16),
          
          // Emojis Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _emojis.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (ctx, idx) {
              final emoji = _emojis[idx];
              return Card(
                color: AppColors.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.line),
                ),
                child: InkWell(
                  onTap: () {
                    onEmojiSelected(emoji);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
