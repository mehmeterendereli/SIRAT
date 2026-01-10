import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/prayer_time.dart';
import '../../bloc/prayer_bloc.dart';
import 'sky_controller.dart';

/// DynamicPrayerHeader - Apple Weather Quality
/// 
/// 4-Layer Stack Architecture:
/// - Layer 0: Animated Gradient Background (lerp based on time)
/// - Layer 1: Celestial Bodies (Sun/Moon with arc movement)
/// - Layer 2: Atmosphere (Clouds, Stars)
/// - Layer 3: Frosted Glass UI Card

class DynamicPrayerHeader extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final String? locationName;
  
  const DynamicPrayerHeader({
    super.key,
    this.onSearchTap,
    this.locationName,
  });

  @override
  State<DynamicPrayerHeader> createState() => _DynamicPrayerHeaderState();
}

class _DynamicPrayerHeaderState extends State<DynamicPrayerHeader>
    with TickerProviderStateMixin {
  Timer? _timer;
  String _countdown = '--:--:--';
  DateTime _now = DateTime.now();
  
  // Animation controllers
  late AnimationController _cloudController;
  late AnimationController _starController;
  
  @override
  void initState() {
    super.initState();
    _startTimers();
    
    // Cloud drift animation (slow, continuous)
    _cloudController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    
    // Star twinkle animation
    _starController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  void _startTimers() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _cloudController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        if (state is PrayerLoaded) {
          return _buildContent(context, state.prayerTime, state.locationName);
        }
        
        // Loading state
        return Container(
          height: 380,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryGreen,
                AppTheme.teal,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      },
    );
  }
  
  Widget _buildContent(BuildContext context, PrayerTime prayer, String locationName) {
    // Controllers
    final skyController = SkyColorController(prayerTime: prayer, currentTime: _now);
    final greeting = SmartGreeting(prayerTime: prayer, currentTime: _now);
    final celestial = CelestialPosition(prayerTime: prayer, currentTime: _now);
    
    final skyGradient = skyController.getGradient();
    final celestialData = celestial.calculate();
    final nextPrayer = _findNextPrayer(prayer);
    _countdown = _calculateCountdown(nextPrayer['time']);
    
    return Container(
      height: 420,
      child: Stack(
        children: [
          // ===== LAYER 0: GRADIENT BACKGROUND =====
          _GradientBackground(gradient: skyGradient),
          
          // ===== LAYER 1: STARS (Night only) =====
          if (skyGradient.starsOpacity > 0)
            _StarsLayer(
              opacity: skyGradient.starsOpacity,
              animation: _starController,
            ),
          
          // ===== LAYER 2: CELESTIAL BODY =====
          if (celestialData.isVisible)
            _CelestialBody(
              data: celestialData,
              containerHeight: 280,
            ),
          
          // ===== LAYER 3: CLOUDS =====
          _CloudsLayer(
            animation: _cloudController,
            opacity: skyGradient.isNight ? 0.15 : 0.4,
          ),
          
          // ===== LAYER 4: UI CONTENT =====
          SafeArea(
            child: Column(
              children: [
                // Header Row (top aligned with padding)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting.getGreeting(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black26, blurRadius: 4),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.locationName ?? locationName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // ===== FROSTED GLASS CARD (CENTERED) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _FrostedGlassCard(
                        prayer: prayer,
                        nextPrayer: nextPrayer,
                        countdown: _countdown,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: widget.onSearchTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppTheme.primaryGreen),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Sirat\'a sor...',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          Icon(Icons.mic_none_rounded, color: AppTheme.primaryGreen),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _findNextPrayer(PrayerTime prayer) {
    final now = _now;
    final times = [
      {'name': 'İmsak', 'time': _parseTimeToday(prayer.imsak, now)},
      {'name': 'Güneş', 'time': _parseTimeToday(prayer.gunes, now)},
      {'name': 'Öğle', 'time': _parseTimeToday(prayer.ogle, now)},
      {'name': 'İkindi', 'time': _parseTimeToday(prayer.ikindi, now)},
      {'name': 'Akşam', 'time': _parseTimeToday(prayer.aksam, now)},
      {'name': 'Yatsı', 'time': _parseTimeToday(prayer.yatsi, now)},
    ];
    
    for (final t in times) {
      if ((t['time'] as DateTime).isAfter(now)) {
        return t;
      }
    }
    
    // Next day Imsak
    return {
      'name': 'İmsak',
      'time': _parseTimeToday(prayer.imsak, now).add(const Duration(days: 1)),
    };
  }
  
  DateTime _parseTimeToday(String timeStr, DateTime now) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return DateTime(now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]));
    }
    return now;
  }
  
  String _calculateCountdown(DateTime target) {
    final diff = target.difference(_now);
    if (diff.isNegative) return '00:00:00';
    
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }
}

// =============================================================================
// LAYER 0: GRADIENT BACKGROUND
// =============================================================================

class _GradientBackground extends StatelessWidget {
  final SkyGradient gradient;
  
  const _GradientBackground({required this.gradient});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: gradient.toLinearGradient(),
      ),
    );
  }
}

// =============================================================================
// LAYER 1: STARS
// =============================================================================

class _StarsLayer extends StatelessWidget {
  final double opacity;
  final AnimationController animation;
  
