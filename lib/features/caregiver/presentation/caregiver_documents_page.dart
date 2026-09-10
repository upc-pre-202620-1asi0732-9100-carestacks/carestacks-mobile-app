import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/caregiver_models.dart';
import 'caregiver_ui_helpers.dart';

class CaregiverDocumentsPage extends StatefulWidget {
  const CaregiverDocumentsPage({
    super.key,
    required this.dashboard,
    required this.onAddDocument,
    required this.onNotificationsPressed,
    required this.onRefresh,
  });

  final CaregiverDashboardData dashboard;
  final Future<void> Function(DocumentItemDraft draft) onAddDocument;
  final VoidCallback onNotificationsPressed;
  final Future<void> Function() onRefresh;

  @override
  State<CaregiverDocumentsPage> createState() => _CaregiverDocumentsPageState();
}

class _CaregiverDocumentsPageState extends State<CaregiverDocumentsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final patient = widget.dashboard.activePatient;
    final documents = widget.dashboard.documentItems.where((item) {
      final query = _query.toLowerCase();
      return item.title.toLowerCase().contains(query) ||
          item.documentType.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Container(
          color: AppColors.backgroundSoft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CareTopBar(
            title: 'Documentos',
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Gestiona y revisa el historial médico de forma segura.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                CareSearchField(
                  hintText: 'Buscar documentos...',
                  onChanged: (value) => setState(() => _query = value),
                ),
                if (patient != null && patient.allows('DOCUMENTS')) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () => _showDocumentSheet(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.upload_file_outlined, size: 18),
                      label: Text(
                        'Subir documento',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (patient == null)
                  const _DocumentEmptyState(
                    message:
                        'Acepta una invitación para ver documentos compartidos.',
                  )
                else if (!patient.allows('DOCUMENTS'))
                  const _DocumentEmptyState(
                    message:
                        'Este paciente no compartió permisos de documentos.',
                  )
                else if (documents.isEmpty)
                  const _DocumentEmptyState(
                    message: 'No hay documentos sincronizados.',
                  )
                else ...[
                  const CareSectionTitle('RECIENTES'),
                  const SizedBox(height: 14),
                  for (final item in documents) ...[
                    CareDocumentTile(
                      icon: documentIcon(item.documentType),
                      title: item.title,
                      typeLabel: documentTypeLabel(item.documentType),
                      dateLabel: CareDateFormatters.date(item.uploadedAt),
                      onTap: () => _showDocumentDetails(context, item),
                      badgeBackgroundColor: toneBackground(
                        item.documentType == 'IMAGING' ? 'orange' : 'purple',
                      ),
                      badgeTextColor: toneForeground(
                        item.documentType == 'IMAGING' ? 'orange' : 'purple',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDocumentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DocumentFormSheet(onSave: widget.onAddDocument),
    );
  }

  void _showDocumentDetails(BuildContext context, DocumentItem item) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text(
                documentTypeLabel(item.documentType),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(item.description, style: AppTextStyles.bodyLarge),
              ],
              const SizedBox(height: 14),
              Text(
                'Archivo: ${item.fileUrl.isEmpty ? 'Sin URL' : item.fileUrl}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${item.mimeType.isEmpty ? 'Tipo desconocido' : item.mimeType} · ${_formatBytes(item.fileSizeBytes)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentFormSheet extends StatefulWidget {
  const _DocumentFormSheet({required this.onSave});

  final Future<void> Function(DocumentItemDraft draft) onSave;

  @override
  State<_DocumentFormSheet> createState() => _DocumentFormSheetState();
}

class _DocumentFormSheetState extends State<_DocumentFormSheet> {
  static const _documentTypes = [
    'PRESCRIPTION',
    'LAB_RESULT',
    'CLINICAL_REPORT',
    'IMAGING',
    'REFERRAL',
    'VACCINATION_RECORD',
    'INSURANCE_FORM',
    'OTHER',
  ];
  static const _mimeTypes = ['application/pdf', 'image/jpeg', 'image/png'];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUrlController = TextEditingController();
  final _fileSizeController = TextEditingController(text: '1024');
  String _documentType = 'OTHER';
  String _mimeType = 'application/pdf';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    _fileSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar documento', style: AppTextStyles.titleLarge),
              const SizedBox(height: 18),
              _SheetTextField(
                controller: _titleController,
                label: 'Nombre',
                hintText: 'Ej. Resultados cardiólogo',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _documentType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: [
                  for (final type in _documentTypes)
                    DropdownMenuItem(
                      value: type,
                      child: Text(documentTypeLabel(type)),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(
                        () => _documentType = value ?? _documentType,
                      ),
              ),
              const SizedBox(height: 14),
              _SheetTextField(
                controller: _fileUrlController,
                label: 'URL del archivo',
                hintText: 'https://...',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _mimeType,
                decoration: const InputDecoration(labelText: 'Tipo de archivo'),
                items: [
                  for (final type in _mimeTypes)
                    DropdownMenuItem(value: type, child: Text(type)),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _mimeType = value ?? _mimeType),
              ),
              const SizedBox(height: 14),
              _SheetTextField(
                controller: _fileSizeController,
                label: 'Tamaño en bytes',
                hintText: 'Ej. 204800',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _SheetTextField(
                controller: _descriptionController,
                label: 'Descripción',
                hintText: 'Detalle breve del documento',
                minLines: 2,
                maxLines: 4,
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
                label: _saving ? 'Guardando...' : 'Guardar documento',
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
    final title = _titleController.text.trim();
    final fileUrl = _fileUrlController.text.trim();
    final fileSize = int.tryParse(_fileSizeController.text.trim()) ?? 0;

    if (title.isEmpty) {
      setState(() => _error = 'Ingresa el nombre del documento.');
      return;
    }
    if (Uri.tryParse(fileUrl)?.hasScheme != true) {
      setState(() => _error = 'Ingresa una URL válida del archivo.');
      return;
    }
    if (fileSize <= 0 || fileSize > 10 * 1024 * 1024) {
      setState(() => _error = 'El tamaño debe estar entre 1 byte y 10 MB.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSave(
        DocumentItemDraft(
          documentType: _documentType,
          title: title,
          description: _descriptionController.text.trim(),
          fileUrl: fileUrl,
          mimeType: _mimeType,
          fileSizeBytes: fileSize,
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
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return 'Tamaño desconocido';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _errorMessage(Object error, String fallback) {
  if (error is ApiException) return error.message;
  return fallback;
}

class _DocumentEmptyState extends StatelessWidget {
  const _DocumentEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CareIconBubble(
            icon: Icons.folder_off_outlined,
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
