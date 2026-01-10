import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Animated Sky Background System for SIRAT
/// World-class atmospheric visual system with day/night awareness
/// 
/// Features:
/// - Twinkling stars at night
/// - Crescent moon (Hilal) during night hours
/// - Moving clouds during day
/// - Smooth gradient transitions between times
/// - Performance optimized with RepaintBoundary

// =============================================================================
// MAIN ANIMATED SKY WIDGET
// =============================================================================

class AnimatedSkyBackground extends StatelessWidget {
  final Widget child;
  final bool isNight;
  
  const AnimatedSkyBackground({
    super.key,
    required this.child,
    required this.isNight,
  });
  
  factory AnimatedSkyBackground.auto({
    Key? key,
    required Widget child,
  }) {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour >= 19;
    return AnimatedSkyBackground(key: key, child: child, isNight: isNight);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: isNight ? _nightGradient : _dayGradient,
            ),
          ),
        ),
        
        // Stars (Night only) - Wrapped in RepaintBoundary for performance
        if (isNight)
          const Positioned.fill(
            child: RepaintBoundary(
              child: TwinklingStars(),
            ),
          ),
        
        // Crescent Moon (Night only)
        if (isNight)
          const Positioned(
            top: 20,
            right: 30,
            child: CrescentMoon(),
          ),
        
        // Clouds (Day only)
        if (!isNight)
          const Positioned.fill(
            child: RepaintBoundary(
              child: MovingClouds(),
            ),
          ),
        
        // Actual content
        child,
      ],
    );
  }

  static const LinearGradient _nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D1B2A), // Deep midnight
      Color(0xFF1B2838), // Dark blue
      Color(0xFF1B3A4B), // Hint of teal
    ],
  );

  static const LinearGradient _dayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF87CEEB), // Sky blue
      Color(0xFFB0E0E6), // Powder blue
      Color(0xFFE0F7FA), // Light cyan
    ],
  );
}

// =============================================================================
// TWINKLING STARS
// =============================================================================

class TwinklingStars extends StatefulWidget {
  final int starCount;
  
  const TwinklingStars({
    super.key,
    this.starCount = 50,
  });

  @override
  State<TwinklingStars> createState() => _TwinklingStarsState();
}

class _TwinklingStarsState extends State<TwinklingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _generateStars();
  }

  void _generateStars() {
    _stars = List.generate(widget.starCount, (index) {
      return Star(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.6, // Stars only in top 60%
        size: _random.nextDouble() * 2 + 1,
        twinkleOffset: _random.nextDouble() * 2 * pi,
        twinkleSpeed: _random.nextDouble() * 0.5 + 0.5,
      );
    });
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
          painter: StarsPainter(
            stars: _stars,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double twinkleOffset;
  final double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleOffset,
    required this.twinkleSpeed,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarsPainter({
    required this.stars,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final opacity = (sin(animationValue * 2 * pi * star.twinkleSpeed + star.twinkleOffset) + 1) / 2;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 + opacity * 0.7)
        ..style = PaintingStyle.fill;

      // Draw star with glow
      final center = Offset(star.x * size.width, star.y * size.height);
      
      // Outer glow
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, star.size * 2, glowPaint);
      
      // Core star
      canvas.drawCircle(center, star.size, paint);
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

// =============================================================================
// CRESCENT MOON (HILAL)
// =============================================================================

class CrescentMoon extends StatefulWidget {
  final double size;
  
  const CrescentMoon({
    super.key,
    this.size = 40,
  });

  @override
  State<CrescentMoon> createState() => _CrescentMoonState();
}

class _CrescentMoonState extends State<CrescentMoon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFF8DC).withValues(alpha: _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: CrescentMoonPainter(),
            size: Size(widget.size, widget.size),
          ),
        );
      },
    );
  }
}

class CrescentMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Full moon (bright cream color)
    final moonPaint = Paint()
      ..color = const Color(0xFFFFF8DC) // Cornsilk
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, moonPaint);

    // Shadow circle to create crescent effect
    final shadowPaint = Paint()
      ..color = const Color(0xFF0D1B2A) // Match night sky
      ..style = PaintingStyle.fill;

    // Offset shadow circle to create crescent
    final shadowCenter = Offset(center.dx + radius * 0.4, center.dy - radius * 0.1);
    canvas.drawCircle(shadowCenter, radius * 0.85, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// =============================================================================
// MOVING CLOUDS
// =============================================================================

class MovingClouds extends StatefulWidget {
  final int cloudCount;
  
  const MovingClouds({
    super.key,
    this.cloudCount = 5,
  });

  @override
  State<MovingClouds> createState() => _MovingCloudsState();
}

class _MovingCloudsState extends State<MovingClouds>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Cloud> _clouds;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 60), // Slow cloud movement
      vsync: this,
    )..repeat();
    
    _generateClouds();
  }

  void _generateClouds() {
    _clouds = List.generate(widget.cloudCount, (index) {
      return Cloud(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.4 + 0.05, // Top 5-45%
        scale: _random.nextDouble() * 0.5 + 0.5,
        speed: _random.nextDouble() * 0.5 + 0.5,
        opacity: _random.nextDouble() * 0.3 + 0.4,
      );
    });
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
          painter: CloudsPainter(
            clouds: _clouds,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Cloud {
  final double x;
  final double y;
  final double scale;
  final double speed;
  final double opacity;

  Cloud({
    required this.x,
    required this.y,
    required this.scale,
    required this.speed,
    required this.opacity,
  });
}

class CloudsPainter extends CustomPainter {
  final List<Cloud> clouds;
  final double animationValue;

  CloudsPainter({
    required this.clouds,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final cloud in clouds) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: cloud.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      // Calculate moving X position
      final xPos = ((cloud.x + animationValue * cloud.speed) % 1.2) - 0.1;
      final centerX = xPos * size.width;
      final centerY = cloud.y * size.height;
      final cloudScale = cloud.scale * 40;

      // Draw cloud as overlapping circles
      canvas.drawCircle(Offset(centerX, centerY), cloudScale, paint);
      canvas.drawCircle(Offset(centerX - cloudScale * 0.6, centerY + 5), cloudScale * 0.7, paint);
      canvas.drawCircle(Offset(centerX + cloudScale * 0.6, centerY + 5), cloudScale * 0.7, paint);
      canvas.drawCircle(Offset(centerX - cloudScale * 0.3, centerY - cloudScale * 0.3), cloudScale * 0.5, paint);
      canvas.drawCircle(Offset(centerX + cloudScale * 0.3, centerY - cloudScale * 0.3), cloudScale * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(CloudsPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

// =============================================================================
// PRAYER CARD SKY BACKGROUND (Compact version for card)
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
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isNight ? _nightCardGradient : _dayCardGradient,
              ),
            ),
          ),
          
          // Stars for night
          if (isNight)
            const Positioned.fill(
              child: RepaintBoundary(
                child: TwinklingStars(starCount: 25),
              ),
            ),
          
          // Mini crescent for night
          if (isNight)
            const Positioned(
              top: 15,
              right: 20,
              child: CrescentMoon(size: 25),
            ),
          
          // Clouds for day
          if (!isNight)
            const Positioned.fill(
              child: RepaintBoundary(
                child: MovingClouds(cloudCount: 3),
              ),
            ),
          
          // Glass overlay for readability
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

  static const LinearGradient _nightCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D1B2A),
      Color(0xFF1B2838),
      Color(0xFF162447),
    ],
  );

  static const LinearGradient _dayCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF87CEEB),
      Color(0xFF98D8E8),
      Color(0xFFB0E0E6),
    ],
  );
}
