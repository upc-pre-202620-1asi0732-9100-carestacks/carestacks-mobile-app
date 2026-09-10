import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'care_card.dart';

class CareActionTile extends StatelessWidget {
  const CareActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBackgroundColor = AppColors.greenLight,
    this.iconColor = AppColors.greenDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconBackgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.greenLight,
            ).copyWith(color: iconBackgroundColor),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: AppColors.iconMuted, size: 26),
        ],
      ),
    );
  }
}
