import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'care_card.dart';

class CareMetric {
  const CareMetric({
    required this.value,
    required this.label,
    required this.color,
    this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData? icon;
}

class CareMetricSummaryCard extends StatelessWidget {
  const CareMetricSummaryCard({
    super.key,
    required this.title,
    required this.metrics,
  });
  final String title;
  final List<CareMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (int index = 0; index < metrics.length; index++) ...[
                Expanded(child: _CareMetricItem(metric: metrics[index])),
                if (index != metrics.length - 1)
                  Container(width: 1, height: 56, color: AppColors.border),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CareMetricItem extends StatelessWidget {
  const _CareMetricItem({required this.metric});

  final CareMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (metric.icon != null)
          Icon(metric.icon, color: metric.color, size: 28)
        else
          Text(
            metric.value,
            style: AppTextStyles.headlineLarge.copyWith(color: metric.color),
          ),
        const SizedBox(height: 4),
        Text(
          metric.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
