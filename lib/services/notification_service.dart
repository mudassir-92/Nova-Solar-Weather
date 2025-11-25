// lib/services/notification_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../models/space_weather_data.dart';

class NotificationService {
  static bool _isInitialized = false;
  static FlutterLocalNotificationsPlugin? _notifications;
  static final Set<String> _shownAlerts = {};

  static Future<void> initialize() async {
    print('🔔 Initializing Notification Service...');

    if (kIsWeb) {
      print('🌐 Web platform - Notifications not supported');
      _isInitialized = true;
      return;
    }

    // Check if we're on mobile
    final isMobile = Platform.isAndroid || Platform.isIOS;

    if (isMobile) {
      await _initializeMobileNotifications();
    } else {
      print('💻 Desktop platform - Notifications not fully supported');
      _isInitialized = true;
    }
  }

  static Future<void> _initializeMobileNotifications() async {
    try {
      _notifications = FlutterLocalNotificationsPlugin();

      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Request permissions (Android 13+)
      if (Platform.isAndroid) {
        final bool? granted = await _notifications!
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        
        if (granted == true) {
          print('✅ Android notification permission granted');
        } else {
          print('⚠️ Android notification permission denied');
        }
      }

      // Initialize the plugin
      final bool? initialized = await _notifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _isInitialized = true;
        print('✅ Mobile notifications initialized successfully');
      } else {
        print('❌ Failed to initialize notifications');
        _isInitialized = false;
      }
    } catch (e) {
      print('❌ Mobile notifications initialization error: $e');
      _isInitialized = false;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    // You can handle navigation here if needed
  }

