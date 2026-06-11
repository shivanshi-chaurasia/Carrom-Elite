import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class VoiceChatPanel extends StatefulWidget {
  const VoiceChatPanel({super.key, required this.opponentName});

  final String opponentName;

  static void show(BuildContext context, {required String opponentName}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceChatPanel(opponentName: opponentName),
    );
  }

  @override
  State<VoiceChatPanel> createState() => _VoiceChatPanelState();
}

class _VoiceChatPanelState extends State<VoiceChatPanel> {
  bool _micEnabled = true;
  bool _opponentMicEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
          const SizedBox(height: 20),
          
          Text(
            'IN-GAME VOICE CHAT',
            style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 24),

          // Voice Avatars Status Area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // You
              Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.purple.withOpacity(0.2),
                        child: const Icon(Icons.person_rounded, color: AppColors.white, size: 28),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _micEnabled ? AppColors.green : AppColors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bg, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('You', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    _micEnabled ? 'Unmuted' : 'Muted',
                    style: AppTypography.small.copyWith(color: _micEnabled ? AppColors.green : AppColors.textSoft, fontSize: 10),
                  ),
                ],
              ),

              // Mic Control Toggle
              Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _micEnabled = !_micEnabled),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _micEnabled ? AppColors.purple : AppColors.surface2,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Icon(
                        _micEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                        color: _micEnabled ? AppColors.white : AppColors.textSoft,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _micEnabled ? 'TAP TO MUTE' : 'TAP TO UNMUTE',
                    style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                ],
              ),

              // Opponent
              Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.teal.withOpacity(0.2),
                        child: const Icon(Icons.person_rounded, color: AppColors.white, size: 28),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _opponentMicEnabled ? AppColors.green : AppColors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bg, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.opponentName, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    _opponentMicEnabled ? 'Speaking' : 'Muted',
                    style: AppTypography.small.copyWith(color: _opponentMicEnabled ? AppColors.green : AppColors.textSoft, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Audio info footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.teal, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ensure permissions are allowed. Avoid background noise for optimal match talk.',
                    style: AppTypography.small.copyWith(color: AppColors.textMuted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
