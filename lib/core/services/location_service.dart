import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Real-Time Location Service
/// Handles GPS coordination and permission management.
/// NO MOCK DATA - returns null if location cannot be obtained.

@lazySingleton
class LocationService {
  /// Get current location - returns null if location cannot be obtained
  /// NO FALLBACK COORDINATES - user must grant permission or select city manually
  Future<Position?> getCurrentLocation() async {
    try {
      // For web, use simpler approach with timeout
      if (kIsWeb) {
        return await _getWebLocation();
      }
      
      // For mobile platforms
      return await _getMobileLocation();
    } catch (e) {
      debugPrint('LocationService Error: $e');
      return null; // No fallback - return null
    }
  }

  Future<Position?> _getWebLocation() async {
    try {
      // Check permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Web location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Web location permission denied forever');
        return null;
      }

      // Web-specific location handling with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return position;
    } catch (e) {
      debugPrint('Web location failed: $e');
      return null; // No fallback - return null
    }
  }

  Future<Position?> _getMobileLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services disabled');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied');
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission denied forever');
      return null;
    } 

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      debugPrint('Failed to get mobile location: $e');
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update every 100 meters
      ),
    );
  }
}
