import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CareSectionTitle extends StatelessWidget {
  const CareSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}
