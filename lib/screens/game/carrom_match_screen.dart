import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../game/carrom_game.dart';
import '../../widgets/common/app_scaffold.dart';
import 'voice_chat_panel_screen.dart';
import '../../providers/service_providers.dart';

class CarromMatchScreen extends ConsumerStatefulWidget {
  const CarromMatchScreen({super.key, this.mode, this.matchId, this.roomCode});

  final String? mode;
  final String? matchId;
  final String? roomCode;

  @override
  ConsumerState<CarromMatchScreen> createState() => _CarromMatchState();
}

class _CarromMatchState extends ConsumerState<CarromMatchScreen> with TickerProviderStateMixin {
  late CarromGame game;
  
  // HUD states
  int p1Score = 0;
  int p2Score = 0;
  String activeTurn = 'player1';
  double strikerSliderVal = 0.5;

  // Emoji popups
  String? p1Emoji;
  String? p2Emoji;
  Timer? p1EmojiTimer;
  Timer? p2EmojiTimer;

  // Emoji overlay & animation states
  bool _showEmojiOverlay = false;
  Timer? _emojiOverlayTimer;
  final List<FloatingEmoji> _floatingEmojis = [];

  // Turn timer
  int secondsLeft = 15;
  Timer? turnTimer;

  @override
  void initState() {
    super.initState();
    _initGame();
    _startTurnTimer();
  }

  void _initGame() {
    game = CarromGame(
      mode: widget.mode ?? 'bot',
      onScoreChanged: (s1, s2) {
        setState(() {
          p1Score = s1;
          p2Score = s2;
        });
      },
      onTurnChanged: (turn) {
        setState(() {
          activeTurn = turn;
          secondsLeft = 15; // reset countdown
        });
        
        // bots can simulate emoji reactions
        if (turn == 'player2' && widget.mode == 'bot') {
          _triggerBotEmoji();
        }
      },
      onGameOver: (winner) {
        turnTimer?.cancel();
        context.go('/carrom-result?winner=$winner&mode=${widget.mode ?? 'bot'}');
      },
    );
  }

