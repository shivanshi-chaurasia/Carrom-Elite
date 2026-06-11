import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class MatchReplayScreen extends StatefulWidget {
  const MatchReplayScreen({
    super.key,
    this.p1Name = 'Shiva (You)',
    this.p2Name = 'StrikerKing',
  });

  final String p1Name;
  final String p2Name;

  @override
  State<MatchReplayScreen> createState() => _MatchReplayScreenState();
}

class _MatchReplayScreenState extends State<MatchReplayScreen> {
  bool _isPlaying = false;
  double _timelineValue = 0.0;
  double _speed = 1.0;
  int _p1Score = 0;
  int _p2Score = 0;
  Timer? _playbackTimer;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _startPlayback() {
    _playbackTimer?.cancel();
    final intervalMs = (100 / _speed).toInt();
    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timelineValue >= 100.0) {
          _timelineValue = 100.0;
          _isPlaying = false;
          _playbackTimer?.cancel();
        } else {
          _timelineValue += 1.0;
          // Dynamically update scores based on playback timeline progress
          _p1Score = (_timelineValue * 0.19).toInt();
          _p2Score = (_timelineValue * 0.14).toInt();
        }
      });
    });
  }

  void _pausePlayback() {
    _playbackTimer?.cancel();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startPlayback();
      } else {
        _pausePlayback();
      }
    });
  }

  void _updateSpeed(double newSpeed) {
    setState(() {
      _speed = newSpeed;
      if (_isPlaying) {
        _startPlayback();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'MATCH REPLAY',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildScoreBoard(),
            const Spacer(),
            
            // Carrom Board Replay CustomPainter Area
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.purple.withOpacity(0.12), blurRadius: 20, spreadRadius: 2)
                  ],
                ),
                child: CustomPaint(
                  size: const Size(280, 280),
                  painter: _ReplayBoardPainter(_timelineValue),
                ),
              ),
            ),

            const Spacer(),

            // Scrubber Timeline slider
            _buildScrubberRow(),

            // Playback controls panel
            _buildPlaybackControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.p1Name, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                Text('Score: $_p1Score', style: AppTypography.small.copyWith(color: AppColors.purple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(4)),
            child: Text('VS', style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.p2Name, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                Text('Score: $_p2Score', style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrubberRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            '00:${(_timelineValue * 0.12).toInt().toString().padLeft(2, '0')}',
            style: AppTypography.small.copyWith(color: AppColors.textSoft),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.gold,
                inactiveTrackColor: AppColors.surface,
                thumbColor: AppColors.white,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: _timelineValue,
                min: 0.0,
                max: 100.0,
                onChanged: (val) {
                  setState(() {
                    _timelineValue = val;
                    _p1Score = (_timelineValue * 0.19).toInt();
                    _p2Score = (_timelineValue * 0.14).toInt();
                  });
                },
              ),
            ),
          ),
          Text(
            '00:12',
            style: AppTypography.small.copyWith(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Playback Speed Toggle
          Row(
            children: [0.5, 1.0, 2.0].map((s) {
              final selected = _speed == s;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('${s}x', style: AppTypography.small.copyWith(color: selected ? Colors.black : AppColors.textSoft)),
                  selected: selected,
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.bg,
                  onSelected: (val) {
                    if (val) _updateSpeed(s);
                  },
                ),
              );
            }).toList(),
          ),

          // Central Play/Pause
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.purple,
            child: IconButton(
              icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.white, size: 28),
              onPressed: _togglePlay,
            ),
          ),

          // Refresh/Restart playback
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.textSoft),
            onPressed: () {
              setState(() {
                _timelineValue = 0.0;
                _p1Score = 0;
                _p2Score = 0;
                if (_isPlaying) {
                  _startPlayback();
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

// Carrom board painter with animated positioning values mapping to timeline scrubber progress
class _ReplayBoardPainter extends CustomPainter {
  _ReplayBoardPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Board Outline
    final boardPaint = Paint()
      ..color = const Color(0xFF0F3223) // Dark green board
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12)),
      boardPaint,
    );

    // Board wood frame
    final framePaint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12)),
      framePaint,
    );

    // Pockets at corners
    final pocketPaint = Paint()..color = Colors.black;
    canvas.drawCircle(const Offset(16, 16), 10, pocketPaint);
    canvas.drawCircle(Offset(size.width - 16, 16), 10, pocketPaint);
    canvas.drawCircle(Offset(16, size.height - 16), 10, pocketPaint);
    canvas.drawCircle(Offset(size.width - 16, size.height - 16), 10, pocketPaint);

    // Center Red Queen circle
    canvas.drawCircle(center, 22, Paint()..color = AppColors.gold.withOpacity(0.2)..style = PaintingStyle.stroke);
    canvas.drawCircle(center, 4, Paint()..color = AppColors.red);

    // Animated striker coordinate mapping to progress scrubber
    final strikerX = center.dx + 40 * progress * 0.01;
    final strikerY = center.dy + 80 * progress * 0.01;
    
    // Draw striker
    final strikerPaint = Paint()..color = AppColors.gold;
    canvas.drawCircle(Offset(strikerX, strikerY), 10, strikerPaint);
    canvas.drawCircle(Offset(strikerX, strikerY), 8, Paint()..color = Colors.white..style = PaintingStyle.stroke);

    // Draw other remaining coins
    final coinPaint = Paint()..style = PaintingStyle.fill;
    coinPaint.color = AppColors.white;
    canvas.drawCircle(Offset(center.dx - 12 + progress * 0.05, center.dy - 12), 6, coinPaint);
    coinPaint.color = Colors.black;
    canvas.drawCircle(Offset(center.dx + 12 - progress * 0.08, center.dy + 12), 6, coinPaint);
  }

  @override
  bool shouldRepaint(covariant _ReplayBoardPainter oldDelegate) => oldDelegate.progress != progress;
}
