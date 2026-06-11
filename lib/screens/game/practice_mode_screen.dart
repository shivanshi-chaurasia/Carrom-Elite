import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class PracticeModeScreen extends StatefulWidget {
  const PracticeModeScreen({super.key});

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  String _selectedDifficulty = 'Easy';

  final List<Map<String, String>> _levels = [
    {
      'name': 'Easy',
      'desc': 'Good for beginners. Bot takes slow shots and misses occasionally.',
      'tag': 'Beginner friendly',
    },
    {
      'name': 'Medium',
      'desc': 'For average players. Bot makes calculated shots with decent speed.',
      'tag': 'Balanced challenge',
    },
    {
      'name': 'Hard',
      'desc': 'Face the ultimate bot challenge. Perfect aim, high speed, and bounce shots.',
      'tag': 'Expert level',
    },
  ];

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
          'PRACTICE MODE',
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Bot Difficulty',
                style: AppTypography.h2.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Sharpen your carrom skills offline with our smart AI bots.',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              
              // Difficulty Cards
              Expanded(
                child: ListView.builder(
                  itemCount: _levels.length,
                  itemBuilder: (ctx, idx) {
                    final item = _levels[idx];
                    final isSelected = _selectedDifficulty == item['name'];
                    
                    return Card(
                      color: isSelected ? AppColors.surface2 : AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? AppColors.purple : AppColors.line,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => setState(() => _selectedDifficulty = item['name']!),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.purple.withOpacity(0.15),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.bg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Icon(
                                  Icons.smart_toy_rounded,
                                  color: isSelected ? AppColors.gold : AppColors.textSoft,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item['name']!,
                                          style: AppTypography.h3.copyWith(
                                            color: isSelected ? AppColors.gold : AppColors.text,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.purple.withOpacity(0.2) : AppColors.surface,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item['tag']!,
                                            style: AppTypography.small.copyWith(
                                              fontSize: 9,
                                              color: isSelected ? AppColors.purple : AppColors.textSoft,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['desc']!,
                                      style: AppTypography.small.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Play Button
              _gradientButton('PLAY PRACTICE MATCH', () {
                // Navigate to bot match
                context.push('/carrom-match?mode=bot&difficulty=${_selectedDifficulty.toLowerCase()}');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradientButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
