import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Qibla Service
/// Sensor Fusion ile GPS + Pusula entegrasyonu.
/// Kabe koordinatlarına göre kıble yönü hesaplar.
/// 
/// NOT: Factory pattern kullanılır - her sayfa açıldığında yeni instance
/// oluşturulur ve sayfa kapandığında dispose edilir.

@injectable
class QiblaService {
  // Kabe Koordinatları (Kutsal Kabe, Mekke)
  static const double _kabeLatitude = 21.4225;
  static const double _kabeLongitude = 39.8262;

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamController<QiblaData>? _qiblaController;
  bool _isDisposed = false;

  /// Kıble verisini stream olarak dinle
  Stream<QiblaData> getQiblaStream() {
    // Önceki stream'i temizle
    _cleanupResources();
    _isDisposed = false;
    
    _qiblaController = StreamController<QiblaData>.broadcast(
      onCancel: () {
        // Son listener ayrıldığında temizle
        _cleanupResources();
      },
    );

    _startQiblaCalculation();
    return _qiblaController!.stream;
  }

  Future<void> _startQiblaCalculation() async {
    if (_isDisposed || _qiblaController == null) return;
    
    // Önce konum izni kontrolü
    final position = await _getCurrentPosition();
    if (_isDisposed || _qiblaController == null) return;
    
    if (position == null) {
      _safeAddError(QiblaError.locationPermissionDenied);
      return;
    }

    // Kıble açısını hesapla (kullanıcı konumundan Kabe'ye)
    final qiblaAngle = _calculateQiblaAngle(
      position.latitude,
      position.longitude,
    );

    // Pusula verisi kontrolü
    final hasCompass = await FlutterCompass.events != null;
    if (_isDisposed || _qiblaController == null) return;
    
    if (!hasCompass) {
      _safeAddError(QiblaError.compassNotAvailable);
      return;
    }

    // Pusula stream'ini dinle
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (_isDisposed || _qiblaController == null || _qiblaController!.isClosed) {
        return;
      }
      
      final heading = event.heading;
      if (heading == null) {
        _safeAdd(QiblaData(
          qiblaAngle: qiblaAngle,
          compassHeading: 0,
          relativeAngle: qiblaAngle,
          accuracy: event.accuracy ?? 0,
          hasInterference: true,
          needsCalibration: true,
        ));
        return;
      }

      // Göreceli açı = Kıble açısı - Pusula yönü
      double relativeAngle = qiblaAngle - heading;
      
      // Açıyı -180 ile +180 aralığına normalize et
      while (relativeAngle > 180) {
        relativeAngle -= 360;
      }
      while (relativeAngle < -180) {
        relativeAngle += 360;
      }
      
      // Accuracy < 15 = düşük doğruluk (parazit veya kalibrasyon gerekli)
      final accuracy = event.accuracy ?? 0;
      final needsCalibration = accuracy < 25;

      _safeAdd(QiblaData(
        qiblaAngle: qiblaAngle,
        compassHeading: heading,
        relativeAngle: relativeAngle,
        accuracy: accuracy,
        hasInterference: accuracy < 15,
        needsCalibration: needsCalibration,
      ));
    });
  }
  
  /// Güvenli stream add - kapalı controller'a ekleme yapmaz
  void _safeAdd(QiblaData data) {
    if (!_isDisposed && _qiblaController != null && !_qiblaController!.isClosed) {
      _qiblaController!.add(data);
    }
  }
  
  /// Güvenli stream addError - kapalı controller'a ekleme yapmaz
  void _safeAddError(QiblaError error) {
    if (!_isDisposed && _qiblaController != null && !_qiblaController!.isClosed) {
      _qiblaController!.addError(error);
    }
  }
  
  /// Kaynakları temizle
  void _cleanupResources() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    
    if (_qiblaController != null && !_qiblaController!.isClosed) {
      _qiblaController!.close();
    }
    _qiblaController = null;
  }

  /// Kıble açısını hesapla (Great Circle Bearing / Haversine)
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
      debugPrint('QiblaService: Error getting position: $e');
      return null;
    }
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _toDegrees(double radians) => radians * 180 / math.pi;

  void dispose() {
    _isDisposed = true;
    _cleanupResources();
  }
}

/// Kıble verisi modeli
class QiblaData {
  final double qiblaAngle;        // Kabe'nin gerçek yönü (0-360, Kuzeyden)
  final double compassHeading;     // Pusula yönü (0-360)
  final double relativeAngle;      // Telefon yönüne göre kıble açısı (-180 to +180)
  final double accuracy;           // Pusula doğruluğu (derece)
  final bool hasInterference;      // Manyetik parazit var mı?
  final bool needsCalibration;     // Kalibrasyon gerekli mi?

  QiblaData({
    required this.qiblaAngle,
    required this.compassHeading,
    required this.relativeAngle,
    required this.accuracy,
    required this.hasInterference,
    this.needsCalibration = false,
  });

  /// Kıble yönüne bakıyor mu? (±5 derece tolerans)
  bool get isFacingQibla => relativeAngle.abs() < 5;
}

/// Kıble hata türleri
enum QiblaError {
  locationPermissionDenied,
  compassNotAvailable,
  calibrationNeeded,
}
