import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CareSearchField extends StatelessWidget {
  const CareSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.iconMuted,
          size: 23,
        ),
      ),
    );
  }
}
