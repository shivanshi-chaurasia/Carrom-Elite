import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/carrom_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class CarromLobbyScreen extends ConsumerStatefulWidget {
  const CarromLobbyScreen({super.key, this.fee, this.mode});

  final String? fee;
  final String? mode;

  @override
  ConsumerState<CarromLobbyScreen> createState() => _CarromLobbyState();
}

class _CarromLobbyState extends ConsumerState<CarromLobbyScreen> {
  final TextEditingController joinCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fee != null) {
        var entryFee = num.tryParse(widget.fee!) ?? 25;
        ref.read(matchmakerProvider.notifier).findMatch(entryFee);
      }
    });
  }

  @override
  void dispose() {
    joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // listener to redirect when a match is found
    ref.listen<MatchmakerState>(matchmakerProvider, (prev, next) {
      if (next.match != null) {
        context.go('/carrom-match?mode=1v1&matchId=${next.match!.id}');
      }
    });

    ref.listen<PrivateRoomState>(privateRoomProvider, (prev, next) {
      if (next.room != null && next.room!.opponentJoined) {
        context.go('/carrom-match?mode=private&roomCode=${next.room!.code}');
      }
    });

    var isPrivate = widget.mode == 'private';

    return AppScaffold(
      showBottomNav: false,
      child: Column(
        children: [
          GamingAppBar(
            title: isPrivate ? 'CUSTOM ROOM' : 'MATCHMAKING',
            subtitle: isPrivate ? 'Invite your friends' : 'Searching for challenger',
            onBack: () {
              ref.read(matchmakerProvider.notifier).reset();
              ref.read(privateRoomProvider.notifier).reset();
              context.pop();
            },
          ),
          Expanded(
            child: isPrivate ? _buildPrivateUI() : _buildMatchmakingUI(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchmakingUI() {
    final state = ref.watch(matchmakerProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: AppColors.gold,
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: AppColors.gold,
                    size: 42,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 38),
            const Text(
              'FINDING A MATCH...',
              style: AppTypography.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Entry Fee: ₹${widget.fee ?? '25'}',
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            if (state.error != null)
              Text(
                state.error!,
                style: AppTypography.small.copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateUI() {
    final state = ref.watch(privateRoomProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (state.room == null) ...[
          // Option to Create or Join
          _buildActionButton(
            label: 'CREATE CUSTOM TABLE',
            desc: 'Host a table and get unique join code',
            icon: Icons.add_box_rounded,
            color: AppColors.gold,
            onPressed: () => ref.read(privateRoomProvider.notifier).create(),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.line),
          const SizedBox(height: 24),
          const Text('JOIN EXISTING ROOM', style: AppTypography.h3),
          const SizedBox(height: 12),
          TextField(
            controller: joinCodeController,
            keyboardType: TextInputType.number,
            style: AppTypography.h3,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Enter 6-Digit Code',
              hintStyle: AppTypography.h3.copyWith(color: AppColors.textSoft),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.gold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              var code = joinCodeController.text.trim();
              if (code.length == 6) {
                ref.read(privateRoomProvider.notifier).join(code);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: AppColors.bg,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'JOIN ROOM',
              style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ] else ...[
          // Waiting screen for host or joining client
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text('ROOM CODE', style: AppTypography.small),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    state.room!.code,
                    style: AppTypography.h1.copyWith(
                      fontSize: 36,
                      letterSpacing: 4,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                const CircularProgressIndicator(color: AppColors.teal),
                const SizedBox(height: 24),
                Text(
                  state.room!.isHost
                      ? 'Waiting for opponent to connect...'
                      : 'Connecting to room hosts...',
                  style: AppTypography.body.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 48),
                
                // DEMO ONLY: trigger mock join for host screen
                if (state.room!.isHost)
                  TextButton(
                    onPressed: () {
                      context.go('/carrom-match?mode=private&roomCode=${state.room!.code}');
                    },
                    child: Text(
                      'Simulate player joined (demo)',
                      style: AppTypography.small.copyWith(color: AppColors.teal),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.h3.copyWith(color: color)),
                  const SizedBox(height: 4),
                  Text(desc, style: AppTypography.small.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSoft, size: 16),
          ],
        ),
      ),
    );
  }
}
