// lib/services/location_alert_filter.dart
import 'dart:math' as math;
import '../models/space_weather_data.dart';
import 'settings_service.dart';
import 'aurora_service.dart';

class LocationAlertFilter {
  // Filter alerts based on user's location
  static Future<List<SpaceAlert>> filterAlertsByLocation(List<SpaceAlert> alerts) async {
    final userLat = await SettingsService.getLocationLatitude();
    final userLon = await SettingsService.getLocationLongitude();

    // If no location is set, return all alerts
    if (userLat == null || userLon == null) {
      return alerts;
    }

    final filteredAlerts = <SpaceAlert>[];

    for (final alert in alerts) {
      // Check if alert affects user's location
      if (_isAlertRelevantToLocation(alert, userLat, userLon)) {
        filteredAlerts.add(alert);
      }
    }

    return filteredAlerts;
  }

  // Check if alert is relevant to user's location
  static bool _isAlertRelevantToLocation(SpaceAlert alert, double userLat, double userLon) {
    // If alert has specific affected areas, check if user's location is in them
    if (alert.affectedAreas.isNotEmpty) {
      for (final area in alert.affectedAreas) {
        // Check if user is within reasonable distance of affected area
        final distance = _calculateDistance(userLat, userLon, area.latitude, area.longitude);
        // If within 1000 km, consider it relevant
        if (distance < 1000) {
          return true;
        }
      }
    }

    // For geomagnetic alerts, check based on latitude
    if (alert.type.contains('Geomagnetic') || alert.type.contains('geomagnetic')) {
      // Geomagnetic storms affect higher latitudes more
      // If user is at high latitude (>50°), show all geomagnetic alerts
      if (userLat.abs() > 50) {
        return true;
      }
      // For lower latitudes, only show if Kp is high (5+)
      if (alert.kpIndex != null && alert.kpIndex! >= 5.0) {
        return true;
      }
    }

    // For global alerts (solar radiation, radio blackout), always show
    if (alert.type.contains('Solar Radiation') || 
        alert.type.contains('Radio Blackout') ||
        alert.type.contains('X-Ray')) {
      return true;
    }

    // Check message for location keywords
    final message = alert.message.toLowerCase();
    final locationKeywords = [
      'global',
      'worldwide',
      'earth',
      'all latitudes',
      'high latitudes',
      'polar',
    ];

    for (final keyword in locationKeywords) {
      if (message.contains(keyword)) {
        // Check if it's relevant based on latitude
        if (keyword == 'high latitudes' || keyword == 'polar') {
          if (userLat.abs() > 50) {
            return true;
          }
        } else {
          return true; // Global alerts
        }
      }
    }

    // Check for specific location mentions in message
    final commonLocations = {
      'canada': 60.0,
      'alaska': 64.0,
      'northern': 55.0,
      'southern': -55.0,
      'arctic': 70.0,
      'antarctic': -70.0,
    };

    for (final entry in commonLocations.entries) {
      if (message.contains(entry.key)) {
        final thresholdLat = entry.value;
        if (entry.value > 0 && userLat > thresholdLat - 10) {
          return true;
        } else if (entry.value < 0 && userLat < thresholdLat + 10) {
          return true;
        }
      }
    }

    // Default: show alert if Kp is high enough to affect user's latitude
    if (alert.kpIndex != null) {
      final geomagneticLat = AuroraService.calculateGeomagneticLatitude(userLat, userLon);
      // Higher Kp means aurora/effects visible at lower latitudes
      final minKpForLatitude = _getMinKpForLatitude(geomagneticLat.abs());
      return alert.kpIndex! >= minKpForLatitude;
    }

    // If no specific criteria match, show the alert (better safe than sorry)
    return true;
  }

  // Calculate distance between two coordinates (Haversine formula)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Get minimum Kp index needed for effects at given latitude
  static double _getMinKpForLatitude(double latitude) {
    if (latitude >= 70) return 2.0; // Very high latitude
    if (latitude >= 65) return 3.0; // High latitude
    if (latitude >= 60) return 4.0; // Moderate-high latitude
    if (latitude >= 55) return 5.0; // Moderate latitude
    if (latitude >= 50) return 6.0; // Lower-moderate latitude
    return 7.0; // Low latitude (needs strong storm)
  }
}

