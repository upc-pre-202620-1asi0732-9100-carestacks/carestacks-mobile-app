import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CareIconBubble extends StatelessWidget {
  const CareIconBubble({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.primaryLight,
    this.iconColor = AppColors.primary,
    this.size = 48,
    this.iconSize = 24,
    this.shape = BoxShape.circle,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(8)
            : null,
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}
