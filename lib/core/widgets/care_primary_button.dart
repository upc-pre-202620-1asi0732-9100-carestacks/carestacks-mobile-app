import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CarePrimaryButton extends StatelessWidget {
  const CarePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = enabled ? onPressed : null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: action,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.disabled,
          foregroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  color: enabled ? AppColors.surface : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
