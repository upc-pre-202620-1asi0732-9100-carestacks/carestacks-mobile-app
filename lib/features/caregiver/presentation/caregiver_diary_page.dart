import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/caregiver_models.dart';

class CaregiverDiaryPage extends StatelessWidget {
  const CaregiverDiaryPage({
    super.key,
    required this.dashboard,
    required this.onSaveEntry,
    required this.onNotificationsPressed,
    required this.onRefresh,
  });

  final CaregiverDashboardData dashboard;
  final Future<void> Function(DiaryEntryDraft draft) onSaveEntry;
  final VoidCallback onNotificationsPressed;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final patient = dashboard.activePatient;
    final entries = dashboard.diaryEntries;

    return Column(
      children: [
        Container(
          color: AppColors.backgroundSoft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CareTopBar(
            title: 'Diario',
            onNotificationsPressed: onNotificationsPressed,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                24,
                AppSpacing.screenPadding,
                28,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Registro del bienestar diario',
                        style: AppTextStyles.headlineMedium,
                      ),
                    ),
                    if (patient != null && patient.allows('DIARY'))
                      SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () => _showDiarySheet(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(
                            'Nueva\nnota',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  patient?.patientFullName ?? 'Sin paciente activo',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (patient == null)
                  const _DiaryEmptyState(
                    message: 'Acepta una invitación para revisar el diario.',
                  )
                else if (!patient.allows('DIARY'))
                  const _DiaryEmptyState(
                    message: 'Este paciente no compartió permisos de diario.',
                  )
                else if (entries.isEmpty)
                  const _DiaryEmptyState(
                    message: 'Todavía no hay notas en el diario compartido.',
                  )
                else
                  for (final entry in entries) ...[
                    CareNoteCard(
                      author: patient.patientFullName,
                      timestamp: CareDateFormatters.dateTime(entry.entryDate),
                      body: entry.content,
                      showMoreButton: true,
                      onMorePressed: () =>
                          _showDiarySheet(context, entry: entry),
                      badges: const [
                        CareBadge(
                          label: 'Nota diaria',
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.primaryDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDiarySheet(BuildContext context, {DiaryEntry? entry}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DiaryFormSheet(entry: entry, onSave: onSaveEntry),
    );
  }
}

class _DiaryFormSheet extends StatefulWidget {
  const _DiaryFormSheet({required this.entry, required this.onSave});

  final DiaryEntry? entry;
  final Future<void> Function(DiaryEntryDraft draft) onSave;

  @override
  State<_DiaryFormSheet> createState() => _DiaryFormSheetState();
}

class _DiaryFormSheetState extends State<_DiaryFormSheet> {
  late final TextEditingController _contentController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final editing = widget.entry != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editing ? 'Editar nota' : 'Nueva nota',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _contentController,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  hintText: 'Escribe una nota del cuidado diario...',
                  alignLabelWithHint: true,
                ),
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
                label: _saving ? 'Guardando...' : 'Guardar nota',
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

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      setState(() => _error = 'Escribe el contenido de la nota.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSave(
        DiaryEntryDraft(id: widget.entry?.id, content: content),
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
}

String _errorMessage(Object error, String fallback) {
  if (error is ApiException) return error.message;
  return fallback;
}

class _DiaryEmptyState extends StatelessWidget {
  const _DiaryEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CareIconBubble(
            icon: Icons.edit_note_outlined,
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
