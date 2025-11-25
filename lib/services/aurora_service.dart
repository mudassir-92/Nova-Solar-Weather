// lib/services/aurora_service.dart
import '../models/space_weather_data.dart';

class AuroraService {
  // Calculate aurora visibility probability based on Kp index and location
  static double calculateAuroraProbability(double kpIndex, double latitude) {
    // Aurora is typically visible at high latitudes (above 60°)
    // Higher Kp index means aurora can be seen at lower latitudes
    
    // Base probability calculation
    double baseProbability = 0.0;
    
    // Latitude factor (higher latitude = better visibility)
    double latFactor = (latitude - 40) / 30; // Normalize between 0-1 for 40-70° range
    latFactor = latFactor.clamp(0.0, 1.0);
    
    // Kp factor (higher Kp = better visibility at lower latitudes)
    double kpFactor = (kpIndex - 2) / 7; // Normalize between 0-1 for Kp 2-9
    kpFactor = kpFactor.clamp(0.0, 1.0);
    
    // Calculate probability
    if (latitude >= 70) {
      // Very high latitude - always good chance
      baseProbability = 0.7 + (kpIndex / 10) * 0.3;
    } else if (latitude >= 65) {
      // High latitude - good chance with moderate Kp
      baseProbability = 0.5 + (kpIndex / 10) * 0.4;
    } else if (latitude >= 60) {
      // Moderate latitude - needs higher Kp
      baseProbability = 0.3 + ((kpIndex - 3) / 7) * 0.5;
    } else if (latitude >= 55) {
      // Lower latitude - needs high Kp
      baseProbability = 0.1 + ((kpIndex - 5) / 5) * 0.4;
    } else {
      // Low latitude - rare, needs very high Kp
      baseProbability = 0.05 + ((kpIndex - 7) / 3) * 0.3;
    }
    
    return baseProbability.clamp(0.0, 1.0);
  }

  // Get aurora visibility level
  static String getAuroraLevel(double probability) {
    if (probability >= 0.8) return 'Excellent';
    if (probability >= 0.6) return 'Very Good';
    if (probability >= 0.4) return 'Good';
    if (probability >= 0.2) return 'Fair';
    if (probability >= 0.1) return 'Low';
    return 'Very Low';
  }

  // Get best viewing time (typically 10 PM - 2 AM local time)
  static String getBestViewingTime() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 22 || hour < 2) {
      return 'Now is a good time!';
    } else if (hour >= 20) {
      return 'Best in ${22 - hour} hours';
    } else if (hour < 6) {
      return 'Best in ${22 - hour + 24} hours';
    } else {
      return 'Best after 10 PM';
    }
  }

  // Calculate geomagnetic latitude (approximate)
  static double calculateGeomagneticLatitude(double geographicLatitude, double longitude) {
    // Simplified calculation - actual geomagnetic coordinates are more complex
    // This is an approximation
    return geographicLatitude + (longitude.abs() / 100) * 2;
  }

  // Get aurora forecast message
  static String getAuroraForecast(double kpIndex, double? latitude) {
    if (latitude == null) {
      return 'Set your location to get personalized aurora forecasts';
    }
    
    final probability = calculateAuroraProbability(kpIndex, latitude);
    final level = getAuroraLevel(probability);
    
    if (probability >= 0.6) {
      return 'Great conditions! Aurora may be visible tonight. Look north after dark.';
    } else if (probability >= 0.4) {
      return 'Moderate conditions. Aurora possible with clear skies and dark location.';
    } else if (probability >= 0.2) {
      return 'Fair conditions. Aurora unlikely but possible during strong activity.';
    } else {
      return 'Low conditions. Aurora unlikely at your location.';
    }
  }
}








