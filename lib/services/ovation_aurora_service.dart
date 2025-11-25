// lib/services/ovation_aurora_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ovation_aurora_data.dart';

class OvationAuroraService {
  static const String _baseUrl = 'https://services.swpc.noaa.gov';
  static const String _latestUrl = '$_baseUrl/json/ovation_aurora_latest.json';

  static Future<OvationAuroraData?> getLatestAuroraData() async {
    try {
      final response = await http.get(
        Uri.parse(_latestUrl),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return OvationAuroraData.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching Ovation Aurora data: $e');
      return null;
    }
  }

  // Get maximum aurora intensity in a region
  static int getMaxIntensityInRegion(
    OvationAuroraData data,
    double minLat,
    double maxLat,
    double minLon,
    double maxLon,
  ) {
    int maxIntensity = 0;

    for (final point in data.coordinates) {
      if (point.latitude >= minLat &&
          point.latitude <= maxLat &&
          point.longitude >= minLon &&
          point.longitude <= maxLon) {
        if (point.intensity > maxIntensity) {
          maxIntensity = point.intensity;
        }
      }
    }

    return maxIntensity;
  }

  // Get color for aurora intensity (0-9 scale)
  static int getAuroraColor(int intensity) {
    // Return color value based on intensity
    // Higher intensity = brighter/more visible
    return intensity;
  }
}