  const _StarsLayer({required this.opacity, required this.animation});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: opacity,
          child: CustomPaint(
            size: Size.infinite,
            painter: _StarsPainter(twinkle: animation.value),
          ),
        );
      },
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double twinkle;
  final List<Offset> _stars = [];
  final List<double> _sizes = [];
  
  _StarsPainter({required this.twinkle}) {
    // Generate stars once (pseudo-random based on index)
    final random = math.Random(42);
    for (int i = 0; i < 100; i++) {
      _stars.add(Offset(random.nextDouble(), random.nextDouble()));
      _sizes.add(random.nextDouble() * 2 + 0.5);
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _stars.length; i++) {
      final star = _stars[i];
      final starSize = _sizes[i];
      final twinkleOffset = (i % 3 == 0) ? twinkle : (1 - twinkle);
      
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 + twinkleOffset * 0.7)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height * 0.6),
        starSize * (0.8 + twinkleOffset * 0.4),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => oldDelegate.twinkle != twinkle;
}

// =============================================================================
// LAYER 2: CELESTIAL BODY (Sun/Moon)
// =============================================================================

class _CelestialBody extends StatelessWidget {
  final CelestialData data;
  final double containerHeight;
  
  const _CelestialBody({
    required this.data,
    required this.containerHeight,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate position on arc
    final x = 40 + (screenWidth - 80) * data.horizontalProgress;
    final maxArcHeight = containerHeight * 0.5;
    final y = containerHeight - 20 - (data.arcHeight * maxArcHeight);
    
    return Positioned(
      left: x - 25,
      top: y - 25,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: data.isSun
              ? const RadialGradient(
                  colors: [Color(0xFFFFF176), Color(0xFFFFB74D), Color(0xFFFF8F00)],
                )
              : const RadialGradient(
                  colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
                ),
          boxShadow: [
            BoxShadow(
              color: data.isSun
                  ? Colors.orange.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LAYER 3: CLOUDS
// =============================================================================

class _CloudsLayer extends StatelessWidget {
  final AnimationController animation;
  final double opacity;
  
  const _CloudsLayer({required this.animation, required this.opacity});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: opacity,
          child: CustomPaint(
            size: Size.infinite,
            painter: _CloudsPainter(offset: animation.value),
          ),
        );
      },
    );
  }
}

class _CloudsPainter extends CustomPainter {
  final double offset;
  
  _CloudsPainter({required this.offset});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    // Draw simple cloud shapes
    _drawCloud(canvas, paint, 
        Offset(size.width * (0.2 + offset * 0.1), size.height * 0.15), 40);
    _drawCloud(canvas, paint, 
        Offset(size.width * (0.6 + offset * 0.05), size.height * 0.25), 30);
    _drawCloud(canvas, paint, 
        Offset(size.width * (0.8 - offset * 0.08), size.height * 0.1), 35);
  }
  
  void _drawCloud(Canvas canvas, Paint paint, Offset center, double size) {
    // Simple cloud as overlapping circles
    canvas.drawCircle(center, size, paint);
    canvas.drawCircle(center + Offset(-size * 0.6, 0), size * 0.8, paint);
    canvas.drawCircle(center + Offset(size * 0.6, 0), size * 0.8, paint);
    canvas.drawCircle(center + Offset(-size * 0.3, -size * 0.3), size * 0.6, paint);
    canvas.drawCircle(center + Offset(size * 0.3, -size * 0.3), size * 0.6, paint);
  }
  
  @override
  bool shouldRepaint(_CloudsPainter oldDelegate) => oldDelegate.offset != offset;
}

// =============================================================================
// FROSTED GLASS CARD
// =============================================================================

class _FrostedGlassCard extends StatelessWidget {
  final PrayerTime prayer;
  final Map<String, dynamic> nextPrayer;
  final String countdown;
  
  const _FrostedGlassCard({
    required this.prayer,
    required this.nextPrayer,
    required this.countdown,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Next prayer info
              Text(
                'Sıradaki Vakit',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextPrayer['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Countdown - Centered, Monospaced
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  countdown,
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Prayer times row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PrayerTimeChip(label: 'İmsak', time: prayer.imsak, isActive: nextPrayer['name'] == 'İmsak'),
                    const SizedBox(width: 8),
                    _PrayerTimeChip(label: 'Güneş', time: prayer.gunes, isActive: nextPrayer['name'] == 'Güneş'),
                    const SizedBox(width: 8),
                    _PrayerTimeChip(label: 'Öğle', time: prayer.ogle, isActive: nextPrayer['name'] == 'Öğle'),
                    const SizedBox(width: 8),
                    _PrayerTimeChip(label: 'İkindi', time: prayer.ikindi, isActive: nextPrayer['name'] == 'İkindi'),
                    const SizedBox(width: 8),
                    _PrayerTimeChip(label: 'Akşam', time: prayer.aksam, isActive: nextPrayer['name'] == 'Akşam'),
                    const SizedBox(width: 8),
                    _PrayerTimeChip(label: 'Yatsı', time: prayer.yatsi, isActive: nextPrayer['name'] == 'Yatsı'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PRAYER TIME CHIP
// =============================================================================

class _PrayerTimeChip extends StatelessWidget {
  final String label;
  final String time;
  final bool isActive;
  
  const _PrayerTimeChip({
    required this.label,
    required this.time,
    required this.isActive,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive 
            ? AppTheme.primaryGreen 
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
