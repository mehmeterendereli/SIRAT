import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Qibla Service
/// Sensor Fusion ile GPS + Pusula entegrasyonu.
/// Kabe koordinatlarına göre kıble yönü hesaplar.

@lazySingleton
class QiblaService {
  // Kabe Koordinatları (Kutsal Kabe, Mekke)
  static const double _kabeLatitude = 21.4225;
  static const double _kabeLongitude = 39.8262;

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamController<QiblaData>? _qiblaController;

  /// Kıble verisini stream olarak dinle
  Stream<QiblaData> getQiblaStream() {
    _qiblaController = StreamController<QiblaData>.broadcast(
      onCancel: () => _compassSubscription?.cancel(),
    );

    _startQiblaCalculation();
    return _qiblaController!.stream;
  }

  Future<void> _startQiblaCalculation() async {
    // Önce konum izni kontrolü
    final position = await _getCurrentPosition();
    if (position == null) {
      _qiblaController?.addError(QiblaError.locationPermissionDenied);
      return;
    }

    // Kıble açısını hesapla (kullanıcı konumundan Kabe'ye)
    final qiblaAngle = _calculateQiblaAngle(
      position.latitude,
      position.longitude,
    );

    // Pusula verisi kontrolü
    final hasCompass = await FlutterCompass.events != null;
    if (!hasCompass) {
      _qiblaController?.addError(QiblaError.compassNotAvailable);
      return;
    }

    // Pusula stream'ini dinle
    _compassSubscription = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null) {
        _qiblaController?.add(QiblaData(
          qiblaAngle: qiblaAngle,
          compassHeading: 0,
          relativeAngle: qiblaAngle,
          accuracy: event.accuracy ?? 0,
          hasInterference: true,
        ));
        return;
      }

      // Göreceli açı = Kıble açısı - Pusula yönü
      double relativeAngle = qiblaAngle - heading;
      
      // Açıyı 0-360 aralığına normalize et
      if (relativeAngle < 0) {
        relativeAngle += 360;
      }

      _qiblaController?.add(QiblaData(
        qiblaAngle: qiblaAngle,
        compassHeading: heading,
        relativeAngle: relativeAngle,
        accuracy: event.accuracy ?? 0,
        hasInterference: (event.accuracy ?? 0) < 15, // Düşük doğruluk = parazit
      ));
    });
  }

  /// Kıble açısını hesapla (Haversine formülü)
  double _calculateQiblaAngle(double userLat, double userLng) {
    // Dereceleri radyana çevir
    final userLatRad = _toRadians(userLat);
    final userLngRad = _toRadians(userLng);
    final kabeLatRad = _toRadians(_kabeLatitude);
    final kabeLngRad = _toRadians(_kabeLongitude);

    // Kıble açısı hesaplama (Great Circle Bearing)
    final dLng = kabeLngRad - userLngRad;
    
    final y = math.sin(dLng) * math.cos(kabeLatRad);
    final x = math.cos(userLatRad) * math.sin(kabeLatRad) -
        math.sin(userLatRad) * math.cos(kabeLatRad) * math.cos(dLng);
    
    double angle = math.atan2(y, x);
    angle = _toDegrees(angle);
    
    // Açıyı 0-360 aralığına normalize et
    return (angle + 360) % 360;
  }

  /// Kabe'ye olan mesafeyi hesapla (km)
  double calculateDistanceToKaaba(double userLat, double userLng) {
    return Geolocator.distanceBetween(
      userLat, userLng,
      _kabeLatitude, _kabeLongitude,
    ) / 1000; // Metreyi kilometreye çevir
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      return null;
    }
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _toDegrees(double radians) => radians * 180 / math.pi;

  void dispose() {
    _compassSubscription?.cancel();
    _qiblaController?.close();
  }
}

/// Kıble verisi modeli
class QiblaData {
  final double qiblaAngle;      // Kabe'nin gerçek yönü (0-360)
  final double compassHeading;   // Pusula yönü (0-360)
  final double relativeAngle;    // Telefon yönüne göre kıble açısı
  final double accuracy;         // Pusula doğruluğu
  final bool hasInterference;    // Manyetik parazit var mı?

  QiblaData({
    required this.qiblaAngle,
    required this.compassHeading,
    required this.relativeAngle,
    required this.accuracy,
    required this.hasInterference,
  });

  /// Kıble yönüne bakıyor mu? (±5 derece tolerans)
  bool get isFacingQibla => relativeAngle.abs() < 5 || (360 - relativeAngle).abs() < 5;
}

/// Kıble hata türleri
enum QiblaError {
  locationPermissionDenied,
  compassNotAvailable,
  calibrationNeeded,
}
