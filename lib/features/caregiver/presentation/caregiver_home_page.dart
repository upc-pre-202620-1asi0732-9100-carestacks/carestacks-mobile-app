import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/caregiver_models.dart';
import 'caregiver_ui_helpers.dart';

class CaregiverHomePage extends StatelessWidget {
  const CaregiverHomePage({
    super.key,
    required this.dashboard,
    required this.onNavigate,
    required this.onRefresh,
    required this.onAcceptInvitation,
    required this.onRejectInvitation,
    required this.onNotificationsPressed,
    this.errorMessage,
  });

  final CaregiverDashboardData dashboard;
  final ValueChanged<CareNavDestination> onNavigate;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String invitationId) onAcceptInvitation;
  final Future<void> Function(String invitationId) onRejectInvitation;
  final VoidCallback onNotificationsPressed;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.backgroundSoft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CareTopBar(onNotificationsPressed: onNotificationsPressed),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                24,
                AppSpacing.screenPadding,
                28,
              ),
              child: _HomeContent(
                dashboard: dashboard,
                errorMessage: errorMessage,
                onNavigate: onNavigate,
                onAcceptInvitation: onAcceptInvitation,
                onRejectInvitation: onRejectInvitation,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.dashboard,
    required this.onNavigate,
    required this.onAcceptInvitation,
    required this.onRejectInvitation,
    this.errorMessage,
  });

  final CaregiverDashboardData dashboard;
  final ValueChanged<CareNavDestination> onNavigate;
  final Future<void> Function(String invitationId) onAcceptInvitation;
  final Future<void> Function(String invitationId) onRejectInvitation;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final firstName = dashboard.user.fullName.split(' ').first;
    final activePatient = dashboard.activePatient;
    final pendingInvitations = dashboard.invitations
        .where((invitation) => invitation.isPending)
        .toList();
    final pendingEvent = _nextPendingEvent(dashboard.events);
    final latestNote = dashboard.diaryEntries.isEmpty
        ? null
        : dashboard.diaryEntries.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buenos días,',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text('Hola, $firstName', style: AppTextStyles.headlineLarge),
        if (errorMessage != null) ...[
          const SizedBox(height: 16),
          _SyncWarning(message: errorMessage!),
        ],
        const SizedBox(height: 28),
        if (pendingInvitations.isNotEmpty) ...[
          const CareSectionTitle('INVITACIONES PENDIENTES'),
          const SizedBox(height: 16),
          for (final invitation in pendingInvitations.take(2)) ...[
            _InvitationCard(
              invitation: invitation,
              onAccept: () => onAcceptInvitation(invitation.id),
              onReject: () => onRejectInvitation(invitation.id),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 12),
        ],
        const CareSectionTitle('PACIENTES ASIGNADOS'),
        const SizedBox(height: 16),
        if (activePatient == null)
          _NoPatientCard(hasInvitations: pendingInvitations.isNotEmpty)
        else
          _AssignedPatientCard(
            patient: activePatient,
            patientCount: dashboard.patients.length,
          ),
        const SizedBox(height: 24),
        if (activePatient != null && pendingEvent != null)
          CareEventCard(
            icon: eventIcon(pendingEvent.type),
            title:
                '${activePatient.patientFullName.split(' ').first} - ${CareDateFormatters.timeRange(pendingEvent.startAt, null)}',
            description: pendingEvent.description.isEmpty
                ? pendingEvent.title
                : pendingEvent.description,
            badge: CareBadge(
              label: eventStatusLabel(pendingEvent.status),
              backgroundColor: eventStatusBackground(pendingEvent.status),
              foregroundColor: eventStatusForeground(pendingEvent.status),
            ),
            actionLabel: pendingEvent.status == 'PENDING'
                ? 'Confirmar toma'
                : null,
            onActionPressed: () => onNavigate(CareNavDestination.agenda),
          )
        else
          _TodayCard(activePatient: activePatient),
        const SizedBox(height: 24),
        if (activePatient != null)
          CareMetricSummaryCard(
            title: 'RESUMEN DEL DÍA',
            metrics: [
              CareMetric(
                value: _countStatus('PENDING').toString(),
                label: 'PENDIENTES',
                color: AppColors.primaryDark,
              ),
              CareMetric(
                value: _countStatus('CONFIRMED').toString(),
                label: 'CONFIRMADOS',
                color: AppColors.greenDark,
              ),
              CareMetric(
                value: _countStatus('MISSED').toString(),
                label: 'INCUMPLIDOS',
                color: AppColors.redDark,
              ),
            ],
          ),
        const SizedBox(height: 24),
        if (activePatient != null)
          CareNoteCard(
            author: activePatient.patientFullName,
            timestamp: latestNote == null
                ? 'Bienestar hoy'
                : CareDateFormatters.dateTime(latestNote.entryDate),
            body:
                latestNote?.content ??
                'Recuerda revisar el diario de ánimo y las tareas pendientes del paciente.',
            badges: const [
              CareBadge(
                label: 'Bienestar',
                backgroundColor: AppColors.greenLight,
                foregroundColor: AppColors.greenDark,
              ),
            ],
          ),
        const SizedBox(height: 26),
        const CareSectionTitle('ACCIONES RÁPIDAS'),
        const SizedBox(height: 16),
        CareActionTile(
          icon: Icons.calendar_today_outlined,
          label: 'Revisar agenda',
          onTap: () => onNavigate(CareNavDestination.agenda),
        ),
        const SizedBox(height: 14),
        CareActionTile(
          icon: Icons.description_outlined,
          label: 'Ver documentos',
          onTap: () => onNavigate(CareNavDestination.documents),
        ),
        const SizedBox(height: 14),
        CareActionTile(
          icon: Icons.edit_note_outlined,
          label: 'Ver diario',
          onTap: () => onNavigate(CareNavDestination.diary),
        ),
      ],
    );
  }

  int _countStatus(String status) =>
      dashboard.events.where((event) => event.status == status).length;
}

