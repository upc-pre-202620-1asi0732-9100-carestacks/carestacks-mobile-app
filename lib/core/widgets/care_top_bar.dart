import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CareTopBar extends StatelessWidget {
  const CareTopBar({
    super.key,
    this.title = 'CareConnect',
    this.onMenuPressed,
    this.onNotificationsPressed,
    this.showMenu = true,
    this.showNotifications = true,
  });

  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationsPressed;
  final bool showMenu;
  final bool showNotifications;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: showMenu
                  ? IconButton(
                      tooltip: 'Menu',
                      onPressed: onMenuPressed,
                      icon: const Icon(Icons.menu, size: 25),
                      color: AppColors.primaryDark,
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: showNotifications
                  ? IconButton(
                      tooltip: 'Notificaciones',
                      onPressed: onNotificationsPressed,
                      icon: const Icon(Icons.notifications_none, size: 25),
                      color: AppColors.primaryDark,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
