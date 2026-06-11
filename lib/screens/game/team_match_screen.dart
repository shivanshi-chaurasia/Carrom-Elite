import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class TeamMatchScreen extends StatefulWidget {
  const TeamMatchScreen({super.key, this.entryFee = 50});

  final int entryFee;

  @override
  State<TeamMatchScreen> createState() => _TeamMatchScreenState();
}

class _TeamMatchScreenState extends State<TeamMatchScreen> {
  String _teammate = 'Waiting...';
  String _opponent1 = 'Waiting...';
  String _opponent2 = 'Waiting...';
  Timer? _t1;
  Timer? _t2;
  Timer? _t3;
  Timer? _t4;

  @override
  void initState() {
    super.initState();
    
    // Simulate matchmaking updates
    _t1 = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _teammate = 'Player_X92');
    });

    _t2 = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _opponent1 = 'StrikerGod');
    });

    _t3 = Timer(const Duration(milliseconds: 5500), () {
      if (mounted) setState(() => _opponent2 = 'CarromQueen');
    });

    _t4 = Timer(const Duration(milliseconds: 7500), () {
      if (mounted) {
        context.replace('/carrom-match?mode=2v2&matchId=2v2_mock_match');
      }
    });
  }

  @override
  void dispose() {
    _t1?.cancel();
    _t2?.cancel();
    _t3?.cancel();
    _t4?.cancel();
    super.dispose();
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
          '2V2 TEAM MATCH',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
          child: Column(
            children: [
              // Entry Fee header
              _buildEntryFeeHeader(),
              const Spacer(),

              // Player slots grid/layout
              _buildPlayersArena(),
              
              const Spacer(),
              _buildStatusIndicator(),
              const SizedBox(height: 24),

              // Bottom buttons
              _buildActionRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryFeeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ENTRY FEE', style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10)),
              Text('₹${widget.entryFee}', style: AppTypography.h2.copyWith(color: AppColors.gold, fontSize: 24)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('TOTAL PRIZEPOOL', style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10)),
              Text('₹${widget.entryFee * 3.6}', style: AppTypography.h2.copyWith(color: AppColors.teal, fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersArena() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Left Column: Your Team
        Column(
          children: [
            _buildHeading('YOUR TEAM'),
            const SizedBox(height: 16),
            _playerSlot('Shiva (You)', isCurrentPlayer: true),
            const SizedBox(height: 16),
            _playerSlot(_teammate, isTeammate: true),
          ],
        ),
        
        // Center VS Divider
        Text(
          'VS',
          style: AppTypography.h1.copyWith(
            fontSize: 28,
            color: AppColors.textSoft,
            fontStyle: FontStyle.italic,
          ),
        ),

        // Right Column: Opponents
        Column(
          children: [
            _buildHeading('OPPONENTS'),
            const SizedBox(height: 16),
            _playerSlot(_opponent1),
            const SizedBox(height: 16),
            _playerSlot(_opponent2),
          ],
        ),
      ],
    );
  }

  Widget _buildHeading(String title) {
    return Text(
      title,
      style: AppTypography.small.copyWith(
        color: AppColors.teal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _playerSlot(String name, {bool isCurrentPlayer = false, bool isTeammate = false}) {
    final waiting = name == 'Waiting...';
    Color outlineColor = AppColors.line;
    if (isCurrentPlayer) {
      outlineColor = AppColors.gold;
    } else if (!waiting && isTeammate) {
      outlineColor = AppColors.purple;
    } else if (!waiting) {
      outlineColor = AppColors.red;
    }

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor, width: isCurrentPlayer ? 1.5 : 1.0),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: waiting ? AppColors.surface2 : AppColors.purple.withOpacity(0.3),
            child: Icon(
              waiting ? Icons.hourglass_empty_rounded : Icons.person_rounded,
              color: waiting ? AppColors.textSoft : AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: AppTypography.small.copyWith(
              color: waiting ? AppColors.textSoft : AppColors.text,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
        ),
        const SizedBox(width: 10),
        Text(
          _opponent2 == 'Waiting...' ? 'Finding active players...' : 'Match starting in 2 seconds...',
          style: AppTypography.small.copyWith(color: AppColors.textSoft),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.line),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'CANCEL',
                style: AppTypography.button.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.gold],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock Invite Link Copied to clipboard!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'INVITE FRIEND',
                style: AppTypography.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