  void _startTurnTimer() {
    turnTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft > 0) {
        setState(() => secondsLeft--);
      } else {
        // force turn skip
        game.activeTurn = game.activeTurn == 'player1' ? 'player2' : 'player1';
        game.onTurnChanged(game.activeTurn);
      }
    });
  }

  void _showEmoji(String emoji, bool isPlayer1) {
    setState(() {
      if (isPlayer1) {
        p1Emoji = emoji;
        p1EmojiTimer?.cancel();
        p1EmojiTimer = Timer(const Duration(seconds: 2), () {
          setState(() => p1Emoji = null);
        });
      } else {
        p2Emoji = emoji;
        p2EmojiTimer?.cancel();
        p2EmojiTimer = Timer(const Duration(seconds: 2), () {
          setState(() => p2Emoji = null);
        });
      }
    });
    _addFloatingEmoji(emoji, isPlayer1);
  }

  void _addFloatingEmoji(String emoji, bool isPlayer1) {
    if (!mounted) return;
    final random = Random();
    final double startX = isPlayer1 
        ? 50.0 + random.nextDouble() * 100 
        : MediaQuery.of(context).size.width - 150 - random.nextDouble() * 100;
    final double startY = isPlayer1 
        ? MediaQuery.of(context).size.height - 180 
        : 180.0;
    
    final double endX = startX + (random.nextDouble() - 0.5) * 80.0;
    final double endY = isPlayer1 
        ? startY - 250.0 - random.nextDouble() * 100 
        : startY + 250.0 + random.nextDouble() * 100;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    final floating = FloatingEmoji(
      emoji: emoji,
      startX: startX,
      startY: startY,
      endX: endX,
      endY: endY,
      controller: controller,
    );

    setState(() {
      _floatingEmojis.add(floating);
    });

    controller.forward().then((_) {
      if (!mounted) return;
      floating.controller.dispose();
      setState(() {
        _floatingEmojis.remove(floating);
      });
    });
  }

  void _toggleEmojiOverlay() {
    setState(() {
      _showEmojiOverlay = !_showEmojiOverlay;
      if (_showEmojiOverlay) {
        _startEmojiOverlayTimer();
      } else {
        _emojiOverlayTimer?.cancel();
      }
    });
  }

  void _startEmojiOverlayTimer() {
    _emojiOverlayTimer?.cancel();
    _emojiOverlayTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showEmojiOverlay) {
        setState(() {
          _showEmojiOverlay = false;
        });
      }
    });
  }

  void _triggerBotEmoji() async {
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    var botEmojis = ['🎯', '🔥', '👑', '😎', '😈'];
    var rngEmoji = botEmojis[DateTime.now().millisecond % botEmojis.length];
    _showEmoji(rngEmoji, false);
  }

  @override
  void dispose() {
    turnTimer?.cancel();
    p1EmojiTimer?.cancel();
    p2EmojiTimer?.cancel();
    _emojiOverlayTimer?.cancel();
    for (var fe in _floatingEmojis) {
      fe.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      child: Stack(
        children: [
          // 1. Live Flame Physics Canvas
          Positioned.fill(
            child: GameWidget(game: game),
          ),

          // 2. Top HUD Scoreboard & Turn Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildHUD(),
          ),

          // 3. Floating Emoji Bubble Popups
          if (p1Emoji != null)
            Positioned(
              top: 110,
              left: 54,
              child: _buildEmojiBubble(p1Emoji!),
            ),
          if (p2Emoji != null)
            Positioned(
              top: 110,
              right: 54,
              child: _buildEmojiBubble(p2Emoji!),
            ),

          // 4. Bottom Controls (Striker position slider + actions)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildControlsBar(),
          ),

          // Floating Emoji Animations
          ..._floatingEmojis.map((fe) {
            return AnimatedBuilder(
              animation: fe.controller,
              builder: (ctx, child) {
                final progress = fe.controller.value;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final scale = (progress * 2.0).clamp(0.0, 1.5);
                final curX = fe.startX + (fe.endX - fe.startX) * progress;
                final curY = fe.startY + (fe.endY - fe.startY) * progress;

                return Positioned(
                  left: curX,
                  top: curY,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Text(
                        fe.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Emoji Overlay Grid (loads above the bottom control bar)
          if (_showEmojiOverlay)
            Positioned(
              bottom: 155,
              left: 16,
              right: 16,
              child: _buildEmojiOverlayGrid(),
            ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    var isP1 = activeTurn == 'player1';
    var isP2 = activeTurn == 'player2';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player 1 Card
          _buildPlayerCard(
            name: 'Shiva (You)',
            score: p1Score,
            isActive: isP1,
            alignment: CrossAxisAlignment.start,
          ),

          IconButton(
            onPressed: () {
              VoiceChatPanelScreen.show(
                context,
                opponentName: widget.mode == 'bot' ? 'CarromBot' : 'StrikerKing',
              );
            },
            icon: const Icon(Icons.mic_rounded, color: AppColors.teal, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Voice Chat',
          ),

          // Middle Timer
          Column(
            children: [
              Text(
                '00:${secondsLeft.toString().padLeft(2, '0')}',
                style: AppTypography.h3.copyWith(
                  color: secondsLeft <= 5 ? AppColors.red : AppColors.gold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isP1 ? 'YOUR TURN' : 'OPPONENT TURN',
                style: AppTypography.small.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isP1 ? AppColors.teal : AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Player 2 Card
          _buildPlayerCard(
            name: widget.mode == 'bot' ? 'CarromBot' : 'StrikerKing',
            score: p2Score,
            isActive: isP2,
            alignment: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required int score,
    required bool isActive,
    required CrossAxisAlignment alignment,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.gold.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? AppColors.gold : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (alignment == CrossAxisAlignment.start) ...[
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.cardLight,
                  child: Icon(Icons.person, size: 14, color: AppColors.textSoft),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                name,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.gold : AppColors.text,
                ),
              ),
              if (alignment == CrossAxisAlignment.end) ...[
                const SizedBox(width: 6),
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.cardLight,
                  child: Icon(Icons.person, size: 14, color: AppColors.textSoft),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Score: $score',
          style: AppTypography.small.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiBubble(String emoji) {
    return Card(
      color: AppColors.surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.align_horizontal_left_rounded, color: AppColors.textSoft, size: 18),
              Expanded(
                child: Slider(
                  value: strikerSliderVal,
                  activeColor: AppColors.gold,
                  inactiveColor: AppColors.line,
                  onChanged: (val) {
                    setState(() => strikerSliderVal = val);
                    game.updateStrikerX(val);
                  },
                ),
              ),
              const Icon(Icons.align_horizontal_right_rounded, color: AppColors.textSoft, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _toggleEmojiOverlay(),
                icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: AppColors.gold, size: 26),
              ),
              Text(
                'Drag back from striker to aim & release to shoot',
                style: AppTypography.small.copyWith(fontSize: 10, color: AppColors.textSoft),
              ),
              IconButton(
                onPressed: () => _openStatsDialog(),
                icon: const Icon(Icons.query_stats_rounded, color: AppColors.teal, size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiOverlayGrid() {
    final emojis = ['🎯', '🔥', '💥', '😂', '👏', '🎉', '🏆', '😎', '🤣', '😤', '👊', '🎮', '👑', '😈', '👋', '😲', '💔', '💪'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUICK REACTION',
                style: AppTypography.small.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'Auto-dismissing...',
                style: AppTypography.small.copyWith(
                  color: AppColors.textSoft,
                  fontSize: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: emojis.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (ctx, i) {
              final emoji = emojis[i];
              return InkWell(
                onTap: () {
                  _showEmoji(emoji, true);
                  ref.read(carromServiceProvider).sendEmoji(emoji);
                  setState(() {
                    _showEmojiOverlay = false;
                  });
                  _emojiOverlayTimer?.cancel();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openStatsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: const Text('Match Stats', style: AppTypography.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow('Striker Speed', 'Average'),
            _statRow('Accuracy', '84%'),
            _statRow('Fouls committed', '0'),
            _statRow('Coins pocketed', '${(p1Score / 10).round()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('CLOSE', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(val, style: AppTypography.body.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FloatingEmoji {
  final String emoji;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final AnimationController controller;

  FloatingEmoji({
    required this.emoji,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.controller,
  });
}
