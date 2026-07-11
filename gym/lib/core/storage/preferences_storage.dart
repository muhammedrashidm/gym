import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class PreferencesStorage {
  final SharedPreferences _prefs;

  const PreferencesStorage(this._prefs);

  static const _onboardedKey = 'is_onboarded';
  static const _activeRoleIdKey = 'active_role_id';

  // ── Onboarding ────────────────────────────────────────────────

  bool get isOnboarded => _prefs.getBool(_onboardedKey) ?? false;
  Future<void> setOnboarded(bool value) => _prefs.setBool(_onboardedKey, value);

  // ── Active Role ───────────────────────────────────────────────

  /// The [UserRole.roleId] that the user last explicitly selected.
  /// Null if no explicit selection has been made (fall back to JWT default).
  int? get activeRoleId => _prefs.getInt(_activeRoleIdKey);

  Future<void> setActiveRoleId(int roleId) =>
      _prefs.setInt(_activeRoleIdKey, roleId);

  Future<void> clearActiveRoleId() => _prefs.remove(_activeRoleIdKey);
}
