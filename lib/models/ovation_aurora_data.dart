// lib/models/ovation_aurora_data.dart
class OvationAuroraData {
  final String observationTime;
  final String forecastTime;
  final List<AuroraPoint> coordinates;

  OvationAuroraData({
    required this.observationTime,
    required this.forecastTime,
    required this.coordinates,
  });

  factory OvationAuroraData.fromJson(Map<String, dynamic> json) {
    final coords = (json['coordinates'] as List<dynamic>)
        .map((coord) => AuroraPoint.fromJson(coord))
        .toList();

    return OvationAuroraData(
      observationTime: json['Observation Time'] ?? '',
      forecastTime: json['Forecast Time'] ?? '',
      coordinates: coords,
    );
  }

  // Get aurora intensity at a specific location
  int? getAuroraIntensity(double longitude, double latitude) {
    // Find closest point
    double minDistance = double.infinity;
    AuroraPoint? closestPoint;

    for (final point in coordinates) {
      final distance = _calculateDistance(
        longitude,
        latitude,
        point.longitude,
        point.latitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }

    return closestPoint?.intensity;
  }

  double _calculateDistance(
    double lon1,
    double lat1,
    double lon2,
    double lat2,
  ) {
    // Simple distance calculation
    final dLat = (lat2 - lat1).abs();
    final dLon = (lon2 - lon1).abs();
    return dLat * dLat + dLon * dLon;
  }
}

class AuroraPoint {
  final double longitude;
  final double latitude;
  final int intensity; // 0-9 scale

  AuroraPoint({
    required this.longitude,
    required this.latitude,
    required this.intensity,
  });

  factory AuroraPoint.fromJson(List<dynamic> json) {
    return AuroraPoint(
      longitude: (json[0] as num).toDouble(),
      latitude: (json[1] as num).toDouble(),
      intensity: json[2] as int,
    );
  }
}

