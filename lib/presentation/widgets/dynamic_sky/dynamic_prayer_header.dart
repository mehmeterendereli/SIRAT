import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/prayer_time.dart';
import '../../bloc/prayer_bloc.dart';
import 'sky_controller.dart';

/// =============================================================================
/// DynamicPrayerHeader - Apple Weather Quality
/// =============================================================================
/// 
/// Gerçek zamanlı gökyüzü animasyonu:
/// - Güneş: sunrise → sunset arası yarı daire ark
/// - Ay: yatsı → imsak arası yarı daire ark
/// - Yıldızlar: Gece görünür, parıldama efekti
/// - Bulutlar: Yavaş drift hareketi
/// - Gradient: Vakit bazlı yumuşak geçişler

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
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  String _countdown = '--:--:--';
  DateTime _now = DateTime.now();
  
  // Animation controller for smooth effects
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _startTimers();
    
    // Single animation controller for all animated effects
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
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
    _animationController.dispose();
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
          height: 420,
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
    final skyController = SkyController(prayerTime: prayer, currentTime: _now);
    final celestialCalculator = CelestialCalculator(prayerTime: prayer, currentTime: _now);
    final greeting = SmartGreeting(prayerTime: prayer, currentTime: _now);
    
    final skyGradient = skyController.getGradient();
    final nextPrayer = _findNextPrayer(prayer);
    _countdown = _calculateCountdown(nextPrayer['time']);
    
    return SizedBox(
      height: 420,
      child: Stack(
        children: [
          // ===== LAYER 0: SKY GRADIENT BACKGROUND =====
          RepaintBoundary(
            child: AnimatedContainer(
              duration: const Duration(seconds: 30),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: skyGradient.toLinearGradient(),
              ),
            ),
          ),
          
          // ===== LAYER 1: STARS (Gece) =====
          if (skyGradient.starsOpacity > 0)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: skyGradient.starsOpacity,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: StarsPainter(
                        animationValue: _animationController.value,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // ===== LAYER 2: CELESTIAL BODIES =====
          LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, 280);
              final sunData = celestialCalculator.calculateSunPosition(size);
              final moonData = celestialCalculator.calculateMoonPosition(size);
              
              return Stack(
                children: [
                  // Güneş
                  if (sunData.isVisible)
                    Positioned(
                      left: sunData.position.dx - 30,
                      top: sunData.position.dy - 30,
                      child: _buildSun(),
                    ),
                  
                  // Ay
                  if (moonData.isVisible)
                    Positioned(
                      left: moonData.position.dx - 25,
                      top: moonData.position.dy - 25,
                      child: _buildMoon(),
                    ),
                ],
              );
            },
          ),
          
          // ===== LAYER 3: CLOUDS =====
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: skyGradient.isNight ? 0.15 : 0.4,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: CloudsPainter(
                      animationValue: _animationController.value,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // ===== LAYER 4: UI CONTENT =====
          SafeArea(
            child: Column(
              children: [
                // Header Row
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
                
                // ===== FROSTED GLASS CARD =====
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
  
  /// Güneş widget'ı
  Widget _buildSun() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFF59D),  // Açık sarı merkez
            Color(0xFFFFB74D),  // Turuncu
            Color(0xFFFF8F00),  // Koyu turuncu
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.6),
            blurRadius: 40,
            spreadRadius: 15,
          ),
        ],
      ),
    );
  }
  
  /// Ay widget'ı - Gerçek ay fazına göre çizim
  Widget _buildMoon() {
    final moonCalc = MoonPhaseCalculator(currentDate: _now);
    final phaseData = moonCalc.getPhaseData();
    
    return SizedBox(
      width: 50,
      height: 50,
      child: CustomPaint(
        painter: MoonPainter(phaseData: phaseData),
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
// STARS PAINTER
// =============================================================================

class StarsPainter extends CustomPainter {
  final double animationValue;
  
  StarsPainter({required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < cachedStars.length; i++) {
      final star = cachedStars[i];
      
      // Her yıldız için farklı parıldama fazı
      final phase = (animationValue + star.twinkleSpeed) % 1.0;
      final twinkle = math.sin(phase * math.pi * 2) * 0.5 + 0.5;
      
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 + twinkle * 0.7)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * (0.8 + twinkle * 0.4),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(StarsPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

// =============================================================================
// CLOUDS PAINTER
// =============================================================================

class CloudsPainter extends CustomPainter {
  final double animationValue;
  
  CloudsPainter({required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    // Cloud 1 - Sol üst, sağa hareket
    _drawCloud(canvas, paint, 
      Offset(
        size.width * (0.15 + animationValue * 0.1),
        size.height * 0.15,
      ),
      50,
    );
    
    // Cloud 2 - Orta, yavaş sola hareket
    _drawCloud(canvas, paint, 
      Offset(
        size.width * (0.55 - animationValue * 0.05),
        size.height * 0.22,
      ),
      35,
    );
    
    // Cloud 3 - Sağ üst, sağa hareket
    _drawCloud(canvas, paint, 
      Offset(
        size.width * (0.75 + animationValue * 0.08),
        size.height * 0.1,
      ),
      40,
    );
  }
  
  void _drawCloud(Canvas canvas, Paint paint, Offset center, double cloudSize) {
    // Fluffy cloud shape with overlapping circles
    canvas.drawCircle(center, cloudSize, paint);
    canvas.drawCircle(center + Offset(-cloudSize * 0.6, 0), cloudSize * 0.8, paint);
    canvas.drawCircle(center + Offset(cloudSize * 0.6, 0), cloudSize * 0.8, paint);
    canvas.drawCircle(center + Offset(-cloudSize * 0.3, -cloudSize * 0.3), cloudSize * 0.7, paint);
    canvas.drawCircle(center + Offset(cloudSize * 0.3, -cloudSize * 0.3), cloudSize * 0.7, paint);
    canvas.drawCircle(center + Offset(0, -cloudSize * 0.2), cloudSize * 0.6, paint);
  }
  
  @override
  bool shouldRepaint(CloudsPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
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
              
              // Countdown
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
              
              const SizedBox(height: 12),
              
              // Prayer times row
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  const chipCount = 6;
                  const spacing = 6.0;
                  const totalSpacing = spacing * (chipCount - 1);
                  final chipWidth = (availableWidth - totalSpacing) / chipCount;
                  
                  final labelFontSize = (chipWidth * 0.18).clamp(9.0, 12.0);
                  final timeFontSize = (chipWidth * 0.24).clamp(11.0, 15.0);
                  final verticalPadding = (chipWidth * 0.12).clamp(6.0, 10.0);
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PrayerChip(label: 'İmsak', time: prayer.imsak, isActive: nextPrayer['name'] == 'İmsak', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      const SizedBox(width: spacing),
                      _PrayerChip(label: 'Güneş', time: prayer.gunes, isActive: nextPrayer['name'] == 'Güneş', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      const SizedBox(width: spacing),
                      _PrayerChip(label: 'Öğle', time: prayer.ogle, isActive: nextPrayer['name'] == 'Öğle', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      const SizedBox(width: spacing),
                      _PrayerChip(label: 'İkindi', time: prayer.ikindi, isActive: nextPrayer['name'] == 'İkindi', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      const SizedBox(width: spacing),
                      _PrayerChip(label: 'Akşam', time: prayer.aksam, isActive: nextPrayer['name'] == 'Akşam', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      const SizedBox(width: spacing),
                      _PrayerChip(label: 'Yatsı', time: prayer.yatsi, isActive: nextPrayer['name'] == 'Yatsı', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PRAYER CHIP
// =============================================================================

class _PrayerChip extends StatelessWidget {
  final String label;
  final String time;
  final bool isActive;
  final double width;
  final double labelFontSize;
  final double timeFontSize;
  final double verticalPadding;
  
  const _PrayerChip({
    required this.label,
    required this.time,
    required this.isActive,
    required this.width,
    required this.labelFontSize,
    required this.timeFontSize,
    required this.verticalPadding,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(
        color: isActive 
            ? AppTheme.primaryGreen 
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: labelFontSize,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: verticalPadding * 0.2),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: timeFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MOON PAINTER - Gerçek Ay Fazı Çizici
// =============================================================================

class MoonPainter extends CustomPainter {
  final MoonPhaseData phaseData;
  
  MoonPainter({required this.phaseData});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Ay glow efekti
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius + 5, glowPaint);
    
    // Ay arka planı (karanlık kısım)
    final darkPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, darkPaint);
    
    // Aydınlık kısım
    final lightPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;
    
    // Ay fazına göre aydınlık kısmı çiz
    _drawMoonPhase(canvas, center, radius, lightPaint);
    
    // Ay yüzeyi detayları (kraterler)
    _drawCraters(canvas, center, radius);
  }
  
  void _drawMoonPhase(Canvas canvas, Offset center, double radius, Paint paint) {
    final illumination = phaseData.illumination;
    final isWaxing = phaseData.isWaxing;
    
    if (illumination <= 0.01) {
      // Yeni ay - çizme
      return;
    }
    
    if (illumination >= 0.99) {
      // Dolunay - tam daire
      canvas.drawCircle(center, radius, paint);
      return;
    }
    
    // Hilal veya yarım ay çizimi
    final path = Path();
    
    // Ay döngüsüne göre terminator pozisyonu
    // terminator: aydınlık-karanlık sınırı
    final terminatorOffset = (1 - illumination * 2).abs();
    
    if (illumination <= 0.5) {
      // Hilal fazı (ince)
      if (isWaxing) {
        // Sağ taraf aydınlık (büyüyen hilal)
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          math.pi,
        );
        
        // Terminator (karanlık-aydınlık sınırı)
        final controlX = center.dx + radius * terminatorOffset;
        path.quadraticBezierTo(
          controlX,
          center.dy,
          center.dx,
          center.dy - radius,
        );
      } else {
        // Sol taraf aydınlık (küçülen hilal)
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          math.pi / 2,
          math.pi,
        );
        
        final controlX = center.dx - radius * terminatorOffset;
        path.quadraticBezierTo(
          controlX,
          center.dy,
          center.dx,
          center.dy - radius,
        );
      }
    } else {
      // Gibbous fazı (şişkin)
      canvas.drawCircle(center, radius, paint);
      
      // Karanlık kısmı üzerine çiz
      final darkOverlay = Paint()
        ..color = const Color(0xFF2A2A2A)
        ..style = PaintingStyle.fill;
      
      final overlayPath = Path();
      if (isWaxing) {
        // Sol taraf karanlık
        overlayPath.addArc(
          Rect.fromCircle(center: center, radius: radius),
          math.pi / 2,
          math.pi,
        );
        final controlX = center.dx - radius * (2 - illumination * 2);
        overlayPath.quadraticBezierTo(
          controlX,
          center.dy,
          center.dx,
          center.dy - radius,
        );
      } else {
        // Sağ taraf karanlık
        overlayPath.addArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          math.pi,
        );
        final controlX = center.dx + radius * (2 - illumination * 2);
        overlayPath.quadraticBezierTo(
          controlX,
          center.dy,
          center.dx,
          center.dy - radius,
        );
      }
      canvas.drawPath(overlayPath, darkOverlay);
      return;
    }
    
    canvas.drawPath(path, paint);
  }
  
  void _drawCraters(Canvas canvas, Offset center, double radius) {
    // Sadece aydınlık kısımda görünen küçük kraterler
    if (phaseData.illumination < 0.1) return;
    
    final craterPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.fill;
    
    // Birkaç sabit krater pozisyonu
    final craters = [
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.2),
      Offset(center.dx - radius * 0.2, center.dy + radius * 0.3),
      Offset(center.dx + radius * 0.1, center.dy + radius * 0.1),
    ];
    
    for (final crater in craters) {
      canvas.drawCircle(crater, radius * 0.08, craterPaint);
    }
  }
  
  @override
  bool shouldRepaint(MoonPainter oldDelegate) => 
      oldDelegate.phaseData.phase != phaseData.phase;
}