  static Future<void> showSpaceWeatherAlert({
    required String alertType,
    required String level,
    required String message,
    double? kpIndex,
    List<String> affectedAreas = const [],
    int? notificationId,
  }) async {
    final title = _generateAlertTitle(alertType, level, kpIndex);
    final body = _generateAlertBody(message, affectedAreas);

    // Always show in console for debugging
    _showConsoleNotification(title, body);

    if (!_isInitialized || _notifications == null) {
      print('⚠️ Notifications not initialized, showing console only');
      return;
    }

    // Create notification details
    final androidDetails = AndroidNotificationDetails(
      'space_weather_alerts',
      'Space Weather Alerts',
      channelDescription: 'Notifications for space weather alerts and warnings',
      importance: _getImportance(level),
      priority: _getPriority(level),
      icon: '@mipmap/ic_launcher',
      color: _getAlertColor(level),
      styleInformation: BigTextStyleInformation(body),
      enableVibration: true,
      playSound: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate unique notification ID if not provided
    final id = notificationId ?? (DateTime.now().millisecondsSinceEpoch % 2147483647);

    try {
      await _notifications!.show(id, title, body, notificationDetails);
      print('✅ Notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  static Importance _getImportance(String level) {
    switch (level.toLowerCase()) {
      case 'alert':
        return Importance.high;
      case 'warning':
        return Importance.high;
      case 'watch':
        return Importance.defaultImportance;
      default:
        return Importance.low;
    }
  }

  static Priority _getPriority(String level) {
    switch (level.toLowerCase()) {
      case 'alert':
        return Priority.high;
      case 'warning':
        return Priority.high;
      case 'watch':
        return Priority.defaultPriority;
      default:
        return Priority.low;
    }
  }

  static Color _getAlertColor(String level) {
    switch (level.toLowerCase()) {
      case 'alert':
        return const Color(0xFFFF0000); // Red
      case 'warning':
        return const Color(0xFFFFA500); // Orange
      case 'watch':
        return const Color(0xFFFFFF00); // Yellow
      default:
        return const Color(0xFF00FF00); // Green
    }
  }

  static String _generateAlertTitle(String alertType, String level, double? kpIndex) {
    final emoji = _getAlertEmoji(level);
    final kpText = kpIndex != null ? ' (Kp $kpIndex)' : '';

    return '$emoji $level: $alertType$kpText';
  }

  static String _generateAlertBody(String message, List<String> affectedAreas) {
    // Clean up the message - remove extra whitespace and format
    String cleanMessage = message
        .replaceAll('\r\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Extract the key information
    String shortMessage = cleanMessage.length > 150
        ? '${cleanMessage.substring(0, 150)}...'
        : cleanMessage;

    if (affectedAreas.isEmpty) {
      return shortMessage;
    }

    final areas = affectedAreas.take(3).join(', ');
    final extra = affectedAreas.length > 3 ? ' +${affectedAreas.length - 3} more' : '';

    return '$shortMessage\n📍 Affected: $areas$extra';
  }

  static String _getAlertEmoji(String level) {
    switch (level.toLowerCase()) {
      case 'alert':
        return '🚨';
      case 'warning':
        return '⚠️';
      case 'watch':
        return '👀';
      default:
        return 'ℹ️';
    }
  }

  static void _showConsoleNotification(String title, String body) {
    print('''
    
    🔔 SPACE WEATHER NOTIFICATION
    =============================
    $title
    $body
    =============================
    
    ''');
  }

  // Check for new alerts and show notifications
  static Future<void> checkForNewAlerts(
    List<SpaceAlert> currentAlerts,
    List<SpaceAlert> previousAlerts,
  ) async {
    if (currentAlerts.isEmpty) return;

    // Get IDs of current and previous alerts
    final currentIds = currentAlerts.map((alert) => alert.id).toSet();
    final previousIds = previousAlerts.map((alert) => alert.id).toSet();

    // Find new alerts
    final newAlertIds = currentIds.difference(previousIds);

    if (newAlertIds.isEmpty) {
      print('📋 No new alerts detected');
      return;
    }

    print('🔔 Found ${newAlertIds.length} new alert(s)');

    // Show notifications for new alerts
    for (final alertId in newAlertIds) {
      // Avoid showing duplicate notifications
      if (_shownAlerts.contains(alertId)) {
        print('⏭️ Skipping already shown alert: $alertId');
        continue;
      }

      final alert = currentAlerts.firstWhere((a) => a.id == alertId);
      await _showAlertNotification(alert);
      _shownAlerts.add(alertId);
    }

    // Clean up old alerts (keep last 100 to prevent memory issues)
    if (_shownAlerts.length > 100) {
      _shownAlerts.clear();
      print('🧹 Cleared old alert cache');
    }
  }

  static Future<void> _showAlertNotification(SpaceAlert alert) async {
    print('📢 Showing notification for alert: ${alert.id}');

    // Extract affected areas as strings
    final affectedAreas = alert.affectedAreas
        .map((area) => area.locationName)
        .toList();

    await showSpaceWeatherAlert(
      alertType: alert.type,
      level: alert.level,
      message: alert.message,
      kpIndex: alert.kpIndex,
      affectedAreas: affectedAreas,
      notificationId: alert.id.hashCode,
    );
  }

  // Manual notification methods for testing
  static Future<void> testGeomagneticAlert() async {
    await showSpaceWeatherAlert(
      alertType: 'Geomagnetic Storm',
      level: 'Alert',
      message: 'G2 level geomagnetic storm detected. Aurora may be visible at lower latitudes.',
      kpIndex: 6.0,
      affectedAreas: ['New York', 'Washington', 'Canada'],
      notificationId: 9999,
    );
  }

  static Future<void> testSolarFlareAlert() async {
    await showSpaceWeatherAlert(
      alertType: 'Solar Radiation',
      level: 'Warning',
      message: 'M-class solar flare detected. Potential radio blackouts expected.',
      kpIndex: null,
      affectedAreas: ['Polar regions'],
      notificationId: 9998,
    );
  }

  static Future<void> testRadioBlackout() async {
    await showSpaceWeatherAlert(
      alertType: 'Radio Blackout',
      level: 'Watch',
      message: 'Potential radio blackout conditions expected in the next 24 hours.',
      kpIndex: null,
      affectedAreas: ['Global'],
      notificationId: 9997,
    );
  }
}
