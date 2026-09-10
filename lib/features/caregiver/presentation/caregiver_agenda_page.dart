import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/caregiver_models.dart';
import 'caregiver_ui_helpers.dart';

class CaregiverAgendaPage extends StatefulWidget {
  const CaregiverAgendaPage({
    super.key,
    required this.dashboard,
    required this.onConfirmEvent,
    required this.onSaveEvent,
    required this.onNotificationsPressed,
    required this.onRefresh,
  });

  final CaregiverDashboardData dashboard;
  final Future<void> Function(String eventId) onConfirmEvent;
  final Future<void> Function(HealthEventDraft draft) onSaveEvent;
  final VoidCallback onNotificationsPressed;
  final Future<void> Function() onRefresh;

  @override
  State<CaregiverAgendaPage> createState() => _CaregiverAgendaPageState();
}

class _CaregiverAgendaPageState extends State<CaregiverAgendaPage> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = DateTime(today.year, today.month, today.day);
    _visibleMonth = DateTime(today.year, today.month);
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.dashboard.activePatient;
    final events = [...widget.dashboard.events]
      ..sort((a, b) => (a.startAt ?? '').compareTo(b.startAt ?? ''));
    final selectedEvents = events.where((event) {
      return _sameDay(CareDateFormatters.parse(event.startAt), _selectedDate);
    }).toList();

    return Column(
      children: [
        Container(
          color: AppColors.backgroundSoft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CareTopBar(
            title: 'Agenda',
            onNotificationsPressed: widget.onNotificationsPressed,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                24,
                AppSpacing.screenPadding,
                28,
              ),
              children: [
                _CalendarCard(
                  visibleMonth: _visibleMonth,
                  selectedDate: _selectedDate,
                  events: events,
                  onPreviousMonth: () => _changeMonth(-1),
                  onNextMonth: () => _changeMonth(1),
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = DateTime(date.year, date.month, date.day);
                      _visibleMonth = DateTime(date.year, date.month);
                    });
                  },
                ),
                const SizedBox(height: 28),
                _EventsHeader(selectedDate: _selectedDate),
                const SizedBox(height: 18),
                Text(
                  patient == null
                      ? 'Acepta una invitación para revisar la agenda.'
                      : patient.patientFullName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                if (patient == null)
                  const _EmptyAgenda(message: 'No hay paciente activo.')
                else if (!patient.allows('AGENDA'))
                  const _EmptyAgenda(
                    message: 'Este paciente no compartió permisos de agenda.',
                  )
                else if (selectedEvents.isEmpty)
                  const _EmptyAgenda(
                    message: 'No hay eventos programados para este día.',
                  )
                else
                  for (final event in selectedEvents) ...[
                    _AgendaEventCard(
                      event: event,
                      onEdit: () => _showEventSheet(context, event: event),
                      onConfirm: event.status == 'PENDING'
                          ? () => widget.onConfirmEvent(event.id)
                          : null,
                    ),
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          ),
        ),
        if (patient != null && patient.allows('AGENDA'))
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              16,
            ),
            child: CarePrimaryButton(
              label: '+  Agregar evento',
              onPressed: () => _showEventSheet(context),
            ),
          ),
      ],
    );
  }

  void _showEventSheet(BuildContext context, {HealthEvent? event}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EventFormSheet(event: event, onSave: widget.onSaveEvent),
    );
  }

  void _changeMonth(int delta) {
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    final maxDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    final selectedDay = _selectedDate.day > maxDay ? maxDay : _selectedDate.day;
    setState(() {
      _visibleMonth = nextMonth;
      _selectedDate = DateTime(nextMonth.year, nextMonth.month, selectedDay);
    });
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.visibleMonth,
    required this.selectedDate,
    required this.events,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<HealthEvent> events;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final dates = _calendarDates(visibleMonth);
    final eventDays = {
      for (final event in events)
        if (CareDateFormatters.parse(event.startAt) case final date?)
          _dateKey(date),
    };

    return CareCard(
      borderRadius: 12,
      elevation: 1,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _monthTitle(visibleMonth),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Mes anterior',
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Mes siguiente',
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _WeekDaysRow(),
          const SizedBox(height: 12),
          for (var row = 0; row < dates.length; row += 7) ...[
            _CalendarDatesRow(
              dates: dates.sublist(row, row + 7),
              visibleMonth: visibleMonth,
              selectedDate: selectedDate,
              eventDays: eventDays,
              onDateSelected: onDateSelected,
            ),
            if (row < dates.length - 7) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _WeekDaysRow extends StatelessWidget {
  const _WeekDaysRow();

  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final day in _days)
          Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarDatesRow extends StatelessWidget {
  const _CalendarDatesRow({
    required this.dates,
    required this.visibleMonth,
    required this.selectedDate,
    required this.eventDays,
    required this.onDateSelected,
  });

  final List<DateTime> dates;
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final Set<String> eventDays;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final date in dates)
          Expanded(
            child: _CalendarDayButton(
              date: date,
              muted: date.month != visibleMonth.month,
              selected: _sameDay(date, selectedDate),
              hasEvent: eventDays.contains(_dateKey(date)),
              onTap: () => onDateSelected(date),
            ),
          ),
      ],
    );
  }
}

class _CalendarDayButton extends StatelessWidget {
  const _CalendarDayButton({
    required this.date,
    required this.muted,
    required this.selected,
    required this.hasEvent,
    required this.onTap,
  });

