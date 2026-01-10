import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aurora_background/aurora_background.dart';

/// Ultra Professional Sky Scene Widget for SIRAT
/// 6-Layer Architecture for Apple/Weather App Quality
/// 
/// Layers (back to front):
/// 1. Dynamic Gradient Sky (Solar Position Based)
/// 2. Stars Layer (Night Only)
/// 3. Sun/Moon Glow (Celestial Body)
/// 4. Cloud Layer (Animated)
/// 5. Silhouette Layer (Mosque)
/// 6. Glassmorphism UI Overlay

class SkySceneWidget extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool showSilhouette;

  const SkySceneWidget({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.showSilhouette = false,
  });

  @override
  Widget build(BuildContext context) {
    final skyState = _calculateSkyState();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // Layer 1: Dynamic Gradient Sky
          _GradientSkyLayer(skyState: skyState),

          // Layer 2: Stars (Night only, with aurora_background)
          if (skyState.isNight)
            const _StarsLayer(),

          // Layer 3: Celestial Body (Sun or Moon with glow)
          _CelestialBodyLayer(skyState: skyState),

          // Layer 4: Animated Clouds
          if (skyState.cloudsOpacity > 0.1)
            _CloudLayer(opacity: skyState.cloudsOpacity),

          // Layer 5: Mosque Silhouette (Optional)
          if (showSilhouette)
            const _SilhouetteLayer(),

          // Layer 6: Gradient overlay for UI readability
          _GlassOverlay(isNight: skyState.isNight),

          // Content (UI)
          child,
        ],
      ),
    );
  }

  _SkyState _calculateSkyState() {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    final timeValue = hour + (minute / 60.0);

    // Determine period and colors
    if (timeValue >= 21.0 || timeValue < 4.0) {
      return _SkyState.night();
    } else if (timeValue >= 4.0 && timeValue < 5.5) {
      return _SkyState.fajr();
    } else if (timeValue >= 5.5 && timeValue < 7.0) {
      return _SkyState.sunrise();
    } else if (timeValue >= 7.0 && timeValue < 12.0) {
      return _SkyState.morning();
    } else if (timeValue >= 12.0 && timeValue < 15.0) {
      return _SkyState.noon();
    } else if (timeValue >= 15.0 && timeValue < 17.0) {
      return _SkyState.afternoon();
    } else if (timeValue >= 17.0 && timeValue < 19.0) {
      return _SkyState.sunset();
    } else {
      return _SkyState.maghrib();
    }
  }
}

// =============================================================================
// SKY STATE
// =============================================================================

class _SkyState {
  final List<Color> gradientColors;
  final bool isNight;
  final bool showSun;
  final bool showMoon;
  final double starsOpacity;
  final double cloudsOpacity;
  final double celestialPosition; // 0.0 = left, 1.0 = right

  const _SkyState({
    required this.gradientColors,
    required this.isNight,
    required this.showSun,
    required this.showMoon,
    required this.starsOpacity,
    required this.cloudsOpacity,
    required this.celestialPosition,
  });

  factory _SkyState.night() => const _SkyState(
    gradientColors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF1B3A4B)],
    isNight: true,
    showSun: false,
    showMoon: true,
    starsOpacity: 1.0,
    cloudsOpacity: 0.15,
    celestialPosition: 0.8,
  );

  factory _SkyState.fajr() => const _SkyState(
    gradientColors: [Color(0xFF1A237E), Color(0xFF311B92), Color(0xFF4A148C)],
    isNight: true,
    showSun: false,
    showMoon: true,
    starsOpacity: 0.5,
    cloudsOpacity: 0.2,
    celestialPosition: 0.9,
  );

  factory _SkyState.sunrise() => const _SkyState(
    gradientColors: [Color(0xFF3949AB), Color(0xFFFF6F00), Color(0xFFFFEB3B)],
    isNight: false,
    showSun: true,
    showMoon: false,
    starsOpacity: 0.0,
    cloudsOpacity: 0.4,
    celestialPosition: 0.2,
  );

  factory _SkyState.morning() => const _SkyState(
    gradientColors: [Color(0xFF42A5F5), Color(0xFF64B5F6), Color(0xFFE3F2FD)],
    isNight: false,
    showSun: true,
    showMoon: false,
    starsOpacity: 0.0,
    cloudsOpacity: 0.5,
    celestialPosition: 0.35,
  );

  factory _SkyState.noon() => const _SkyState(
    gradientColors: [Color(0xFF1E88E5), Color(0xFF42A5F5), Color(0xFFBBDEFB)],
    isNight: false,
    showSun: true,
    showMoon: false,
    starsOpacity: 0.0,
    cloudsOpacity: 0.6,
    celestialPosition: 0.5,
  );

  factory _SkyState.afternoon() => const _SkyState(
    gradientColors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFF81C784)],
    isNight: false,
    showSun: true,
    showMoon: false,
    starsOpacity: 0.0,
    cloudsOpacity: 0.5,
    celestialPosition: 0.65,
  );

  factory _SkyState.sunset() => const _SkyState(
    gradientColors: [Color(0xFF5C6BC0), Color(0xFFE65100), Color(0xFFFF8F00)],
    isNight: false,
    showSun: true,
    showMoon: false,
    starsOpacity: 0.1,
    cloudsOpacity: 0.7,
    celestialPosition: 0.85,
  );

  factory _SkyState.maghrib() => const _SkyState(
    gradientColors: [Color(0xFF283593), Color(0xFFBF360C), Color(0xFFE65100)],
    isNight: true,
    showSun: false,
    showMoon: true,
    starsOpacity: 0.3,
    cloudsOpacity: 0.4,
    celestialPosition: 0.1,
  );
}

