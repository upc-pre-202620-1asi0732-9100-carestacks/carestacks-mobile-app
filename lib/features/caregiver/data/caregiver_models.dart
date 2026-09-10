class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.type,
    required this.expiresIn,
  });

  final String token;
  final String type;
  final int expiresIn;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.active,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool active;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'CareConnect',
      role: json['role']?.toString() ?? '',
      active: json['active'] == true,
    );
  }
}

class LinkedPatient {
  const LinkedPatient({
    required this.consentId,
    required this.patientId,
    required this.patientFullName,
    required this.caregiverId,
    required this.caregiverFullName,
    required this.allowedViews,
  });

  final String consentId;
  final String patientId;
  final String patientFullName;
  final String caregiverId;
  final String caregiverFullName;
  final List<String> allowedViews;

  bool allows(String view) => allowedViews.contains(view);

  factory LinkedPatient.fromJson(Map<String, dynamic> json) {
    return LinkedPatient(
      consentId: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      patientFullName: json['patientFullName']?.toString() ?? 'Paciente',
      caregiverId: json['caregiverId']?.toString() ?? '',
      caregiverFullName: json['caregiverFullName']?.toString() ?? 'Cuidador',
      allowedViews: _stringList(json['allowedViews']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': consentId,
    'patientId': patientId,
    'patientFullName': patientFullName,
    'caregiverId': caregiverId,
    'caregiverFullName': caregiverFullName,
    'allowedViews': allowedViews,
  };
}

class CaregiverInvitation {
  const CaregiverInvitation({
    required this.id,
    required this.patientId,
    required this.patientFullName,
    required this.patientEmail,
    required this.caregiverId,
    required this.caregiverFullName,
    required this.allowedViews,
    required this.status,
    this.expiresAt,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String patientFullName;
  final String patientEmail;
  final String caregiverId;
  final String caregiverFullName;
  final List<String> allowedViews;
  final String status;
  final String? expiresAt;
  final String? createdAt;

  bool get isPending => status == 'PENDING';

  factory CaregiverInvitation.fromJson(Map<String, dynamic> json) {
    return CaregiverInvitation(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      patientFullName: json['patientFullName']?.toString() ?? 'Paciente',
      patientEmail: json['patientEmail']?.toString() ?? '',
      caregiverId: json['caregiverId']?.toString() ?? '',
      caregiverFullName: json['caregiverFullName']?.toString() ?? 'Cuidador',
      allowedViews: _stringList(json['allowedViews']),
      status: json['status']?.toString() ?? 'PENDING',
      expiresAt: json['expiresAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'patientFullName': patientFullName,
    'patientEmail': patientEmail,
    'caregiverId': caregiverId,
    'caregiverFullName': caregiverFullName,
    'allowedViews': allowedViews,
    'status': status,
    'expiresAt': expiresAt,
    'createdAt': createdAt,
  };
}

class HealthEvent {
  const HealthEvent({
    required this.id,
    required this.patientId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.startAt,
    this.endAt,
  });

  final String id;
  final String patientId;
  final String title;
  final String description;
  final String type;
  final String status;
  final String? startAt;
  final String? endAt;

  factory HealthEvent.fromJson(Map<String, dynamic> json) {
    return HealthEvent(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Evento',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'CARE_ACTIVITY',
      status: json['status']?.toString() ?? 'PENDING',
      startAt: json['startAt']?.toString(),
      endAt: json['endAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'title': title,
    'description': description,
    'type': type,
    'status': status,
    'startAt': startAt,
    'endAt': endAt,
  };
}

class CareNotification {
  const CareNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.status,
    this.createdAt,
    this.sentAt,
    this.readAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final String priority;
  final String status;
  final String? createdAt;
  final String? sentAt;
  final String? readAt;

  factory CareNotification.fromJson(Map<String, dynamic> json) {
    return CareNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notificación',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'INFO',
      priority: json['priority']?.toString() ?? 'MEDIUM',
      status: json['status']?.toString() ?? 'SENT',
      createdAt: json['createdAt']?.toString(),
      sentAt: json['sentAt']?.toString(),
      readAt: json['readAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'priority': priority,
    'status': status,
    'createdAt': createdAt,
    'sentAt': sentAt,
    'readAt': readAt,
  };
}

class MedicalDocument {
  const MedicalDocument({
    required this.id,
    required this.patientId,
    required this.items,
  });

  final String id;
  final String patientId;
  final List<DocumentItem> items;

  factory MedicalDocument.fromJson(Map<String, dynamic> json) {
    return MedicalDocument(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      items: _mapList(json['documentItems'], DocumentItem.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'documentItems': items.map((item) => item.toJson()).toList(),
  };
}

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.documentType,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSizeBytes,
    this.uploadedAt,
  });

  final String id;
  final String documentType;
  final String title;
  final String description;
  final String fileUrl;
  final String mimeType;
  final int fileSizeBytes;
  final String? uploadedAt;

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? 'OTHER',
      title: json['title']?.toString() ?? 'Documento',
      description: json['description']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? '',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      uploadedAt: json['uploadedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'documentType': documentType,
    'title': title,
    'description': description,
    'fileUrl': fileUrl,
    'mimeType': mimeType,
    'fileSizeBytes': fileSizeBytes,
    'uploadedAt': uploadedAt,
  };
}

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.patientId,
    required this.content,
    this.entryDate,
  });

  final String id;
  final String patientId;
  final String content;
  final String? entryDate;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      entryDate: json['entryDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'content': content,
    'entryDate': entryDate,
  };
}

class HealthEventDraft {
  const HealthEventDraft({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startAt,
    required this.endAt,
  });

  final String? id;
  final String title;
  final String description;
  final String type;
  final DateTime startAt;
  final DateTime endAt;
}

class DiaryEntryDraft {
  const DiaryEntryDraft({this.id, required this.content});

  final String? id;
  final String content;
}

class DocumentItemDraft {
  const DocumentItemDraft({
    required this.documentType,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSizeBytes,
  });

  final String documentType;
  final String title;
  final String description;
  final String fileUrl;
  final String mimeType;
  final int fileSizeBytes;
}

class CaregiverDashboardData {
  const CaregiverDashboardData({
    required this.user,
    required this.patients,
    required this.invitations,
    required this.notifications,
    required this.events,
    required this.documents,
    required this.diaryEntries,
    this.activePatient,
  });

  final UserProfile user;
  final List<LinkedPatient> patients;
  final LinkedPatient? activePatient;
  final List<CaregiverInvitation> invitations;
  final List<CareNotification> notifications;
  final List<HealthEvent> events;
  final List<MedicalDocument> documents;
  final List<DiaryEntry> diaryEntries;

  List<DocumentItem> get documentItems =>
      documents.expand((document) => document.items).toList();
}

List<String> _stringList(Object? value) {
  if (value is List) return value.map((item) => item.toString()).toList();
  if (value is Set) return value.map((item) => item.toString()).toList();
  return const [];
}

List<T> _mapList<T>(Object? value, T Function(Map<String, dynamic>) mapper) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().map(mapper).toList();
}

List<T> mapJsonList<T>(Object? value, T Function(Map<String, dynamic>) mapper) {
  return _mapList(value, mapper);
}
