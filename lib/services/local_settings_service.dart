import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyAiApiKey = 'ai_api_key';
  static const String _keyAiProvider = 'ai_provider';
  static const String _keyAiModel = 'ai_model';
  static const String _keyAiBaseUrl = 'ai_base_url';

  static LocalSettingsService? _instance;
  SharedPreferences? _prefs;

  LocalSettingsService._();

  static LocalSettingsService get instance {
    _instance ??= LocalSettingsService._();
    return _instance!;
  }

  Future<void> init({SharedPreferences? mockPrefs}) async {
    _prefs = mockPrefs ?? await SharedPreferences.getInstance();
  }

  static const String _keyRemindersEnabled = 'reminders_enabled';
  static const String _keyBillingAlerts = 'billing_alerts_enabled';

  /// Global "Deadline reminders" switch in Settings › Reminders (§17).
  bool areRemindersEnabled() {
    return _prefs?.getBool(_keyRemindersEnabled) ?? true;
  }

  Future<bool> setRemindersEnabled(bool value) async {
    return await _prefs?.setBool(_keyRemindersEnabled, value) ?? false;
  }

  bool areBillingAlertsEnabled() {
    return _prefs?.getBool(_keyBillingAlerts) ?? true;
  }

  Future<bool> setBillingAlertsEnabled(bool value) async {
    return await _prefs?.setBool(_keyBillingAlerts, value) ?? false;
  }

  bool isOnboardingCompleted() {
    return _prefs?.getBool(_keyOnboardingCompleted) ?? false;
  }

  Future<bool> setOnboardingCompleted(bool value) async {
    return await _prefs?.setBool(_keyOnboardingCompleted, value) ?? false;
  }

  String? getAiApiKey() {
    return _prefs?.getString(_keyAiApiKey);
  }

  Future<bool> setAiApiKey(String key) async {
    return await _prefs?.setString(_keyAiApiKey, key) ?? false;
  }

  String getAiProvider() {
    return _prefs?.getString(_keyAiProvider) ?? 'gemini';
  }

  Future<bool> setAiProvider(String provider) async {
    return await _prefs?.setString(_keyAiProvider, provider) ?? false;
  }

  String? getAiModel() {
    return _prefs?.getString(_keyAiModel);
  }

  Future<bool> setAiModel(String model) async {
    return await _prefs?.setString(_keyAiModel, model) ?? false;
  }

  String? getAiBaseUrl() {
    return _prefs?.getString(_keyAiBaseUrl);
  }

  Future<bool> setAiBaseUrl(String baseUrl) async {
    return await _prefs?.setString(_keyAiBaseUrl, baseUrl) ?? false;
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
