// lib/services/background_alert_service.dart
import 'dart:async';
import '../services/space_weather_service.dart';
import '../services/alert_database_service.dart';
import '../services/notification_service.dart';
import '../services/location_alert_filter.dart';

class BackgroundAlertService {
  static Timer? _timer;
  static bool _isRunning = false;
  static const Duration _checkInterval = Duration(minutes: 15); // Check every 15 minutes

  // Start background checking
  static Future<void> start() async {
    if (_isRunning) {
      print('🔄 Background service already running');
      return;
    }

    print('🚀 Starting background alert service...');
    _isRunning = true;

    // Initial check
    await _checkForNewAlerts();

    // Set up periodic checking
    _timer = Timer.periodic(_checkInterval, (_) async {
      await _checkForNewAlerts();
    });
  }

  // Stop background checking
  static void stop() {
    if (!_isRunning) return;

    print('🛑 Stopping background alert service...');
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  // Check for new alerts
  static Future<void> _checkForNewAlerts() async {
    try {
      print('🔍 Background check: Fetching space weather data...');
      
      final data = await SpaceWeatherService.getSpaceWeatherData();
      
      // Get stored alert IDs from database
      final storedIds = await AlertDatabaseService.getStoredAlertIds();
      
      // Find new alerts
      final currentIds = data.alerts.map((a) => a.id).toSet();
      final newAlertIds = currentIds.difference(storedIds);

      if (newAlertIds.isNotEmpty) {
        print('🔔 Background check: Found ${newAlertIds.length} new alert(s)!');
        
        // Get new alerts
        final newAlerts = data.alerts.where((a) => newAlertIds.contains(a.id)).toList();
        
        // Filter new alerts by location
        final locationFilteredNewAlerts = await LocationAlertFilter.filterAlertsByLocation(newAlerts);
        
        // Save all alerts to database (not just filtered)
        await AlertDatabaseService.saveAlerts(newAlerts);
        
        // Show notifications only for location-relevant new alerts
        if (locationFilteredNewAlerts.isNotEmpty) {
          // Get stored alerts to compare
          final storedAlerts = await AlertDatabaseService.getAllAlerts();
          final filteredStoredAlerts = await LocationAlertFilter.filterAlertsByLocation(storedAlerts);
          
          await NotificationService.checkForNewAlerts(
            locationFilteredNewAlerts,
            filteredStoredAlerts,
          );
        }
      } else {
        print('✅ Background check: No new alerts');
      }

      // Save all alerts to database (update existing ones)
      await AlertDatabaseService.saveAlerts(data.alerts);
      
      // Clean up old alerts periodically
      if (DateTime.now().hour == 2) { // Run cleanup at 2 AM
        await AlertDatabaseService.clearOldAlerts();
      }
    } catch (e) {
      print('❌ Background check error: $e');
    }
  }

  // Manual check (can be called from UI)
  static Future<void> checkNow() async {
    print('🔍 Manual check triggered...');
    await _checkForNewAlerts();
  }

  static bool get isRunning => _isRunning;
}

