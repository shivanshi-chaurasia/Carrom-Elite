import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AppTypography {
  static const font = 'Roboto';

  static const h1 = TextStyle(
    fontFamily: font,
    fontSize: 28,
    height: 1.08,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );

  static const h2 = TextStyle(
    fontFamily: font,
    fontSize: 22,
    height: 1.15,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );

  static const h3 = TextStyle(
    fontFamily: font,
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const body = TextStyle(
    fontFamily: font,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const small = TextStyle(
    fontFamily: font,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textSoft,
  );

  static const button = TextStyle(
    fontFamily: font,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.bg,
  );
}
