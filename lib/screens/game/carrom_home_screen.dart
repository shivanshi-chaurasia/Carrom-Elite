import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class CarromHomeScreen extends ConsumerStatefulWidget {
  const CarromHomeScreen({super.key});

  @override
  ConsumerState<CarromHomeScreen> createState() => _CarromHomeState();
}

class _CarromHomeState extends ConsumerState<CarromHomeScreen> {
  int selectedFee = 25;
  final List<int> entryFees = [10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
      child: Column(
        children: [
          GamingAppBar(
            title: 'CARROM KING',
            subtitle: 'Choose your arena',
            onBack: () => context.go('/'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildModeHeader('PUBLIC MATCHES', 'Compete with live online players'),
                const SizedBox(height: 12),
                _buildPublicLobbies(),
                const SizedBox(height: 28),
                _buildModeHeader('CUSTOM MATES', 'Play with friends locally or online'),
                const SizedBox(height: 12),
                _buildPrivateRoomCard(),
                const SizedBox(height: 28),
                _buildModeHeader('OFFLINE ACTION', 'Train and level up your skills'),
                const SizedBox(height: 12),
                _buildPracticeCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeHeader(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.small.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(desc, style: AppTypography.small.copyWith(color: AppColors.textSoft)),
      ],
    );
  }

  Widget _buildPublicLobbies() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Entry Fee', style: AppTypography.body),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: entryFees.map((fee) {
              var isSelected = fee == selectedFee;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedFee = fee),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gold : AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : AppColors.line,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '₹$fee',
                        style: AppTypography.h3.copyWith(
                          color: isSelected ? AppColors.bg : AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              context.push('/carrom-lobby?fee=$selectedFee');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.bg,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'FIND OPPONENT',
              style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateRoomCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Private Room', style: AppTypography.h3),
                const SizedBox(height: 4),
                Text(
                  'Create custom table and share code',
                  style: AppTypography.small.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/carrom-lobby?mode=private');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface2,
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CREATE/JOIN'),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Practice Mode', style: AppTypography.h3),
                const SizedBox(height: 4),
                Text(
                  'Play offline vs bot. No coins required.',
                  style: AppTypography.small.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/carrom-match?mode=bot');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: AppColors.bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'START BOT',
              style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
