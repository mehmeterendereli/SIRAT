import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/injection.dart';
import '../../core/services/qibla_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Kıble Sayfası
/// AR (Augmented Reality) Modu + Standart Pusula Modu
/// Sensor Fusion ile doğru yön tayini.

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // QiblaService - sayfa açıldığında oluşturulur, kapandığında dispose edilir
  late final QiblaService _qiblaService;
  
  // Camera State
  CameraController? _cameraController;
  bool _isARMode = false;
  bool _isCameraInitialized = false;
  bool _hasCameraPermission = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    // QiblaService'i burada oluştur - sayfa kapandığında dispose edilecek
    _qiblaService = QiblaService();
    
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _enableARMode() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AR Modu Web tarayıcısında desteklenmemektedir.')),
      );
      return;
    }

    if (_cameras.isEmpty) await _initCamera();
    if (_cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera bulunamadı.')),
      );
      return;
    }

    // Permission check
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AR modu için kamera izni gereklidir.')),
        );
      }
      return;
    }

    setState(() => _hasCameraPermission = true);

    if (_cameraController != null) return;

    // Select back camera
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isARMode = true;
        });
      }
    } catch (e) {
      debugPrint('Camera controller init error: $e');
    }
  }

  void _disableARMode() {
    setState(() => _isARMode = false);
    // Kamera kaynağını tasarruf için hemen kapatmıyoruz, sadece duraklatabiliriz 
    // ama basitlik için dispose etmiyoruz, sayfa kapanınca dispose olacak.
    // İsteğe bağlı: _cameraController?.dispose(); _cameraController = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _qiblaService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Background/Foreground handling for camera
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_isARMode) _enableARMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!; // Localizations eklendiği varsayılıyor

    return Scaffold(
      extendBodyBehindAppBar: _isARMode, // AR modunda AppBar şeffaf olsun
      backgroundColor: _isARMode ? Colors.transparent : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.qibla_direction), // 'Kıble Yönü'
        centerTitle: true,
        backgroundColor: _isARMode ? Colors.black.withValues(alpha: 0.3) : null,
        elevation: _isARMode ? 0 : null,
        foregroundColor: _isARMode ? Colors.white : null,
        actions: [
          IconButton(
            icon: Icon(_isARMode ? Icons.close : Icons.view_in_ar),
            tooltip: _isARMode ? 'Standart Moda Geç' : 'AR Moduna Geç (Kamera)',
            onPressed: () {
              if (_isARMode) {
                _disableARMode();
              } else {
                _enableARMode();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showCalibrationDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Layer: Background (Camera or Color)
          if (_isARMode && _isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            ),
          
          // 2. Layer: Compass Content
          SafeArea(
            child: StreamBuilder<QiblaData>(
              stream: _qiblaService.getQiblaStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(context, snapshot.error as QiblaError);
                }

                if (!snapshot.hasData) {
                  return _buildLoadingState(context);
                }

                final data = snapshot.data!;
                return _buildQiblaCompass(context, data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _isARMode ? Colors.white : null,
          ),
          const SizedBox(height: 24),
          Text(
            'Kıble yönü hesaplanıyor...',
            style: TextStyle(
              color: _isARMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, QiblaError error) {
    IconData icon;
    String message;
    String action;

    switch (error) {
      case QiblaError.locationPermissionDenied:
        icon = Icons.location_off;
        message = 'Konum izni gerekli';
        action = 'Ayarlardan konum iznini açın';
        break;
      case QiblaError.compassNotAvailable:
        icon = Icons.explore_off;
        message = 'Pusula sensörü bulunamadı';
        action = 'Bu cihazda pusula desteklenmiyor';
        break;
      case QiblaError.calibrationNeeded:
        icon = Icons.warning_amber;
        message = 'Pusula kalibrasyonu gerekli';
        action = 'Telefonu 8 şeklinde hareket ettirin';
        break;
    }

    final textColor = _isARMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: _isARMode ? BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
        ) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: _isARMode ? Colors.white70 : Colors.grey),
            const SizedBox(height: 24),
            Text(message, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(action, style: TextStyle(color: _isARMode ? Colors.white70 : Colors.grey), textAlign: TextAlign.center),
            if (error == QiblaError.locationPermissionDenied)
               Padding(
                 padding: const EdgeInsets.only(top: 16),
                 child: ElevatedButton(
                   onPressed: () => openAppSettings(),
                   child: const Text('Ayarları Aç'),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildQiblaCompass(BuildContext context, QiblaData data) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final compassSize = screenWidth * 0.85;

    // Haptic feedback when aligned
    if (data.isFacingQibla) {
      // Throttle feedback? Ideally handled in state to not vibrate constantly
      // HapticFeedback.selectionClick(); 
    }

    return Column(
      children: [
        // Parazit uyarısı
        if (data.hasInterference)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.withValues(alpha: 0.9),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manyetik parazit! Metalden uzaklaşın.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

        const Spacer(),

        // COMPASS VIZ
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Compass Background (Dial)
              Container(
                width: compassSize,
                height: compassSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isARMode 
                      ? Colors.black.withValues(alpha: 0.4) // Semi-transparent in AR
                      : theme.colorScheme.surface,
                  border: Border.all(
                    color: data.isFacingQibla ? AppTheme.primaryGreen : Colors.grey.withValues(alpha: 0.3),
                    width: data.isFacingQibla ? 4 : 2,
                  ),
                  boxShadow: _isARMode ? [] : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _isARMode ? null : CustomPaint( // Hide grid in AR for cleaner view
                  painter: _CompassGridPainter(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),

              // 2. Rotating Scale (Cardinal Points N, S, E, W)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: -data.compassHeading),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, angle, child) {
                  return Transform.rotate(
                    angle: angle * math.pi / 180,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: compassSize - 40,
                  height: compassSize - 40,
                  child: CustomPaint(
                    painter: _CompassDialPainter(
                      color: _isARMode ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // 3. Qibla Needle (Points to Qibla relative to North)
              // The needle should rotate with the compass CARD, but point to a fixed QIBLA angle on that card.
              // Actually, standard approach: Dial rotates (N follows real North). Qibla needle is fixed on the Dial at Qibla Angle.
              // OR: Needle rotates independently to simplified 'Relative Angle'.
              
              // Let's use the layout where the Dial rotates to match real world.
              // We place an icon on the rotating dial at [qiblaAngle].
              
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: -data.compassHeading + data.qiblaAngle),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, angle, child) {
                  return Transform.rotate(
                    angle: angle * math.pi / 180,
                    child: child,
                  );
                },
                child: Container(
                  alignment: Alignment.topCenter,
                  height: compassSize - 60, 
                  width: compassSize - 60,
                  child: Column(
                    children: [
                      // Qibla Indicator Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppTheme.gold.withValues(alpha: 0.5), blurRadius: 10),
                          ],
                        ),
                        child: const Icon(Icons.mosque, color: Colors.white, size: 24),
                      ),
                      // Line
                      Expanded(
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [AppTheme.gold, Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              
              // 4. Center Decor
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: data.isFacingQibla ? AppTheme.primaryGreen : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Info Card
        if (!_isARMode || data.isFacingQibla) // AR modunda sadece hizalanınca göster veya hep göster
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: data.isFacingQibla 
                  ? AppTheme.primaryGreen.withValues(alpha: 0.9) 
                  : (_isARMode ? Colors.black54 : theme.cardColor),
              borderRadius: BorderRadius.circular(24),
              border: _isARMode ? Border.all(color: Colors.white24) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.isFacingQibla ? Icons.verified : Icons.compass_calibration,
                      color: data.isFacingQibla ? Colors.white : (_isARMode ? Colors.white70 : theme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      data.isFacingQibla 
                          ? 'Kıbleye Bakıyorsunuz' 
                          : _getDirectionText(data.relativeAngle),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: data.isFacingQibla ? Colors.white : (_isARMode ? Colors.white : theme.textTheme.bodyLarge?.color),
                      ),
                    ),
                  ],
                ),
               if (!data.isFacingQibla)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Kıble açısı: ${data.qiblaAngle.toStringAsFixed(1)}° (Kuzeyden)',
                      style: TextStyle(color: _isARMode ? Colors.white70 : Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  void _showCalibrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kalibrasyon'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.screen_rotation_alt, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Pusula hassasiyetini artırmak için telefonunuzu 8 çizerek hareket ettirin.'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam'))],
      ),
    );
  }
  
  /// Yön metnini hesapla (relative angle based)
  String _getDirectionText(double relativeAngle) {
    final absAngle = relativeAngle.abs();
    if (absAngle < 5) return 'Kıbleye Bakıyorsunuz';
    
    final direction = relativeAngle > 0 ? 'Sağa' : 'Sola';
    return '${absAngle.toStringAsFixed(0)}° $direction Dönün';
  }
}

// =============================================================================
// PAINTERS
// =============================================================================

class _CompassGridPainter extends CustomPainter {
  final Color color;
  _CompassGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1;

    canvas.drawCircle(center, radius * 0.7, paint);
    canvas.drawCircle(center, radius * 0.4, paint);
    
    // Crosshair
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), paint);
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassDialPainter extends CustomPainter {
  final Color color;
  _CompassDialPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2;
    final textPaint = TextPainter(textDirection: TextDirection.ltr);

    final cardinalPoints = ['K', 'D', 'G', 'B'];
    
    for (int i = 0; i < 360; i += 2) {
      final isCardinal = i % 90 == 0;
      final isIntermediate = i % 30 == 0;
      
      final angle = (i - 90) * math.pi / 180;
      final lineLength = isCardinal ? 15.0 : (isIntermediate ? 10.0 : 5.0);
      
      final innerX = center.dx + (radius - lineLength) * math.cos(angle);
      final innerY = center.dy + (radius - lineLength) * math.sin(angle);
      final outerX = center.dx + radius * math.cos(angle);
      final outerY = center.dy + radius * math.sin(angle);

      paint.strokeWidth = isCardinal ? 3 : (isIntermediate ? 2 : 1);
      paint.color = isCardinal ? Colors.red : color.withValues(alpha: 0.5);
      
      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), paint);

      if (isCardinal) {
        textPaint.text = TextSpan(
          text: cardinalPoints[i ~/ 90],
          style: TextStyle(
            color: i == 0 ? Colors.red : color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        );
        textPaint.layout();
        final textRadius = radius - 30;
        final tx = center.dx + textRadius * math.cos(angle) - textPaint.width / 2;
        final ty = center.dy + textRadius * math.sin(angle) - textPaint.height / 2;
        textPaint.paint(canvas, Offset(tx, ty));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