  final DateTime date;
  final bool muted;
  final bool selected;
  final bool hasEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? AppColors.surface
        : muted
        ? AppColors.textMuted.withAlpha(166)
        : AppColors.textPrimary;

    return SizedBox(
      height: 42,
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: Center(
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date.day.toString(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: textColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasEvent
                        ? selected
                              ? AppColors.surface
                              : AppColors.primary
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventsHeader extends StatelessWidget {
  const _EventsHeader({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _sameDay(selectedDate, DateTime.now())
                ? 'Eventos de hoy'
                : 'Eventos del día',
            style: AppTextStyles.headlineMedium,
          ),
        ),
        Text(
          _shortDate(selectedDate),
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

List<DateTime> _calendarDates(DateTime visibleMonth) {
  final firstDay = DateTime(visibleMonth.year, visibleMonth.month);
  final start = firstDay.subtract(Duration(days: firstDay.weekday - 1));
  return [
    for (var index = 0; index < 42; index++) start.add(Duration(days: index)),
  ];
}

bool _sameDay(DateTime? left, DateTime right) {
  return left != null &&
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

String _monthTitle(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.year}';
}

String _shortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  return '${_monthShortNames[date.month - 1].toUpperCase()} $day';
}

const _monthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

const _monthShortNames = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

class _AgendaEventCard extends StatelessWidget {
  const _AgendaEventCard({
    required this.event,
    required this.onConfirm,
    required this.onEdit,
  });

  final HealthEvent event;
  final VoidCallback? onConfirm;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CareIconBubble(
                icon: eventIcon(event.type),
                backgroundColor: AppColors.primaryLight,
                iconColor: AppColors.primaryDark,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      eventTypeLabel(event.type),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CareBadge(
                label: eventStatusLabel(event.status),
                backgroundColor: eventStatusBackground(event.status),
                foregroundColor: eventStatusForeground(event.status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: CareDateFormatters.date(event.startAt),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.schedule,
            text: CareDateFormatters.timeRange(event.startAt, event.endAt),
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              event.description,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (onEdit != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar evento'),
            ),
          ],
          if (onConfirm != null) ...[
            const SizedBox(height: 16),
            CarePrimaryButton(
              label: 'Confirmar evento',
              icon: Icons.check_circle_outline,
              onPressed: onConfirm,
            ),
          ],
        ],
      ),
    );
  }
}

class _EventFormSheet extends StatefulWidget {
  const _EventFormSheet({required this.event, required this.onSave});

  final HealthEvent? event;
  final Future<void> Function(HealthEventDraft draft) onSave;

  @override
  State<_EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<_EventFormSheet> {
  static const _types = [
    'MEDICATION',
    'APPOINTMENT',
    'THERAPY',
    'CARE_ACTIVITY',
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _type;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final start =
        CareDateFormatters.parse(event?.startAt) ??
        DateTime.now().add(const Duration(hours: 1));
    final end =
        CareDateFormatters.parse(event?.endAt) ??
        start.add(const Duration(hours: 1));

    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    _type = _types.contains(event?.type) ? event!.type : 'CARE_ACTIVITY';
    _date = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay.fromDateTime(start);
    _endTime = TimeOfDay.fromDateTime(end);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final editing = widget.event != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editing ? 'Editar evento' : 'Nuevo evento',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 18),
              _SheetTextField(
                controller: _titleController,
                label: 'Nombre del evento',
                hintText: 'Ej. Revisión cardiológica',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Tipo de evento'),
                items: [
                  for (final type in _types)
                    DropdownMenuItem(
                      value: type,
                      child: Text(eventTypeLabel(type)),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 14),
              _PickerButton(
                icon: Icons.calendar_today_outlined,
                label: CareDateFormatters.date(_date.toIso8601String()),
                onPressed: _saving ? null : _pickDate,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.schedule,
                      label: _startTime.format(context),
                      onPressed: _saving ? null : () => _pickTime(start: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.schedule_outlined,
                      label: _endTime.format(context),
                      onPressed: _saving ? null : () => _pickTime(start: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SheetTextField(
                controller: _descriptionController,
                label: 'Descripción',
                hintText: 'Detalles adicionales, dosis o notas importantes...',
                minLines: 3,
                maxLines: 5,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.redDark,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              CarePrimaryButton(
                label: _saving ? 'Guardando...' : 'Guardar evento',
                icon: Icons.save_outlined,
                enabled: !_saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final startAt = _combine(_date, _startTime);
    final endAt = _combine(_date, _endTime);

    if (title.isEmpty) {
      setState(() => _error = 'Ingresa el nombre del evento.');
      return;
    }
    if (!endAt.isAfter(startAt)) {
      setState(() => _error = 'La hora de fin debe ser posterior al inicio.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSave(
        HealthEventDraft(
          id: widget.event?.id,
          title: title,
          description: _descriptionController.text.trim(),
          type: _type,
          startAt: startAt,
          endAt: endAt,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _error = _errorMessage(error, 'No se pudo guardar.'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

String _errorMessage(Object error, String fallback) {
  if (error is ApiException) return error.message;
  return fallback;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.iconMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CareIconBubble(
            icon: Icons.event_busy_outlined,
            size: 58,
            iconSize: 28,
          ),
          const SizedBox(height: 14),
          Text(
            message,
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
