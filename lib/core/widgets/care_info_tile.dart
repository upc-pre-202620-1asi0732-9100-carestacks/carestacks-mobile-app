import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'care_card.dart';
import 'care_icon_bubble.dart';

class CareInfoTile extends StatelessWidget {
  const CareInfoTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconBackgroundColor = AppColors.greenLight,
    this.iconColor = AppColors.greenDark,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color iconBackgroundColor;
  final Color iconColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      onTap: onTap,
      padding: padding,
      child: Row(
        children: [
          CareIconBubble(
            icon: icon,
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
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing ??
              const Icon(
                Icons.chevron_right,
                color: AppColors.iconMuted,
                size: 26,
              ),
        ],
      ),
    );
  }
}
