import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class SoundGraphicsSettingsScreen extends ConsumerWidget {
  const SoundGraphicsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);

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
          'SOUND & GRAPHICS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildHeading('AUDIO SETTINGS'),
          const SizedBox(height: 12),
          _buildSliderCard(
            title: 'Sound Effects (SFX)',
            value: prefs.sfxVolume,
            icon: Icons.volume_up_rounded,
            onChanged: notifier.setSFXVolume,
          ),
          const SizedBox(height: 12),
          _buildSliderCard(
            title: 'Background Music (BGM)',
            value: prefs.musicVolume,
            icon: Icons.music_note_rounded,
            onChanged: notifier.setMusicVolume,
          ),
          const SizedBox(height: 12),
          _buildSwitchCard(
            title: 'Haptic Feedback / Vibrations',
            value: prefs.hapticsEnabled,
            icon: Icons.vibration_rounded,
            onChanged: notifier.setHaptics,
          ),
          const SizedBox(height: 24),
          _buildHeading('GRAPHICS & PERFORMANCE'),
          const SizedBox(height: 12),
          _buildGraphicsSelector(context, prefs.graphicsQuality, notifier),
          const SizedBox(height: 24),
          _buildInfoNote(),
        ],
      ),
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

  Widget _buildSliderCard({
    required String title,
    required double value,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
              const Spacer(),
              Text('${(value * 100).toInt()}%', style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.purple,
              inactiveTrackColor: AppColors.bg,
              thumbColor: AppColors.white,
              overlayColor: AppColors.purple.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.purple,
            inactiveThumbColor: AppColors.textSoft,
            inactiveTrackColor: AppColors.bg,
          ),
        ],
      ),
    );
  }

  Widget _buildGraphicsSelector(
    BuildContext context,
    String current,
    UserPreferencesNotifier notifier,
  ) {
    final options = [
      {'key': 'Low', 'fps': '30 FPS', 'desc': 'Best battery life'},
      {'key': 'Medium', 'fps': '60 FPS', 'desc': 'Smooth gameplay'},
      {'key': 'High', 'fps': '60 FPS', 'desc': 'Detailed textures'},
      {'key': 'Ultra', 'fps': '90+ FPS', 'desc': 'Maximum fidelity'},
    ];

    return Column(
      children: options.map((opt) {
        final key = opt['key']!;
        final isSelected = current == key;

        return Card(
          color: isSelected ? AppColors.surface2 : AppColors.surface,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? AppColors.gold : AppColors.line, width: isSelected ? 1.5 : 1.0),
          ),
          child: InkWell(
            onTap: () => notifier.setGraphics(key),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Radio<String>(
                    value: key,
                    groupValue: current,
                    activeColor: AppColors.gold,
                    onChanged: (val) {
                      if (val != null) notifier.setGraphics(val);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              key,
                              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.gold.withOpacity(0.15) : AppColors.bg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: isSelected ? AppColors.gold : AppColors.line),
                              ),
                              child: Text(
                                opt['fps']!,
                                style: AppTypography.small.copyWith(
                                  color: isSelected ? AppColors.gold : AppColors.textSoft,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          opt['desc']!,
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
      }).toList(),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.purple.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.purple, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'High and Ultra settings consume more battery power and may cause your device to run warm during long gaming sessions.',
              style: AppTypography.small.copyWith(color: AppColors.textMuted, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
