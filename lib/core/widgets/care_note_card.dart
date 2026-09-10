import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'care_badge.dart';
import 'care_card.dart';

class CareNoteCard extends StatelessWidget {
  const CareNoteCard({
    super.key,
    required this.author,
    required this.timestamp,
    required this.body,
    this.avatar,
    this.badges = const [],
    this.showMoreButton = false,
    this.onMorePressed,
  });

  final String author;
  final String timestamp;
  final String body;
  final Widget? avatar;
  final List<CareBadge> badges;
  final bool showMoreButton;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar ??
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      _initials(author),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author, style: AppTextStyles.titleMedium),
                    Text(
                      timestamp,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (showMoreButton)
                IconButton(
                  tooltip: 'Mas opciones',
                  onPressed: onMorePressed,
                  icon: const Icon(Icons.more_vert, color: AppColors.iconMuted),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            body,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(spacing: 8, runSpacing: 8, children: badges),
          ],
        ],
      ),
    );
  }
}

String _initials(String value) {
  final List<String> words = value
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .take(2)
      .toList();

  return words.map((word) => word[0].toUpperCase()).join();
}
