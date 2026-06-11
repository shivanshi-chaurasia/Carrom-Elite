import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/profile_providers.dart';

class KycVerificationScreen extends ConsumerStatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  ConsumerState<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen> {
  String _aadhaarFront = '';
  String _aadhaarBack = '';
  String _pan = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kycSubmitProvider);

    ref.listen(kycSubmitProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
      if (prev?.isLoading == true && !next.isLoading && !next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KYC documents uploaded successfully!')));
        context.push(AppRoutes.uploadDocs);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('KYC Verification', style: AppTypography.h1),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ACTION REQUIRED',
                          style: AppTypography.small.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _documentUploadZone(
                    title: 'Aadhaar Card',
                    subtitle: 'Front & Back',
                    onTap: () => setState(() {
                      _aadhaarFront = 'aadhaar_front.png';
                      _aadhaarBack = 'aadhaar_back.png';
                    }),
                    fileName: _aadhaarFront,
                  ),
                  const SizedBox(height: 20),
                  _documentUploadZone(
                    title: 'PAN Card',
                    subtitle: 'Front Only',
                    onTap: () => setState(() => _pan = 'pan_file.png'),
                    fileName: _pan,
                  ),
                  const SizedBox(height: 32),
                  _gradientButton(
                    label: state.isLoading ? 'SUBMITTING...' : 'SUBMIT VERIFICATION',
                    onPressed: state.isLoading
                        ? null
                        : () {
                            ref.read(kycSubmitProvider.notifier).submit(
                                  aadhaarFront: _aadhaarFront,
                                  aadhaarBack: _aadhaarBack,
                                  pan: _pan,
                                );
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _documentUploadZone({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required String fileName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.h3),
            Text(subtitle, style: AppTypography.small),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                const Icon(Icons.file_upload_outlined, color: AppColors.purple, size: 28),
                const SizedBox(height: 10),
                Text(
                  fileName.isNotEmpty ? fileName : 'Tap to select files',
                  style: AppTypography.body.copyWith(
                    color: fileName.isNotEmpty ? AppColors.gold : AppColors.text,
                    fontWeight: fileName.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('(JPG, PNG or PDF Max 255MB)', style: AppTypography.small),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradientButton({required String label, required VoidCallback? onPressed}) {
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