HealthEvent? _nextPendingEvent(List<HealthEvent> events) {
  final pending = events.where((event) => event.status == 'PENDING').toList();
  pending.sort((a, b) => (a.startAt ?? '').compareTo(b.startAt ?? ''));
  return pending.isEmpty ? null : pending.first;
}

class _AssignedPatientCard extends StatelessWidget {
  const _AssignedPatientCard({
    required this.patient,
    required this.patientCount,
  });

  final LinkedPatient patient;
  final int patientCount;

  @override
  Widget build(BuildContext context) {
    return CareInfoTile(
      icon: Icons.person_outline,
      title: patient.patientFullName,
      subtitle: patientCount > 1
          ? '$patientCount pacientes vinculados'
          : 'Paciente activo',
      iconBackgroundColor: AppColors.greenLight,
      iconColor: AppColors.greenDark,
      trailing: const CareBadge(
        label: 'Activo',
        backgroundColor: AppColors.greenLight,
        foregroundColor: AppColors.greenDark,
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  });

  final CaregiverInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CareIconBubble(
                icon: Icons.shield_outlined,
                backgroundColor: AppColors.primaryLight,
                iconColor: AppColors.primaryDark,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.patientFullName,
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      'quiere compartir su cuidado contigo',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  child: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoPatientCard extends StatelessWidget {
  const _NoPatientCard({required this.hasInvitations});

  final bool hasInvitations;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const CareIconBubble(
            icon: Icons.group_add_outlined,
            size: 58,
            iconSize: 28,
          ),
          const SizedBox(height: 14),
          Text(
            'Aún no tienes pacientes activos',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            hasInvitations
                ? 'Acepta una invitación pendiente para empezar.'
                : 'Cuando un paciente te invite, aparecerá en notificaciones para aceptar o rechazar.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.activePatient});

  final LinkedPatient? activePatient;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          const CareIconBubble(
            icon: Icons.check_circle_outline,
            backgroundColor: AppColors.greenLight,
            iconColor: AppColors.greenDark,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              activePatient == null
                  ? 'Acepta una invitación para ver tareas del día.'
                  : 'No hay eventos pendientes para ${activePatient!.patientFullName}.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncWarning extends StatelessWidget {
  const _SyncWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      backgroundColor: AppColors.orangeLight,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.orangeDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutral,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
