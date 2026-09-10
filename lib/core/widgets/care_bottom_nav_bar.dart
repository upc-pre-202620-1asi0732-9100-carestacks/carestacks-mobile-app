import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum CareNavDestination {
  home(label: 'Inicio', icon: Icons.home_outlined, selectedIcon: Icons.home),
  agenda(
    label: 'Agenda',
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_today,
  ),
  documents(
    label: 'Documentos',
    icon: Icons.description_outlined,
    selectedIcon: Icons.description,
  ),
  diary(
    label: 'Diario',
    icon: Icons.edit_note_outlined,
    selectedIcon: Icons.edit_note,
  ),
  profile(
    label: 'Perfil',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  );

  const CareNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class CareBottomNavBar extends StatelessWidget {
  const CareBottomNavBar({
    super.key,
    required this.currentDestination,
    required this.onDestinationSelected,
  });

  final CareNavDestination currentDestination;
  final ValueChanged<CareNavDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? AppColors.primary : AppColors.textMuted,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),
      child: NavigationBar(
        height: 72,
        backgroundColor: AppColors.surface,
        elevation: 4,
        selectedIndex: currentDestination.index,
        onDestinationSelected: (index) =>
            onDestinationSelected(CareNavDestination.values[index]),
        destinations: [
          for (final destination in CareNavDestination.values)
            NavigationDestination(
              icon: Icon(destination.icon, color: AppColors.iconMuted),
              selectedIcon: Icon(
                destination.selectedIcon,
                color: AppColors.primary,
              ),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
