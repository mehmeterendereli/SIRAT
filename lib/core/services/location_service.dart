import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Real-Time Location Service
/// Handles GPS coordination and permission management.
/// Includes fallback for web platform and testing.

@lazySingleton
class LocationService {
  // Fallback coordinates (Istanbul, Turkey - default for testing)
  static const double _defaultLatitude = 41.0082;
  static const double _defaultLongitude = 28.9784;

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
      // Return default position for testing
      return _createFallbackPosition();
    }
  }

  Future<Position?> _getWebLocation() async {
    try {
      // Web-specific location handling with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return position;
    } catch (e) {
      debugPrint('Web location failed: $e - Using fallback coordinates');
      return _createFallbackPosition();
    }
  }

  Future<Position?> _getMobileLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services disabled - Using fallback');
      return _createFallbackPosition();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied - Using fallback');
        return _createFallbackPosition();
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission denied forever - Using fallback');
      return _createFallbackPosition();
    } 

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Create fallback position for testing when location fails
  Position _createFallbackPosition() {
    return Position(
      latitude: _defaultLatitude,
      longitude: _defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 100.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
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
