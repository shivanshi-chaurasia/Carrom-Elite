import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class PreviousWinnersScreen extends StatefulWidget {
  const PreviousWinnersScreen({super.key});

  @override
  State<PreviousWinnersScreen> createState() => _PreviousWinnersScreenState();
}

class _PreviousWinnersScreenState extends State<PreviousWinnersScreen> {
  String _activeTab = 'Daily';
  bool _isLoading = true;

  // Mock winner database
  final Map<String, List<Map<String, dynamic>>> _winnerData = {
    'Daily': [
      {
        'rank': 1,
        'name': 'Rahul S',
        'avatar': 'RS',
        'prize': '₹10,000',
        'date': '11 June 2026',
      },
      {
        'rank': 2,
        'name': 'Karan M',
        'avatar': 'KM',
        'prize': '₹5,000',
        'date': '11 June 2026',
      },
      {
        'rank': 3,
        'name': 'Amit K',
        'avatar': 'AK',
        'prize': '₹2,500',
        'date': '11 June 2026',
      },
      {
        'rank': 4,
        'name': 'Suresh P',
        'avatar': 'SP',
        'prize': '₹1,000',
        'date': '11 June 2026',
      },
    ],
    'Weekly': [
      {
        'rank': 1,
        'name': 'Vikram G',
        'avatar': 'VG',
        'prize': '₹50,000',
        'date': '08 June 2026',
      },
      {
        'rank': 2,
        'name': 'Priya D',
        'avatar': 'PD',
        'prize': '₹25,000',
        'date': '08 June 2026',
      },
      {
        'rank': 3,
        'name': 'Nikhil J',
        'avatar': 'NJ',
        'prize': '₹12,500',
        'date': '08 June 2026',
      },
    ],
    'Jackpot': [
      {
        'rank': 1,
        'name': 'StrikerKing',
        'avatar': 'SK',
        'prize': '₹1,00,000',
        'date': '04 June 2026',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadWinners();
  }

  void _loadWinners() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
          'PREVIOUS WINNERS',
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
            _buildFilterRow(),
            Expanded(
              child: _isLoading
                  ? _buildShimmerLoadingList()
                  : _buildWinnersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final tabs = ['Daily', 'Weekly', 'Jackpot'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((tab) {
          final isSelected = _activeTab == tab;
          return ChoiceChip(
            label: Text(
              tab.toUpperCase(),
              style: AppTypography.small.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : AppColors.textSoft,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.gold,
            backgroundColor: AppColors.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isSelected ? AppColors.gold : AppColors.line),
            ),
            onSelected: (val) {
              if (val) {
                setState(() => _activeTab = tab);
                _loadWinners();
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWinnersList() {
    final list = _winnerData[_activeTab] ?? [];
    if (list.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final winner = list[idx];
        return _buildWinnerCard(winner);
      },
    );
  }

  Widget _buildWinnerCard(Map<String, dynamic> winner) {
    final rank = winner['rank'] as int;
    String rankBadge = rank.toString();
    Color rankColor = AppColors.textSoft;
    if (rank == 1) {
      rankBadge = '🥇';
      rankColor = AppColors.gold;
    } else if (rank == 2) {
      rankBadge = '🥈';
      rankColor = AppColors.white;
    } else if (rank == 3) {
      rankBadge = '🥉';
      rankColor = const Color(0xFFCD7F32);
    }

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,
                border: Border.all(color: rankColor.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Text(
                rankBadge,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: rankColor),
              ),
            ),
            const SizedBox(width: 14),

            // Winner Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.purple.withOpacity(0.12),
              child: Text(
                winner['avatar'] as String,
                style: AppTypography.small.copyWith(color: AppColors.purple, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),

            // Name & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    winner['name'] as String,
                    style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    winner['date'] as String,
                    style: AppTypography.small.copyWith(color: AppColors.textSoft),
                  ),
                ],
              ),
            ),

            // Prize
            Text(
              winner['prize'] as String,
              style: AppTypography.body.copyWith(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (ctx, idx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.bg, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              const CircleAvatar(radius: 20, backgroundColor: AppColors.bg),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 12, color: AppColors.bg),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 8, color: AppColors.bg),
                  ],
                ),
              ),
              Container(width: 70, height: 16, color: AppColors.bg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied_rounded, color: AppColors.textSoft, size: 54),
          const SizedBox(height: 16),
          Text(
            'No Winners Recorded',
            style: AppTypography.h3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Check back after the next drawing has occurred.',
            style: AppTypography.small.copyWith(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}
