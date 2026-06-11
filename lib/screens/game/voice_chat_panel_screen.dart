import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/carrom_providers.dart';

class VoiceChatPanelScreen extends ConsumerWidget {
  const VoiceChatPanelScreen({super.key, required this.opponentName});

  final String opponentName;

  static void show(BuildContext context, {required String opponentName}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => VoiceChatPanelScreen(opponentName: opponentName),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceChatProvider);
    final notifier = ref.read(voiceChatProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.98),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: const Border(top: BorderSide(color: AppColors.line, width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VOICE ROOM',
                style: AppTypography.small.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.close_rounded, size: 14, color: AppColors.text),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.line, height: 28),

          // Player status list
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // You
              _buildPlayerVoiceNode(
                name: 'You',
                avatarInitials: 'SH',
                isSpeaking: voiceState.isSpeaking,
                isMuted: voiceState.isMuted,
              ),

              // Opponent
              _buildPlayerVoiceNode(
                name: opponentName,
                avatarInitials: opponentName.substring(0, 2).toUpperCase(),
                isSpeaking: !voiceState.isMuted && DateTime.now().millisecond % 3 == 0, // mock speaking
                isMuted: false,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Large push-to-talk button
          GestureDetector(
            onTapDown: (_) => notifier.setSpeaking(true),
            onTapUp: (_) => notifier.setSpeaking(false),
            onTapCancel: () => notifier.setSpeaking(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: voiceState.isMuted
                    ? AppColors.cardLight
                    : (voiceState.isSpeaking ? AppColors.teal : AppColors.purple),
                boxShadow: [
                  if (voiceState.isSpeaking && !voiceState.isMuted)
                    BoxShadow(
                      color: AppColors.teal.withOpacity(0.5),
                      blurRadius: 24,
                      spreadRadius: 4,
                    )
                  else if (!voiceState.isMuted)
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                ],
                border: Border.all(
                  color: voiceState.isSpeaking && !voiceState.isMuted
                      ? AppColors.white
                      : AppColors.line,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                voiceState.isMuted
                    ? Icons.mic_off_rounded
                    : (voiceState.isSpeaking ? Icons.record_voice_over_rounded : Icons.mic_rounded),
                color: voiceState.isMuted ? AppColors.textSoft : Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            voiceState.isMuted
                ? 'VOICE MUTED'
                : (voiceState.isSpeaking ? 'SPEAKING NOW...' : 'HOLD TO TALK'),
            style: AppTypography.small.copyWith(
              color: voiceState.isSpeaking ? AppColors.teal : AppColors.textSoft,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 28),

          // Toggles row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute toggle
              _buildBottomActionBtn(
                icon: voiceState.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                label: voiceState.isMuted ? 'Unmute' : 'Mute',
                active: !voiceState.isMuted,
                onTap: notifier.toggleMute,
              ),

              // Output toggle
              _buildBottomActionBtn(
                icon: voiceState.device == 'speaker' ? Icons.volume_up_rounded : Icons.headphones_rounded,
                label: voiceState.device == 'speaker' ? 'Speaker' : 'Headphones',
                active: voiceState.device == 'speaker',
                onTap: notifier.toggleDevice,
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPlayerVoiceNode({
    required String name,
    required String avatarInitials,
    required bool isSpeaking,
    required bool isMuted,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Green pulse rings
            if (isSpeaking && !isMuted) ...[
              _buildPulseCircle(56),
              _buildPulseCircle(48),
            ],
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.surface,
              child: Text(
                avatarInitials,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.gold),
              ),
            ),
            if (isMuted)
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: AppColors.red,
                  child: const Icon(Icons.mic_off_rounded, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPulseCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.teal.withOpacity(0.12),
        border: Border.all(color: AppColors.teal.withOpacity(0.3), width: 1.0),
      ),
    );
  }

  Widget _buildBottomActionBtn({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.purple : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.purple : AppColors.textSoft, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.bold,
                color: active ? AppColors.white : AppColors.textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
