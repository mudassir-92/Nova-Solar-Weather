// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  // Get location name from coordinates (reverse geocoding)
  static Future<String?> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        // Build location name
        String name = '';
        if (place.locality != null && place.locality!.isNotEmpty) {
          name = place.locality!;
        } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          name = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          name = place.administrativeArea!;
        } else if (place.country != null && place.country!.isNotEmpty) {
          name = place.country!;
        }
        
        if (name.isEmpty) {
          name = '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';
        }
        
        return name;
      }
      return null;
    } catch (e) {
      print('❌ Error getting location name: $e');
      return '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';
    }
  }

  // Get location with name
  static Future<Map<String, dynamic>?> getLocationWithName() async {
    final position = await getCurrentLocation();
    if (position == null) return null;

    final name = await getLocationName(position.latitude, position.longitude);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'name': name ?? '${position.latitude.toStringAsFixed(2)}°, ${position.longitude.toStringAsFixed(2)}°',
    };
  }
}








