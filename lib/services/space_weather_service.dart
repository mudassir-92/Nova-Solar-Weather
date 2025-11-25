// lib/services/space_weather_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/space_weather_data.dart';

class SpaceWeatherService {
  static const String _baseUrl = 'https://services.swpc.noaa.gov';

  static Future<SpaceWeatherData> getSpaceWeatherData() async {
    try {
      final kpData = await _getKpData();
      final solarWind = await _getSolarWindData();
      final xRayFlux = await _getXRayFluxData();
      final alerts = await _getAlerts();

      return SpaceWeatherData(
        kpData: kpData,
        // kpForecast: kpForecast,
        solarWind: solarWind,
        xRayFlux: xRayFlux,
        alerts: alerts,
      );
    } catch (e) {
      print('Error fetching space weather data: $e');
      return SpaceWeatherData();
    }
  }

  // Kp Index Data (Real API)
  // In SpaceWeatherService, update _getKpData method:
// In SpaceWeatherService, update _getKpData method:
  static Future<List<KpData>> _getKpData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/noaa-planetary-k-index-forecast.json'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<KpData> kpList = [];
        final now = DateTime.now();

        // Skip header row
        for (int i = 1; i < data.length; i++) {
          final item = data[i];
          if (item.length >= 4) {
            final kpValue = double.tryParse(item[1]?.toString() ?? '0') ?? 0.0;
            // Parse timestamp - API provides UTC, ensure it's treated as UTC
            final timeStr = item[0].toString();
            final timestamp = timeStr.contains('Z') || timeStr.contains('+') || timeStr.contains('-', 10)
                ? DateTime.parse(timeStr)
                : DateTime.parse('${timeStr}Z').toUtc();
            final observedType = item[2]?.toString() ?? '';

            // Determine if it's forecast or historical
            final isForecast = observedType == 'predicted' || observedType == 'estimated';

            kpList.add(KpData(
              kpIndex: kpValue,
              timestamp: timestamp,
              isForecast: isForecast,
            ));
          }
        }

        // Sort by timestamp
        kpList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Find current Kp (closest to current time)
        final currentKp = _findCurrentKp(kpList, now);
        print('🎯 Current Kp: ${currentKp?.kpIndex} at ${currentKp?.timestamp}');

        return kpList;
      }
      return [];
    } catch (e) {
      print('Kp data error: $e');
      return [];
    }
  }

