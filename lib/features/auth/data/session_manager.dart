import 'package:shared_preferences/shared_preferences.dart';

import '../../caregiver/data/caregiver_models.dart';

class SessionManager {
  SessionManager(this._preferences);

  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _userFullNameKey = 'user_full_name';
  static const String _userRoleKey = 'user_role';
  static const String _activePatientIdKey = 'active_patient_id';

  final SharedPreferences _preferences;

  String? get token => _preferences.getString(_tokenKey);
  String? get userId => _preferences.getString(_userIdKey);
  String? get userFullName => _preferences.getString(_userFullNameKey);
  String? get userRole => _preferences.getString(_userRoleKey);
  String? get activePatientId => _preferences.getString(_activePatientIdKey);
  bool get hasCaregiverSession => token != null && userRole == 'CAREGIVER';

  Future<void> saveSession({
    required String token,
    required UserProfile user,
  }) async {
    await _preferences.setString(_tokenKey, token);
    await _preferences.setString(_userIdKey, user.id);
    await _preferences.setString(_userFullNameKey, user.fullName);
    await _preferences.setString(_userRoleKey, user.role);
    if (user.role == 'PATIENT') {
      await _preferences.setString(_activePatientIdKey, user.id);
    }
  }

  Future<void> saveActivePatientId(String patientId) {
    return _preferences.setString(_activePatientIdKey, patientId);
  }

  Future<void> clearActivePatientId() {
    return _preferences.remove(_activePatientIdKey);
  }

  Future<void> clear() async {
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userFullNameKey);
    await _preferences.remove(_userRoleKey);
    await _preferences.remove(_activePatientIdKey);
  }
}
