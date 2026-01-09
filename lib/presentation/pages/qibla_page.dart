import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/config/injection.dart';
import '../../core/services/qibla_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Kıble Sayfası
/// Sensor Fusion ile GPS + Pusula entegrasyonu.
/// Gerçek zamanlı kıble yönü gösterimi.

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final QiblaService _qiblaService = getIt<QiblaService>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _qiblaService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.qiblaDirection),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showCalibrationDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QiblaData>(
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
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Kıble yönü hesaplanıyor...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen konum izni verin',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(message, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(action, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQiblaCompass(BuildContext context, QiblaData data) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final compassSize = screenWidth * 0.8;

    return Column(
      children: [
        // Parazit uyarısı
        if (data.hasInterference)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade100,
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manyetik parazit algılandı. Metal nesnelerden uzaklaşın.',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan dairesi
                Container(
                  width: compassSize,
                  height: compassSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceContainerHighest,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),

                // Pusula dairesi (döner)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: -data.compassHeading),
                  duration: const Duration(milliseconds: 300),
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
                      painter: _CompassPainter(theme.colorScheme.onSurface),
                    ),
                  ),
                ),

                // Kıble oku
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: data.qiblaAngle - data.compassHeading),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, angle, child) {
                    return Transform.rotate(
                      angle: angle * math.pi / 180,
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mosque, color: Colors.white, size: 30),
                      ),
                      Container(
                        width: 4,
                        height: compassSize / 2 - 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppTheme.gold, AppTheme.gold.withValues(alpha: 0)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Merkez nokta
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bilgi kartı
        Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: data.isFacingQibla ? AppTheme.primaryGreen : theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                data.isFacingQibla ? Icons.check_circle : Icons.arrow_upward,
                color: data.isFacingQibla ? Colors.white : theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                data.isFacingQibla ? 'Kıbleye bakıyorsunuz!' : 'Kıble yönü: ${data.qiblaAngle.toStringAsFixed(1)}°',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: data.isFacingQibla ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
              if (!data.isFacingQibla) ...[
                const SizedBox(height: 4),
                Text(
                  'Telefonu ${data.relativeAngle > 180 ? "sola" : "sağa"} çevirin',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showCalibrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pusula Kalibrasyonu'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.screen_rotation, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Doğru kıble yönü için telefonunuzu 8 şeklinde hareket ettirerek pusulanızı kalibre edin.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

/// Basit pusula çizici
class _CompassPainter extends CustomPainter {
  final Color color;

  _CompassPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Daire
    canvas.drawCircle(center, radius, paint);

    // Yön çizgileri
    final directions = ['K', 'D', 'G', 'B'];
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0 ? Colors.red : color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final x = center.dx + (radius - 20) * math.cos(angle) - textPainter.width / 2;
      final y = center.dy + (radius - 20) * math.sin(angle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