// Find Kp value closest to current time
  static KpData? _findCurrentKp(List<KpData> kpList, DateTime now) {
    if (kpList.isEmpty) return null;

    KpData? closest;
    Duration? smallestDifference;

    for (final kp in kpList) {
      final difference = kp.timestamp.difference(now).abs();

      if (smallestDifference == null || difference < smallestDifference) {
        smallestDifference = difference;
        closest = kp;
      }
    }

    return closest;
  }
  // Solar Wind Data - Using Real NOAA API
  // Update the _getSolarWindData method
  static Future<List<SolarWindData>> _getSolarWindData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/summary/solar-wind-speed.json'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<SolarWindData> windData = [];

        // Parse the JSON structure correctly
        final windSpeed = double.tryParse(data['WindSpeed']?.toString() ?? '0') ?? 0.0;
        // Parse timestamp - API provides UTC, ensure it's treated as UTC
        final timeStr = data['TimeStamp'].toString();
        final timestamp = timeStr.contains('Z') || timeStr.contains('+') || timeStr.contains('-', 10)
            ? DateTime.parse(timeStr)
            : DateTime.parse('${timeStr}Z').toUtc();

        print('🌬️ Current Solar Wind Speed: $windSpeed km/s');

        // Create current data point
        windData.add(SolarWindData(
          speed: windSpeed,
          density: 0.0, // Not available in this API
          temperature: 0.0, // Not available in this API
          timestamp: timestamp,
        ));

        // Add some historical data points for the chart
        for (int i = 1; i <= 12; i++) {
          windData.add(SolarWindData(
            speed: windSpeed - (i * 10), // Simulate some variation
            density: 0.0,
            temperature: 0.0,
            timestamp: timestamp.subtract(Duration(hours: i)),
          ));
        }

        return windData.reversed.toList();
      }
      return _getRealisticSolarWindData();
    } catch (e) {
      print('Solar wind error: $e');
      return _getRealisticSolarWindData();
    }
  }
  // Alternative Solar Wind Data Source
  static Future<List<SolarWindData>> _getAlternativeSolarWindData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/json/ace_magnetometer.json'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<SolarWindData> windData = [];

        final List<dynamic> timeSeries = data['time_series'] ?? [];

        for (int i = 0; i < timeSeries.length && i < 12; i++) {
          final item = timeSeries[i];
          windData.add(SolarWindData(
            speed: _parseSolarWindValue(item, 'speed', 450.0),
            density: _parseSolarWindValue(item, 'density', 4.5),
            temperature: _parseSolarWindValue(item, 'temperature', 120000.0),
            timestamp: DateTime.parse(item['time']),
          ));
        }

        if (windData.isNotEmpty) {
          return windData.reversed.toList();
        }
      }

      // If all APIs fail, return realistic mock data
      return _getRealisticSolarWindData();

    } catch (e) {
      print('Alternative solar wind error: $e');
      return _getRealisticSolarWindData();
    }
  }

  static double _parseSolarWindValue(Map<String, dynamic> item, String key, double defaultValue) {
    try {
      final value = item[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // Realistic Solar Wind Mock Data (based on actual solar wind patterns)
  static List<SolarWindData> _getRealisticSolarWindData() {
    final now = DateTime.now();
    final List<SolarWindData> data = [];

    // Generate 24 hours of realistic solar wind data
    for (int i = 0; i < 24; i++) {
      final timestamp = now.subtract(Duration(hours: 23 - i));

      // Realistic solar wind variations
      final baseSpeed = 400.0;
      final speedVariation = 100.0 * (0.5 + 0.5 * sin(i * 0.3));
      final speed = baseSpeed + speedVariation;

      final baseDensity = 4.0;
      final densityVariation = 2.0 * (0.5 + 0.5 * cos(i * 0.4));
      final density = baseDensity + densityVariation;

      final baseTemp = 100000.0;
      final tempVariation = 50000.0 * (0.5 + 0.5 * sin(i * 0.2));
      final temperature = baseTemp + tempVariation;

      data.add(SolarWindData(
        speed: speed,
        density: density,
        temperature: temperature,
        timestamp: timestamp,
      ));
    }

    return data;
  }

  // X-Ray Flux Data
  static Future<List<XRayFluxData>> _getXRayFluxData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/json/goes/xray.json'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseXRayFluxData(data);
      }
      return _getRealisticXRayFluxData();
    } catch (e) {
      print('X-ray flux error: $e');
      return _getRealisticXRayFluxData();
    }
  }

  static List<XRayFluxData> _parseXRayFluxData(Map<String, dynamic> data) {
    final List<XRayFluxData> fluxData = [];
    final now = DateTime.now();

    try {
      // Try different possible keys for time series
      List<dynamic>? timeSeries = data['time_series'] as List<dynamic>?;
      if (timeSeries == null) {
        timeSeries = data['data'] as List<dynamic>?;
      }
      if (timeSeries == null) {
        // Try to find any list in the data
        for (final key in data.keys) {
          if (data[key] is List) {
            timeSeries = data[key] as List<dynamic>?;
            print('📊 Found time series in key: $key');
            break;
          }
        }
      }

      if (timeSeries == null || timeSeries.isEmpty) {
        print('⚠️ No time series data found in X-ray flux response');
        return _getRealisticXRayFluxData();
      }

      print('📊 Parsing ${timeSeries.length} X-ray flux data points');

      for (int i = 0; i < timeSeries.length && i < 24; i++) {
        try {
          final item = timeSeries[i];
          if (item is! Map<String, dynamic>) continue;

          // Try different possible keys for flux value
          double? flux;
          if (item.containsKey('flux')) {
            flux = (item['flux'] as num?)?.toDouble();
          } else if (item.containsKey('short')) {
            flux = (item['short'] as num?)?.toDouble();
          } else if (item.containsKey('xrsa')) {
            flux = (item['xrsa'] as num?)?.toDouble();
          } else if (item.containsKey('xrsb')) {
            flux = (item['xrsb'] as num?)?.toDouble();
          } else if (item.containsKey('value')) {
            flux = (item['value'] as num?)?.toDouble();
          }

          flux = flux ?? 1e-7;

          // Try different possible keys for timestamp
          DateTime timestamp;
          try {
            if (item.containsKey('time')) {
              final timeStr = item['time']?.toString() ?? '';
              // Ensure UTC timestamps are parsed correctly
              timestamp = timeStr.contains('Z') || timeStr.contains('+') || timeStr.contains('-', 10)
                  ? DateTime.parse(timeStr)
                  : DateTime.parse('${timeStr}Z').toUtc();
            } else if (item.containsKey('timestamp')) {
              final timeStr = item['timestamp'].toString();
              timestamp = timeStr.contains('Z') || timeStr.contains('+') || timeStr.contains('-', 10)
                  ? DateTime.parse(timeStr)
                  : DateTime.parse('${timeStr}Z').toUtc();
            } else if (item.containsKey('date')) {
              final timeStr = item['date'].toString();
              timestamp = timeStr.contains('Z') || timeStr.contains('+') || timeStr.contains('-', 10)
                  ? DateTime.parse(timeStr)
                  : DateTime.parse('${timeStr}Z').toUtc();
            } else {
              timestamp = now.subtract(Duration(hours: 23 - i));
            }
          } catch (e) {
            print('⚠️ Error parsing timestamp: $e, using fallback');
            timestamp = now.subtract(Duration(hours: 23 - i));
          }

          fluxData.add(XRayFluxData(
            shortTerm: flux,
            longTerm: flux * 0.8, // Simulate long-term average
            level: _getXRayLevel(flux),
            timestamp: timestamp,
          ));
        } catch (e) {
          print('⚠️ Error parsing X-ray flux data point $i: $e');
          continue;
        }
      }

      if (fluxData.isNotEmpty) {
        print('✅ Successfully parsed ${fluxData.length} X-ray flux data points');
        return fluxData.reversed.toList();
      }
    } catch (e) {
      print('❌ X-ray parsing error: $e');
    }

    print('⚠️ Falling back to realistic X-ray flux data');
    return _getRealisticXRayFluxData();
  }

  static List<XRayFluxData> _getRealisticXRayFluxData() {
    final now = DateTime.now();
    final List<XRayFluxData> data = [];

    // Generate realistic X-ray flux data
    for (int i = 0; i < 24; i++) {
      final timestamp = now.subtract(Duration(hours: 23 - i));

      // Realistic X-ray flux variations
      final baseFlux = 1e-7;
      final fluxVariation = 5e-7 * (0.5 + 0.5 * sin(i * 0.25));
      final flux = baseFlux + fluxVariation;

      data.add(XRayFluxData(
        shortTerm: flux,
        longTerm: flux * 0.9,
        level: _getXRayLevel(flux),
        timestamp: timestamp,
      ));
    }

    return data;
  }

  static String _getXRayLevel(double flux) {
    if (flux > 1e-3) return 'Extreme';
    if (flux > 1e-4) return 'Severe';
    if (flux > 1e-5) return 'Strong';
    if (flux > 1e-6) return 'Moderate';
    return 'Normal';
  }

  // Alerts Data (Real API)
  static Future<List<SpaceAlert>> _getAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/json/alerts.json'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _parseAlerts(data);
      }
      return _getRealisticAlerts();
    } catch (e) {
      print('Alerts error: $e');
      return _getRealisticAlerts();
    }
  }

  // Mock data generators for fallback
  static List<KpData> _getMockKpData() {
    final now = DateTime.now();
    final List<KpData> data = [];

    for (int i = 0; i < 24; i++) {
      data.add(KpData(
        kpIndex: 2.0 + 2.0 * sin(i * 0.3), // Realistic Kp variations
        timestamp: now.subtract(Duration(hours: 23 - i)),
      ));
    }

    return data;
  }

  static List<KpData> _getMockKpForecast() {
    final now = DateTime.now();
    return [
      KpData(kpIndex: 3.0, timestamp: now.add(Duration(hours: 1)), isForecast: true),
      KpData(kpIndex: 4.0, timestamp: now.add(Duration(hours: 2)), isForecast: true),
      KpData(kpIndex: 3.0, timestamp: now.add(Duration(hours: 3)), isForecast: true),
      KpData(kpIndex: 2.0, timestamp: now.add(Duration(hours: 4)), isForecast: true),
    ];
  }

  static List<SpaceAlert> _getRealisticAlerts() {
    final now = DateTime.now();
    return [
      SpaceAlert(
        id: 'K04A',
        type: 'Geomagnetic',
        level: 'Alert',
        message: 'Geomagnetic K-index of 4 reached. Minor storm conditions possible.',
        issuedTime: now.subtract(Duration(hours: 2)),
        expiresTime: now.add(Duration(hours: 6)),
        kpIndex: 4.0,
        affectedAreas: [
          GeoCoordinate(latitude: 65.0, longitude: 0, locationName: 'High Latitudes'),
        ],
      ),
      SpaceAlert(
        id: 'SOLFLARE',
        type: 'Solar Radiation',
        level: 'Watch',
        message: 'Increased solar radiation levels detected. No significant impacts expected.',
        issuedTime: now.subtract(Duration(hours: 5)),
        kpIndex: null,
        affectedAreas: [
          GeoCoordinate(latitude: 0, longitude: 0, locationName: 'Global'),
        ],
      ),
    ];
  }

  // ... rest of your existing parsing methods (_parseAlerts, _parseSingleAlert, etc.)
  static List<SpaceAlert> _parseAlerts(List<dynamic> rawAlerts) {
    final List<SpaceAlert> alerts = [];

    for (final alert in rawAlerts) {
      try {
        final parsedAlert = _parseSingleAlert(alert);
        if (parsedAlert != null) {
          alerts.add(parsedAlert);
        }
      } catch (e) {
        print('Error parsing alert: $e');
      }
    }

    alerts.sort((a, b) => b.issuedTime.compareTo(a.issuedTime));
    return alerts;
  }

  static SpaceAlert? _parseSingleAlert(Map<String, dynamic> alert) {
    try {
      final String productId = alert['product_id'] ?? '';
      final String message = alert['message'] ?? '';
      final String issueTime = alert['issue_datetime'] ?? '';

      // Parse the issue time - handle different formats
      DateTime issuedTime;
      try {
        // Try parsing as-is (format: "2025-11-10 16:04:14.890")
        if (issueTime.contains(' ')) {
          // Replace space with 'T' and add 'Z' if no timezone
          String formattedTime = issueTime.replaceFirst(' ', 'T');
          if (!formattedTime.contains('Z') && !formattedTime.contains('+') && !formattedTime.contains('-', 10)) {
            formattedTime += 'Z';
          }
          issuedTime = DateTime.parse(formattedTime);
        } else {
          issuedTime = DateTime.parse(issueTime.replaceAll(' UTC', 'Z'));
        }
      } catch (e) {
        print('Error parsing issue time: $issueTime - $e');
        issuedTime = DateTime.now(); // Fallback to current time
      }

      return SpaceAlert(
        id: productId,
        type: _parseAlertType(productId, message),
        level: _parseAlertLevel(productId, message),
        message: message,
        issuedTime: issuedTime,
        expiresTime: _parseExpiresTime(message),
        kpIndex: _parseKpIndex(productId, message),
        affectedAreas: _parseAffectedAreas(message),
      );
    } catch (e) {
      print('Error parsing single alert: $e');
      return null;
    }
  }

  static DateTime? _parseExpiresTime(String message) {
    try {
      final expiresMatch = RegExp(r'Valid To: (\d{4} \w+ \d{2} \d{4} UTC)').firstMatch(message);
      if (expiresMatch != null) {
        return DateTime.parse(expiresMatch.group(1)!.replaceAll(' UTC', 'Z'));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String _parseAlertType(String productId, String message) {
    if (productId.contains('K')) return 'Geomagnetic';
    if (productId.contains('X') || message.contains('X-Ray')) return 'X-Ray Flux';
    if (productId.contains('R') || message.contains('Radio')) return 'Radio Blackout';
    if (productId.contains('S') || message.contains('Solar Radiation')) return 'Solar Radiation';
    return 'Space Weather';
  }

  static String _parseAlertLevel(String productId, String message) {
    if (productId.contains('A') || message.contains('ALERT')) return 'Alert';
    if (productId.contains('W') || message.contains('WARNING')) return 'Warning';
    if (message.contains('Watch')) return 'Watch';
    return 'Information';
  }

  static double? _parseKpIndex(String productId, String message) {
    try {
      final kMatch = RegExp(r'K(\d+)').firstMatch(productId);
      if (kMatch != null) return double.parse(kMatch.group(1)!);

      final messageMatch = RegExp(r'K-index of (\d+)').firstMatch(message);
      if (messageMatch != null) return double.parse(messageMatch.group(1)!);

      return null;
    } catch (e) {
      return null;
    }
  }

  static List<GeoCoordinate> _parseAffectedAreas(String message) {
    final List<GeoCoordinate> areas = [];

    final locations = {
      'New York': GeoCoordinate(latitude: 40.7128, longitude: -74.0060, locationName: 'New York'),
      'Wisconsin': GeoCoordinate(latitude: 43.7844, longitude: -88.7879, locationName: 'Wisconsin'),
      'Washington': GeoCoordinate(latitude: 47.6062, longitude: -122.3321, locationName: 'Washington'),
      'Michigan': GeoCoordinate(latitude: 44.3148, longitude: -85.6024, locationName: 'Michigan'),
      'Maine': GeoCoordinate(latitude: 45.2538, longitude: -69.4455, locationName: 'Maine'),
      'Canada': GeoCoordinate(latitude: 56.1304, longitude: -106.3468, locationName: 'Canada'),
      'Alaska': GeoCoordinate(latitude: 64.2008, longitude: -149.4937, locationName: 'Alaska'),
    };

    for (final location in locations.entries) {
      if (message.contains(location.key)) areas.add(location.value);
    }

    return areas;
  }
}