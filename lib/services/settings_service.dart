// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyNotificationSound = 'notification_sound';
  static const String _keyNotificationVibration = 'notification_vibration';
  static const String _keyKpThreshold = 'kp_threshold';
  static const String _keyUpdateFrequency = 'update_frequency';
  static const String _keyTheme = 'theme';
  static const String _keyLocationLatitude = 'location_latitude';
  static const String _keyLocationLongitude = 'location_longitude';
  static const String _keyLocationName = 'location_name';
  static const String _keyLocationRequested = 'location_requested';
  static const String _keyAuroraAlertsEnabled = 'aurora_alerts_enabled';

  // Notification Settings
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
  }

  static Future<bool> getNotificationSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationSound) ?? true;
  }

  static Future<void> setNotificationSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationSound, value);
  }

  static Future<bool> getNotificationVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationVibration) ?? true;
  }

  static Future<void> setNotificationVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationVibration, value);
  }

  // Kp Threshold
  static Future<double> getKpThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyKpThreshold) ?? 5.0;
  }

  static Future<void> setKpThreshold(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyKpThreshold, value);
  }

  // Update Frequency (in minutes)
  static Future<int> getUpdateFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUpdateFrequency) ?? 15;
  }

  static Future<void> setUpdateFrequency(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUpdateFrequency, minutes);
  }

  // Theme
  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme) ?? 'dark';
  }

  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, theme);
  }

  // Location
  static Future<double?> getLocationLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyLocationLatitude);
  }

  static Future<double?> getLocationLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyLocationLongitude);
  }

  static Future<String?> getLocationName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocationName);
  }

  static Future<void> setLocation(double latitude, double longitude, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLocationLatitude, latitude);
    await prefs.setDouble(_keyLocationLongitude, longitude);
    await prefs.setString(_keyLocationName, name);
  }

  // Check if location was requested before
  static Future<bool> hasLocationBeenRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLocationRequested) ?? false;
  }

  static Future<void> setLocationRequested(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLocationRequested, value);
  }

  // Aurora Alerts
  static Future<bool> getAuroraAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAuroraAlertsEnabled) ?? false;
  }

  static Future<void> setAuroraAlertsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAuroraAlertsEnabled, value);
  }
}








