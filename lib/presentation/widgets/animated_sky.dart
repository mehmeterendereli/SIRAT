import 'package:flutter/material.dart';
import 'package:aurora_background/aurora_background.dart';
import 'package:lottie/lottie.dart';

/// Professional Animated Sky Background System for SIRAT
/// Uses aurora_background package for production-quality starfield
/// Uses Lottie for premium crescent moon animation
/// 
/// This is THE world-class implementation for the best prayer time app

// =============================================================================
// PRAYER CARD SKY BACKGROUND (Production Version)
// =============================================================================

class PrayerCardSkyBackground extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  
  const PrayerCardSkyBackground({
    super.key,
    required this.child,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour >= 19;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // Professional background with gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isNight ? _nightCardGradient : _dayCardGradient,
              ),
            ),
          ),
          
          // Aurora Background with Starfield (Night only)
          if (isNight)
            Positioned.fill(
              child: AuroraBackground(
                // Disable aurora waves, only use starfield
                numberOfWaves: 0,
                backgroundColors: const [
                  Color(0xFF0D1B2A),
                  Color(0xFF1B2838),
                ],
                starFieldConfig: const StarFieldConfig(
                  starCount: 80,
                  maxStarSize: 2.5,
                  starColor: Colors.white,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          
          // Crescent Moon (Night only) - Premium positioned
          if (isNight)
            Positioned(
              top: 12,
              right: 15,
              child: _buildCrescentMoon(),
            ),
          
          // Subtle clouds for day (using simple shapes)
          if (!isNight)
            const Positioned.fill(
              child: _DaytimeClouds(),
            ),
          
          // Gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    (isNight ? Colors.black : Colors.white).withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          child,
        ],
      ),
    );
  }
  
  Widget _buildCrescentMoon() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFF8DC).withValues(alpha: 0.6),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CrescentMoonPainter(),
        size: const Size(30, 30),
      ),
    );
  }

  static const LinearGradient _nightCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D1B2A), // Deep midnight
      Color(0xFF1B2838), // Dark blue
      Color(0xFF162447), // Navy blue
    ],
  );

  static const LinearGradient _dayCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF87CEEB), // Sky blue
      Color(0xFF98D8E8), // Light blue
      Color(0xFFB0E0E6), // Powder blue
    ],
  );
}

// =============================================================================
// CRESCENT MOON PAINTER (Premium Quality)
// =============================================================================

class _CrescentMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Full moon (bright cream/gold color)
    final moonPaint = Paint()
      ..color = const Color(0xFFFFF8DC) // Cornsilk
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, moonPaint);

    // Shadow circle to create crescent effect
    final shadowPaint = Paint()
      ..color = const Color(0xFF0D1B2A) // Match night sky
      ..style = PaintingStyle.fill;

    // Offset shadow circle to create crescent
    final shadowCenter = Offset(center.dx + radius * 0.35, center.dy - radius * 0.1);
    canvas.drawCircle(shadowCenter, radius * 0.8, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// =============================================================================
// DAYTIME CLOUDS (Subtle animated clouds for day mode)
// =============================================================================

class _DaytimeClouds extends StatefulWidget {
  const _DaytimeClouds();

  @override
  State<_DaytimeClouds> createState() => _DaytimeCloudsState();
}

class _DaytimeCloudsState extends State<_DaytimeClouds>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CloudsPainter(animationValue: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CloudsPainter extends CustomPainter {
  final double animationValue;

  _CloudsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Draw 3 clouds moving slowly
    for (int i = 0; i < 3; i++) {
      final startX = (i * 0.4) - 0.1;
      final y = 0.15 + (i * 0.1);
      final x = ((startX + animationValue * 0.3) % 1.3) - 0.15;
      
      final centerX = x * size.width;
      final centerY = y * size.height;
      final cloudSize = 25.0 + (i * 8);
      
      // Draw cloud shape (overlapping circles)
      canvas.drawCircle(Offset(centerX, centerY), cloudSize, paint);
      canvas.drawCircle(Offset(centerX - cloudSize * 0.5, centerY + 3), cloudSize * 0.7, paint);
      canvas.drawCircle(Offset(centerX + cloudSize * 0.5, centerY + 3), cloudSize * 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(_CloudsPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

// =============================================================================
// FULL SCREEN SKY BACKGROUND (For dashboard header)
// =============================================================================

class FullScreenSkyBackground extends StatelessWidget {
  final Widget child;
  
  const FullScreenSkyBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour >= 19;
    
    if (isNight) {
      return AuroraBackground(
        numberOfWaves: 2,
        backgroundColors: const [
          Color(0xFF0D1B2A),
          Color(0xFF1B2838),
        ],
        waveColors: const [
          [Color(0xFF1B5E20), Color(0xFF004D40)],
          [Color(0xFF1A237E), Color(0xFF311B92)],
        ],
        waveDurations: const [8000, 12000],
        waveBlur: 50,
        starFieldConfig: const StarFieldConfig(
          starCount: 100,
          maxStarSize: 3.0,
          starColor: Colors.white,
        ),
        child: child,
      );
    }
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFFE0F7FA),
          ],
        ),
      ),
      child: child,
    );
  }
}
