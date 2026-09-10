import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/caregiver_models.dart';

class CaregiverNotificationsPage extends StatefulWidget {
  const CaregiverNotificationsPage({
    super.key,
    required this.dashboard,
    required this.onAcceptInvitation,
    required this.onRejectInvitation,
    required this.onMarkAsRead,
  });

  final CaregiverDashboardData dashboard;
  final Future<void> Function(String invitationId) onAcceptInvitation;
  final Future<void> Function(String invitationId) onRejectInvitation;
  final Future<void> Function(String notificationId) onMarkAsRead;

  @override
  State<CaregiverNotificationsPage> createState() =>
      _CaregiverNotificationsPageState();
}

class _CaregiverNotificationsPageState
    extends State<CaregiverNotificationsPage> {
  final Set<String> _busyInvitationIds = {};
  final Set<String> _readNotificationIds = {};

  @override
  Widget build(BuildContext context) {
    final invitations = widget.dashboard.invitations
        .where((invitation) => invitation.isPending)
        .toList();
    final notifications = widget.dashboard.notifications
        .where(
          (notification) => !_readNotificationIds.contains(notification.id),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSoft,
        foregroundColor: AppColors.primaryDark,
        title: Text(
          'Notificaciones',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          24,
          AppSpacing.screenPadding,
          28,
        ),
        children: [
          Text('Estado de hoy', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            invitations.isEmpty
                ? 'No tienes invitaciones pendientes de revisión.'
                : 'Tienes ${invitations.length} invitación(es) pendiente(s).',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          if (invitations.isNotEmpty) ...[
            const CareSectionTitle('INVITACIONES'),
            const SizedBox(height: 14),
            for (final invitation in invitations) ...[
              _InvitationNotificationCard(
                invitation: invitation,
                busy: _busyInvitationIds.contains(invitation.id),
                onAccept: () => _handleInvitation(invitation.id, accept: true),
                onReject: () => _handleInvitation(invitation.id, accept: false),
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 10),
          ],
          const CareSectionTitle('NOTIFICACIONES'),
          const SizedBox(height: 14),
          if (notifications.isEmpty)
            const _NotificationsEmptyState()
          else
            for (final notification in notifications) ...[
              CareNotificationTile(
                icon: _notificationIcon(notification),
                title: notification.title,
                message: notification.message,
                timeLabel: CareDateFormatters.dateTime(
                  notification.readAt ??
                      notification.sentAt ??
                      notification.createdAt,
                ),
                badge: CareBadge(
                  label: _statusLabel(notification.status),
                  backgroundColor: _statusBackground(notification.status),
                  foregroundColor: _statusForeground(notification.status),
                ),
                actionLabel: notification.status == 'READ'
                    ? null
                    : 'Marcar leído',
                onActionTap: () => _markAsRead(notification.id),
                iconBackgroundColor: _priorityBackground(notification.priority),
                iconColor: _priorityForeground(notification.priority),
              ),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Has llegado al final de tus notificaciones.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleInvitation(
    String invitationId, {
    required bool accept,
  }) async {
    setState(() => _busyInvitationIds.add(invitationId));
    try {
      if (accept) {
        await widget.onAcceptInvitation(invitationId);
      } else {
        await widget.onRejectInvitation(invitationId);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busyInvitationIds.remove(invitationId));
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await widget.onMarkAsRead(notificationId);
    if (mounted) setState(() => _readNotificationIds.add(notificationId));
  }
}

class _InvitationNotificationCard extends StatelessWidget {
  const _InvitationNotificationCard({
    required this.invitation,
    required this.busy,
    required this.onAccept,
    required this.onReject,
  });

  final CaregiverInvitation invitation;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(20),
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
                      'Invitación de cuidado',
                      style: AppTextStyles.titleLarge,
                    ),
                    Text(
                      invitation.patientFullName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const CareBadge(
                label: 'PENDIENTE',
                backgroundColor: AppColors.statusPendingBackground,
                foregroundColor: AppColors.statusPendingText,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Permisos: ${invitation.allowedViews.join(', ')}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onReject,
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: busy ? null : onAccept,
                  child: Text(busy ? 'Procesando...' : 'Aceptar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CareIconBubble(
            icon: Icons.notifications_none,
            size: 58,
            iconSize: 28,
          ),
          const SizedBox(height: 14),
          Text(
            'No hay notificaciones sincronizadas todavía.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

IconData _notificationIcon(CareNotification notification) {
  return switch (notification.type) {
    'ALERT' => Icons.warning_amber_outlined,
    'REMINDER' => Icons.schedule,
    'INVITATION' => Icons.shield_outlined,
    _ => Icons.notifications_none,
  };
}

String _statusLabel(String status) {
  return switch (status) {
    'READ' => 'LEÍDO',
    'SCHEDULED' => 'PENDIENTE',
    'FAILED' => 'FALLIDO',
    'CANCELLED' => 'CANCELADO',
    _ => 'ENVIADO',
  };
}

Color _statusBackground(String status) {
  return switch (status) {
    'READ' => AppColors.statusReadBackground,
    'FAILED' || 'CANCELLED' => AppColors.redLight,
    'SCHEDULED' => AppColors.statusPendingBackground,
    _ => AppColors.greenLight,
  };
}

Color _statusForeground(String status) {
  return switch (status) {
    'READ' => AppColors.statusReadText,
    'FAILED' || 'CANCELLED' => AppColors.redDark,
    'SCHEDULED' => AppColors.statusPendingText,
    _ => AppColors.greenDark,
  };
}

Color _priorityBackground(String priority) {
  return switch (priority) {
    'CRITICAL' => AppColors.redLight,
    'HIGH' => AppColors.primaryLight,
    'MEDIUM' => AppColors.greenLight,
    _ => AppColors.backgroundSoft,
  };
}

Color _priorityForeground(String priority) {
  return switch (priority) {
    'CRITICAL' => AppColors.redDark,
    'HIGH' => AppColors.primaryDark,
    'MEDIUM' => AppColors.greenDark,
    _ => AppColors.iconMuted,
  };
}
