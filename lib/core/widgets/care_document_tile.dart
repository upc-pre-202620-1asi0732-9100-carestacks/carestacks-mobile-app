import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'care_badge.dart';
import 'care_card.dart';
import 'care_icon_bubble.dart';

class CareDocumentTile extends StatelessWidget {
  const CareDocumentTile({
    super.key,
    required this.icon,
    required this.title,
    required this.typeLabel,
    required this.dateLabel,
    this.onTap,
    this.iconBackgroundColor = AppColors.primaryLight,
    this.iconColor = AppColors.primaryDark,
    this.badgeBackgroundColor = AppColors.primaryLight,
    this.badgeTextColor = AppColors.primaryDark,
  });

  final IconData icon;
  final String title;
  final String typeLabel;
  final String dateLabel;
  final VoidCallback? onTap;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CareIconBubble(
            icon: icon,
            shape: BoxShape.rectangle,
            backgroundColor: iconBackgroundColor,
            iconColor: iconColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CareBadge(
                      label: typeLabel,
                      backgroundColor: badgeBackgroundColor,
                      foregroundColor: badgeTextColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: AppColors.iconMuted, size: 26),
        ],
      ),
    );
  }
}