// =============================================================================
// LAYER 1: GRADIENT SKY
// =============================================================================

class _GradientSkyLayer extends StatelessWidget {
  final _SkyState skyState;

  const _GradientSkyLayer({required this.skyState});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: skyState.gradientColors,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LAYER 2: STARS (using aurora_background)
// =============================================================================

class _StarsLayer extends StatelessWidget {
  const _StarsLayer();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AuroraBackground(
          numberOfWaves: 0, // Only stars, no aurora
          backgroundColors: const [Colors.transparent, Colors.transparent],
          starFieldConfig: const StarFieldConfig(
            starCount: 100,
            maxStarSize: 2.5,
            starColor: Colors.white,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// =============================================================================
// LAYER 3: CELESTIAL BODY (Sun or Moon with Glow)
// =============================================================================

class _CelestialBodyLayer extends StatefulWidget {
  final _SkyState skyState;

  const _CelestialBodyLayer({required this.skyState});

  @override
  State<_CelestialBodyLayer> createState() => _CelestialBodyLayerState();
}

class _CelestialBodyLayerState extends State<_CelestialBodyLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.skyState.showSun && !widget.skyState.showMoon) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 15,
      right: 15 + (1 - widget.skyState.celestialPosition) * 50,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.skyState.showSun
                          ? const Color(0xFFFFEB3B)
                          : const Color(0xFFFFF8DC))
                      .withValues(alpha: _glowAnimation.value * 0.7),
                  blurRadius: 25,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: widget.skyState.showMoon
                ? CustomPaint(painter: _CrescentMoonPainter())
                : CustomPaint(painter: _SunPainter()),
          );
        },
      ),
    );
  }
}

class _CrescentMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final moonPaint = Paint()
      ..color = const Color(0xFFFFF8DC)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, moonPaint);

    final shadowPaint = Paint()
      ..color = const Color(0xFF0D1B2A)
      ..style = PaintingStyle.fill;

    final shadowCenter = Offset(center.dx + radius * 0.35, center.dy - radius * 0.1);
    canvas.drawCircle(shadowCenter, radius * 0.8, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Sun gradient
    final sunGradient = RadialGradient(
      colors: [
        const Color(0xFFFFEB3B),
        const Color(0xFFFF9800),
      ],
    );

    final sunPaint = Paint()
      ..shader = sunGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.8, sunPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// =============================================================================
// LAYER 4: CLOUDS (Animated)
// =============================================================================

class _CloudLayer extends StatefulWidget {
  final double opacity;

  const _CloudLayer({required this.opacity});

  @override
  State<_CloudLayer> createState() => _CloudLayerState();
}

class _CloudLayerState extends State<_CloudLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 120),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _CloudPainter(
                animationValue: _controller.value,
                opacity: widget.opacity,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double animationValue;
  final double opacity;

  _CloudPainter({required this.animationValue, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Draw 4 clouds with different speeds
    for (int i = 0; i < 4; i++) {
      final startX = (i * 0.3) - 0.2;
      final y = 0.1 + (i * 0.08);
      final speed = 0.15 + (i * 0.05);
      final x = ((startX + animationValue * speed) % 1.4) - 0.2;

      final centerX = x * size.width;
      final centerY = y * size.height;
      final cloudSize = 20.0 + (i * 10);

      // Cloud shape (overlapping ellipses)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: cloudSize * 2.5,
          height: cloudSize,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX - cloudSize * 0.6, centerY + 3),
          width: cloudSize * 1.8,
          height: cloudSize * 0.8,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX + cloudSize * 0.6, centerY + 3),
          width: cloudSize * 1.8,
          height: cloudSize * 0.8,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CloudPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// =============================================================================
// LAYER 5: SILHOUETTE (Mosque)
// =============================================================================

class _SilhouetteLayer extends StatelessWidget {
  const _SilhouetteLayer();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 60,
      child: CustomPaint(
        painter: _MosqueSilhouettePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _MosqueSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Ground
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.7);

    // Simple mosque dome shape
    final domeCenter = size.width * 0.5;
    final domeWidth = size.width * 0.3;

    // Left building
    path.lineTo(domeCenter - domeWidth, size.height * 0.7);
    path.lineTo(domeCenter - domeWidth, size.height * 0.4);

    // Dome curve
    path.quadraticBezierTo(
      domeCenter,
      size.height * 0.1,
      domeCenter + domeWidth,
      size.height * 0.4,
    );

    // Right building
    path.lineTo(domeCenter + domeWidth, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Minaret
    final minaretPaint = Paint()
      ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final minaretPath = Path();
    final minaretX = size.width * 0.75;

    minaretPath.moveTo(minaretX - 5, size.height * 0.7);
    minaretPath.lineTo(minaretX - 3, size.height * 0.15);
    minaretPath.lineTo(minaretX, size.height * 0.08);
    minaretPath.lineTo(minaretX + 3, size.height * 0.15);
    minaretPath.lineTo(minaretX + 5, size.height * 0.7);
    minaretPath.close();

    canvas.drawPath(minaretPath, minaretPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// =============================================================================
// LAYER 6: GLASS OVERLAY
// =============================================================================

class _GlassOverlay extends StatelessWidget {
  final bool isNight;

  const _GlassOverlay({required this.isNight});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              (isNight ? Colors.black : Colors.white).withValues(alpha: 0.25),
            ],
          ),
        ),
      ),
    );
  }
}
