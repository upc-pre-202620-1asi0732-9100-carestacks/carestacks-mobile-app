import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/caregiver_models.dart';

class CaregiverProfilePage extends StatelessWidget {
  const CaregiverProfilePage({
    super.key,
    required this.dashboard,
    required this.onPatientSelected,
    required this.onLogout,
    required this.onNotificationsPressed,
  });

  final CaregiverDashboardData dashboard;
  final Future<void> Function(String patientId) onPatientSelected;
  final VoidCallback onLogout;
  final VoidCallback onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    final user = dashboard.user;
    final activePatient = dashboard.activePatient;

    return Column(
      children: [
        Container(
          color: AppColors.backgroundSoft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CareTopBar(
            title: 'Perfil',
            onNotificationsPressed: onNotificationsPressed,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              24,
              AppSpacing.screenPadding,
              28,
            ),
            children: [
              CareCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        _initials(user.fullName),
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user.fullName,
                      style: AppTextStyles.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const CareBadge(
                      label: 'Cuidador verificado',
                      backgroundColor: AppColors.greenLight,
                      foregroundColor: AppColors.greenDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CareMetricSummaryCard(
                title: 'RESUMEN DE CUIDADO',
                metrics: [
                  CareMetric(
                    value: dashboard.patients.length.toString(),
                    label: 'PACIENTES',
                    color: AppColors.primaryDark,
                  ),
                  CareMetric(
                    value: dashboard.invitations
                        .where((invitation) => invitation.isPending)
                        .length
                        .toString(),
                    label: 'INVITACIONES',
                    color: AppColors.orangeDark,
                  ),
                  CareMetric(
                    value: dashboard.notifications.length.toString(),
                    label: 'AVISOS',
                    color: AppColors.greenDark,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const CareSectionTitle('PACIENTES VINCULADOS'),
              const SizedBox(height: 14),
              if (dashboard.patients.isEmpty)
                const _NoLinkedPatients()
              else
                for (final patient in dashboard.patients) ...[
                  _PatientAccessCard(
                    patient: patient,
                    selected: activePatient?.patientId == patient.patientId,
                    onTap: () => onPatientSelected(patient.patientId),
                  ),
                  const SizedBox(height: 14),
                ],
              const SizedBox(height: 16),
              CareActionTile(
                icon: Icons.logout,
                label: 'Cerrar sesión',
                iconBackgroundColor: AppColors.redLight,
                iconColor: AppColors.redDark,
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatientAccessCard extends StatelessWidget {
  const _PatientAccessCard({
    required this.patient,
    required this.selected,
    required this.onTap,
  });

  final LinkedPatient patient;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      backgroundColor: selected ? AppColors.backgroundSoft : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CareIconBubble(
                icon: selected ? Icons.check_circle : Icons.person_outline,
                backgroundColor: selected
                    ? AppColors.greenLight
                    : AppColors.primaryLight,
                iconColor: selected
                    ? AppColors.greenDark
                    : AppColors.primaryDark,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  patient.patientFullName,
                  style: AppTextStyles.titleMedium,
                ),
              ),
              if (selected)
                const CareBadge(
                  label: 'Activo',
                  backgroundColor: AppColors.greenLight,
                  foregroundColor: AppColors.greenDark,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final view in patient.allowedViews)
                CareBadge(
                  label: _viewLabel(view),
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.primaryDark,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoLinkedPatients extends StatelessWidget {
  const _NoLinkedPatients();

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Aún no tienes pacientes vinculados. Las invitaciones aparecerán en notificaciones para aceptarlas o rechazarlas.',
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2);
  return words.map((word) => word[0].toUpperCase()).join();
}

String _viewLabel(String value) {
  return switch (value) {
    'PROFILE' => 'Perfil',
    'AGENDA' => 'Agenda',
    'DOCUMENTS' => 'Documentos',
    'DIARY' => 'Diario',
    'NOTIFICATIONS' => 'Notificaciones',
    _ => value,
  };
}
