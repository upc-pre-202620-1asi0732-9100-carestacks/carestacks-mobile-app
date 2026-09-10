import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'care_badge.dart';
import 'care_card.dart';
import 'care_icon_bubble.dart';
import 'care_primary_button.dart';

class CareEventCard extends StatelessWidget {
  const CareEventCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
    this.actionLabel,
    this.onActionPressed,
    this.iconBackgroundColor = AppColors.primary,
    this.iconColor = AppColors.surface,
  });

  final IconData icon;
  final String title;
  final String description;
  final CareBadge? badge;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color iconBackgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CareIconBubble(
                icon: icon,
                size: 56,
                iconSize: 28,
                backgroundColor: iconBackgroundColor,
                iconColor: iconColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          badge!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(left: 72),
              child: CarePrimaryButton(
                label: actionLabel!,
                onPressed: onActionPressed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
