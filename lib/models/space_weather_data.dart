// lib/models/space_weather_data.dart
import 'package:flutter/material.dart';

class SpaceWeatherData {
  final List<KpData> kpData;
  final List<SolarWindData> solarWind;
  final List<XRayFluxData> xRayFlux;
  final List<SpaceAlert> alerts;
  final DateTime lastUpdated;

  SpaceWeatherData({
    List<KpData>? kpData,
    List<SolarWindData>? solarWind,
    List<XRayFluxData>? xRayFlux,
    List<SpaceAlert>? alerts,
  })  : kpData = kpData ?? [],
        solarWind = solarWind ?? [],
        xRayFlux = xRayFlux ?? [],
        alerts = alerts ?? [],
        lastUpdated = DateTime.now();

  // ✅ Get current Kp (closest to current time)
  KpData? get currentKp {
    if (kpData.isEmpty) return null;

    final now = DateTime.now();
    KpData? closest;
    Duration? smallestDifference;

    for (final kp in kpData) {
      final difference = kp.timestamp.difference(now).abs();

      if (smallestDifference == null || difference < smallestDifference) {
        smallestDifference = difference;
        closest = kp;
      }
    }

    return closest;
  }

  // ✅ Get the most recent solar wind data
  SolarWindData? get currentSolarWind {
    if (solarWind.isEmpty) return null;

    SolarWindData? latest;
    for (final wind in solarWind) {
      if (latest == null || wind.timestamp.isAfter(latest.timestamp)) {
        latest = wind;
      }
    }
    return latest;
  }

  // ✅ Get the most recent X-ray flux data
  XRayFluxData? get currentXRayFlux {
    if (xRayFlux.isEmpty) return null;

    XRayFluxData? latest;
    for (final xray in xRayFlux) {
      if (latest == null || xray.timestamp.isAfter(latest.timestamp)) {
        latest = xray;
      }
    }
    return latest;
  }

  // Helper method to check if data is available
  bool get hasKpData => kpData.isNotEmpty;
  bool get hasSolarWindData => solarWind.isNotEmpty;
  bool get hasXRayData => xRayFlux.isNotEmpty;
  bool get hasAlerts => alerts.isNotEmpty;

  // Get latest alert
  SpaceAlert? get latestAlert {
    if (alerts.isEmpty) return null;

    SpaceAlert? latest;
    for (final alert in alerts) {
      if (latest == null || alert.issuedTime.isAfter(latest.issuedTime)) {
        latest = alert;
      }
    }
    return latest;
  }

  // Debug method to print current state
  void debugPrint() {
    print('=== SpaceWeatherData Debug ===');
    print('Kp Data: ${kpData.length} points');
    if (kpData.isNotEmpty) {
      print('  Current Kp: ${currentKp?.kpIndex}');
      print('  First: ${kpData.first.kpIndex} at ${kpData.first.timestamp}');
      print('  Last: ${kpData.last.kpIndex} at ${kpData.last.timestamp}');
    }
    print('Solar Wind: ${solarWind.length} points');
    if (solarWind.isNotEmpty) {
      print('  Current Speed: ${currentSolarWind?.speed} km/s');
    }
    print('X-Ray Flux: ${xRayFlux.length} points');
    if (xRayFlux.isNotEmpty) {
      print('  Current Level: ${currentXRayFlux?.level}');
    }
    print('Alerts: ${alerts.length}');
    if (alerts.isNotEmpty) {
      print('  Latest Alert: ${latestAlert?.type} - ${latestAlert?.level}');
    }
    print('Last Updated: $lastUpdated');
    print('==============================');
  }
}

class KpData {
  final double kpIndex;
  final DateTime timestamp;
  final bool isForecast;

  KpData({
    required this.kpIndex,
    required this.timestamp,
    this.isForecast = false,
  });

  @override
  String toString() => 'KpData(kp: $kpIndex, time: $timestamp, forecast: $isForecast)';
}

class SolarWindData {
  final double speed;
  final double density;
  final double temperature;
  final DateTime timestamp;

  SolarWindData({
    required this.speed,
    required this.density,
    required this.temperature,
    required this.timestamp,
  });

  @override
  String toString() => 'SolarWindData(speed: $speed km/s, time: $timestamp)';
}

class XRayFluxData {
  final double shortTerm;
  final double longTerm;
  final String level;
  final DateTime timestamp;

  XRayFluxData({
    required this.shortTerm,
    required this.longTerm,
    required this.level,
    required this.timestamp,
  });

  @override
  String toString() => 'XRayFluxData(level: $level, short: $shortTerm, time: $timestamp)';
}

class SpaceAlert {
  final String id;
  final String type;
  final String level;
  final String message;
  final DateTime issuedTime;
  final DateTime? expiresTime;
  final double? kpIndex;
  final List<GeoCoordinate> affectedAreas;

  SpaceAlert({
    required this.id,
    required this.type,
    required this.level,
    required this.message,
    required this.issuedTime,
    this.expiresTime,
    this.kpIndex,
    this.affectedAreas = const [],
  });

  // Helper to check if alert is active
  bool get isActive {
    if (expiresTime == null) return true;
    return DateTime.now().isBefore(expiresTime!);
  }

  // Get alert color based on level
  Color get color {
    switch (level.toLowerCase()) {
      case 'alert':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'watch':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  @override
  String toString() => 'SpaceAlert($type - $level - Kp: $kpIndex)';
}

class GeoCoordinate {
  final double latitude;
  final double longitude;
  final String locationName;

  GeoCoordinate({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  String toString() => 'GeoCoordinate($locationName: $latitude, $longitude)';
}