import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CareCard extends StatelessWidget {
  const CareCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.elevation = 2,
    this.backgroundColor = AppColors.surface,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(12),
            blurRadius: elevation * 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.border),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
