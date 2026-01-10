import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Geocoding Service using OpenStreetMap Nominatim API
/// Works on Web, iOS, and Android - no API key required
/// Rate limit: 1 request per second

@lazySingleton
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'SIRAT/1.0';
  
  // Cache to avoid repeated requests for same location
  final Map<String, GeocodingResult> _cache = {};
  DateTime? _lastRequestTime;
  
  /// Reverse geocode coordinates to city/district name
  /// Returns GeocodingResult with cityName and district
  Future<GeocodingResult?> reverseGeocode(double latitude, double longitude) async {
    // Check cache first (round to 2 decimal places = ~1km accuracy)
    final cacheKey = '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    if (_cache.containsKey(cacheKey)) {
      debugPrint('Geocoding: Cache hit for $cacheKey');
      return _cache[cacheKey];
    }
    
    // Rate limiting - wait 1 second between requests
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
      }
    }
    
    try {
      debugPrint('Geocoding: Requesting reverse geocode for $latitude, $longitude');
      
      final uri = Uri.parse('$_baseUrl/reverse').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'json',
          'accept-language': 'tr', // Turkish names
          'zoom': '14', // City level detail
        },
      );
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      _lastRequestTime = DateTime.now();
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        
        if (address != null) {
          // Extract district and city from address
          final district = address['suburb'] ?? 
                          address['neighbourhood'] ?? 
                          address['town'] ?? 
                          address['village'] ??
                          address['city_district'] ?? '';
          
          final city = address['city'] ?? 
                       address['province'] ?? 
                       address['state'] ?? 
                       address['county'] ?? '';
          
          final result = GeocodingResult(
            district: district.toString(),
            city: city.toString(),
            displayName: data['display_name'] ?? '',
          );
          
          // Cache the result
          _cache[cacheKey] = result;
          
          debugPrint('Geocoding: Success - ${result.formattedName}');
          return result;
        }
      }
      
      debugPrint('Geocoding: API returned status ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Geocoding: Error - $e');
      return null;
    }
  }
  
  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }
}

/// Result of reverse geocoding
class GeocodingResult {
  final String district;
  final String city;
  final String displayName;
  
  const GeocodingResult({
    required this.district,
    required this.city,
    required this.displayName,
  });
  
  /// Get formatted name like "Kadıköy, İstanbul"
  String get formattedName {
    if (district.isNotEmpty && city.isNotEmpty) {
      return '$district, $city';
    } else if (city.isNotEmpty) {
      return city;
    } else if (district.isNotEmpty) {
      return district;
    }
    return 'Konum belirlendi';
  }
  
  @override
  String toString() => 'GeocodingResult(district: $district, city: $city)';
}
