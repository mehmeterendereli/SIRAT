import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// IP tabanlı konum servisi
/// GPS izni verilmediğinde veya konum alınamadığında
/// IP adresinden yaklaşık konum belirler.

@lazySingleton
class IpGeolocationService {
  // Free IP geolocation API
  static const String _apiUrl = 'http://ip-api.com/json/?fields=status,lat,lon,city,country';
  
  IpLocation? _cachedLocation;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  /// IP adresinden konum al
  Future<IpLocation?> getLocationFromIp() async {
    // Cache kontrolü
    if (_cachedLocation != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        debugPrint('IpGeolocation: Using cached location: ${_cachedLocation?.city}');
        return _cachedLocation;
      }
    }
    
    try {
      debugPrint('IpGeolocation: Fetching location from IP...');
      
      final response = await http.get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          _cachedLocation = IpLocation(
            latitude: (data['lat'] as num).toDouble(),
            longitude: (data['lon'] as num).toDouble(),
            city: data['city'] ?? 'Bilinmeyen',
            country: data['country'] ?? '',
          );
          _cacheTime = DateTime.now();
          
          debugPrint('IpGeolocation: Got location: ${_cachedLocation?.city}, ${_cachedLocation?.country}');
          return _cachedLocation;
        }
      }
      
      debugPrint('IpGeolocation: API returned error or non-200 status');
      return null;
    } catch (e) {
      debugPrint('IpGeolocation: Error fetching location: $e');
      return null;
    }
  }
  
  /// Varsayılan konum (İstanbul, Türkiye)
  IpLocation getDefaultLocation() {
    return IpLocation(
      latitude: 41.0082,
      longitude: 28.9784,
      city: 'İstanbul',
      country: 'Türkiye',
    );
  }
}

/// IP tabanlı konum modeli
class IpLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  IpLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });
  
  String get formattedName => '$city, $country';
}
