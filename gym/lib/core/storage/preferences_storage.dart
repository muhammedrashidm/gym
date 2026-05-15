import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class PreferencesStorage {
  final SharedPreferences _prefs;

  const PreferencesStorage(this._prefs);

  static const _onboardedKey = 'is_onboarded';

  bool get isOnboarded => _prefs.getBool(_onboardedKey) ?? false;
  Future<void> setOnboarded(bool value) => _prefs.setBool(_onboardedKey, value);
}
