import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/hijri_calendar.dart';
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

  /// Calculate responsive header height based on screen size
  double _getHeaderHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // For tablets/large screens
    if (screenWidth > 600) {
      return (screenHeight * 0.40).clamp(350.0, 450.0);
    }
    
    // For phones - scale based on screen height
    return (screenHeight * 0.48).clamp(320.0, 480.0);
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = _getHeaderHeight(context);
    
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        if (state is PrayerLoaded) {
          return _buildContent(context, state.prayerTime, state.locationName, headerHeight);
        }
        
        // Error state with retry button
        if (state is PrayerError) {
          return _buildErrorState(context, state.message, headerHeight);
        }
        
        // Loading state
        return Container(
          height: headerHeight,
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
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Namaz vakitleri yükleniyor...',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Error state with retry button
  Widget _buildErrorState(BuildContext context, String message, double height) {
    return Container(
      height: height,
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
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_rounded, size: 48, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PrayerBloc>().add(FetchPrayerTimes());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, PrayerTime prayer, String locationName, double headerHeight) {
    final skyController = SkyController(prayerTime: prayer, currentTime: _now);
    final celestialCalculator = CelestialCalculator(prayerTime: prayer, currentTime: _now);
    final greeting = SmartGreeting(prayerTime: prayer, currentTime: _now);
    
    final skyGradient = skyController.getGradient();
    final nextPrayer = _findNextPrayer(prayer);
    _countdown = _calculateCountdown(nextPrayer['time']);
    
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = isSmallScreen ? 16.0 : 24.0;
    
    return SizedBox(
      height: headerHeight,
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
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final isVerySmall = availableHeight < 300;
                final isSmall = availableHeight < 380;
                
                // Calculate responsive sizes
                final greetingFontSize = isVerySmall ? 20.0 : (isSmall ? 24.0 : 28.0);
                final topPadding = isVerySmall ? 8.0 : (isSmall ? 12.0 : 16.0);
                final cardBottomSpacing = isVerySmall ? 8.0 : (isSmall ? 12.0 : 16.0);
                final searchBarHeight = isVerySmall ? 40.0 : (isSmall ? 44.0 : 50.0);
                final horizontalPadding = isSmall ? 16.0 : 24.0;
                
                return Column(
                  children: [
                    // Header Row - Compact on small screens
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  greeting.getGreeting(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: greetingFontSize,
                                    fontWeight: FontWeight.bold,
                                    shadows: const [
                                      Shadow(color: Colors.black26, blurRadius: 4),
                                    ],
                                  ),
                                ),
                                if (!isVerySmall) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          widget.locationName ?? locationName,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: isSmall ? 12 : 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (!isVerySmall && !isSmall) ...[
                                  const SizedBox(height: 4),
                                  _buildHijriDateRow(),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.notifications_none_rounded, 
                                color: Colors.white,
                                size: isSmall ? 20 : 24,
                              ),
                              padding: EdgeInsets.all(isSmall ? 8 : 12),
                              constraints: BoxConstraints(
                                minWidth: isSmall ? 36 : 48,
                                minHeight: isSmall ? 36 : 48,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Flexible spacer - takes remaining space
                    const Expanded(child: SizedBox()),
                    
                    // ===== FROSTED GLASS CARD =====
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                    
                    SizedBox(height: cardBottomSpacing),
                    
                    // Search Bar - Responsive height
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, isSmall ? 8 : 12),
                      child: GestureDetector(
                        onTap: widget.onSearchTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
                          height: searchBarHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(isSmall ? 12 : 15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: AppTheme.primaryGreen, size: isSmall ? 20 : 24),
                              SizedBox(width: isSmall ? 8 : 12),
                              Expanded(
                                child: Text(
                                  'Sirat\'a sor...',
                                  style: TextStyle(fontSize: isSmall ? 12 : 14, color: Colors.grey),
                                ),
                              ),
                              Icon(Icons.mic_none_rounded, color: AppTheme.primaryGreen, size: isSmall ? 20 : 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
  
  /// Hicri tarih satırı
  Widget _buildHijriDateRow() {
    final hijriDate = HijriCalendar.fromGregorian(_now);
    final specialDay = IslamicSpecialDays.checkSpecialDay(hijriDate);
    final isSpecial = specialDay != IslamicSpecialDay.none;
    
    return Row(
      children: [
        Icon(
          Icons.nightlight_round,
          size: 14,
          color: isSpecial ? const Color(0xFFFFD700) : Colors.white70,
        ),
        const SizedBox(width: 4),
        Text(
          hijriDate.format(),
          style: TextStyle(
            color: isSpecial ? const Color(0xFFFFD700) : Colors.white70,
            fontSize: 12,
            fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isSpecial) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              IslamicSpecialDays.getSpecialDayName(specialDay),
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
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
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    
    // Responsive values
    final cardPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
    final titleFontSize = isSmallScreen ? 10.0 : 12.0;
    final nextPrayerFontSize = isSmallScreen ? 20.0 : 24.0;
    final countdownFontSize = isSmallScreen ? 24.0 : (isMediumScreen ? 28.0 : 32.0);
    final countdownPaddingH = isSmallScreen ? 16.0 : 28.0;
    final countdownPaddingV = isSmallScreen ? 10.0 : 14.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Next prayer info
              Text(
                'Sıradaki Vakit',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: titleFontSize,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  nextPrayer['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: nextPrayerFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: spacing),
              
              // Countdown
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: countdownPaddingH, 
                    vertical: countdownPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    countdown,
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: countdownFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: isSmallScreen ? 2 : 3,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: spacing),
              
              // Prayer times row - Responsive chips
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  const chipCount = 6;
                  final chipSpacing = isSmallScreen ? 4.0 : 6.0;
                  final totalSpacing = chipSpacing * (chipCount - 1);
                  final chipWidth = (availableWidth - totalSpacing) / chipCount;
                  
                  // Responsive font sizes clamped to prevent overflow
                  final labelFontSize = (chipWidth * 0.20).clamp(7.0, 11.0);
                  final timeFontSize = (chipWidth * 0.26).clamp(9.0, 14.0);
                  final verticalPadding = (chipWidth * 0.10).clamp(4.0, 8.0);
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PrayerChip(label: 'İmsak', time: prayer.imsak, isActive: nextPrayer['name'] == 'İmsak', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      SizedBox(width: chipSpacing),
                      _PrayerChip(label: 'Güneş', time: prayer.gunes, isActive: nextPrayer['name'] == 'Güneş', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      SizedBox(width: chipSpacing),
                      _PrayerChip(label: 'Öğle', time: prayer.ogle, isActive: nextPrayer['name'] == 'Öğle', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      SizedBox(width: chipSpacing),
                      _PrayerChip(label: 'İkindi', time: prayer.ikindi, isActive: nextPrayer['name'] == 'İkindi', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      SizedBox(width: chipSpacing),
                      _PrayerChip(label: 'Akşam', time: prayer.aksam, isActive: nextPrayer['name'] == 'Akşam', width: chipWidth, labelFontSize: labelFontSize, timeFontSize: timeFontSize, verticalPadding: verticalPadding),
                      SizedBox(width: chipSpacing),
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
// MOON PAINTER - Gerçek Ay Fazı Çizici (Saydam Arka Plan)
// =============================================================================

class MoonPainter extends CustomPainter {
  final MoonPhaseData phaseData;
  
  MoonPainter({required this.phaseData});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    
    // Ay glow efekti (hafif)
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius + 3, glowPaint);
    
    // Sadece aydınlık kısmı çiz (karanlık kısım saydam kalır)
    _drawIlluminatedPortion(canvas, center, radius);
  }
  
  void _drawIlluminatedPortion(Canvas canvas, Offset center, double radius) {
    final illumination = phaseData.illumination;
    final isWaxing = phaseData.isWaxing;
    
    // Ay yüzeyi için gradient
    final moonGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        const Color(0xFFFFFFF0),  // Kremsi beyaz
        const Color(0xFFE8E8E8),  // Açık gri
        const Color(0xFFD0D0D0),  // Kenarlarda daha koyu
      ],
    );
    
    final moonPaint = Paint()
      ..shader = moonGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;
    
    if (illumination <= 0.01) {
      // Yeni ay - sadece çok hafif outline
      final outlinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius, outlinePaint);
      return;
    }
    
    if (illumination >= 0.99) {
      // Dolunay - tam daire
      canvas.drawCircle(center, radius, moonPaint);
      _drawCraters(canvas, center, radius);
      return;
    }
    
    // Hilal veya gibbous fazı için path oluştur
    canvas.save();
    
    // Clip region oluştur
    final clipPath = _createMoonPhasePath(center, radius, illumination, isWaxing);
    canvas.clipPath(clipPath);
    
    // Clipped bölgeye ay çiz
    canvas.drawCircle(center, radius, moonPaint);
    
    // Kraterler
    _drawCraters(canvas, center, radius);
    
    canvas.restore();
  }
  
  Path _createMoonPhasePath(Offset center, double radius, double illumination, bool isWaxing) {
    final path = Path();
    
    if (illumination <= 0.5) {
      // Hilal fazı (ince şerit)
      // Aydınlık tarafın yarım dairesi
      if (isWaxing) {
        // Sağ taraf aydınlık
        path.moveTo(center.dx, center.dy - radius);
        path.arcToPoint(
          Offset(center.dx, center.dy + radius),
          radius: Radius.circular(radius),
          clockwise: true,
        );
        
        // Terminator eğrisi (içe doğru)
        final curveDepth = radius * (1 - illumination * 2);
        path.quadraticBezierTo(
          center.dx - curveDepth,
          center.dy,
          center.dx,
          center.dy - radius,
        );
      } else {
        // Sol taraf aydınlık
        path.moveTo(center.dx, center.dy - radius);
        path.arcToPoint(
          Offset(center.dx, center.dy + radius),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        
        final curveDepth = radius * (1 - illumination * 2);
        path.quadraticBezierTo(
          center.dx + curveDepth,
          center.dy,
          center.dx,
          center.dy - radius,
        );
      }
    } else {
      // Gibbous fazı (şişkin - yarıdan fazla aydınlık)
      final shadowDepth = radius * (2 - illumination * 2);
      
      if (isWaxing) {
        // Sağ taraf tam, sol taraf kısmi
        path.moveTo(center.dx, center.dy - radius);
        path.arcToPoint(
          Offset(center.dx, center.dy + radius),
          radius: Radius.circular(radius),
          clockwise: true,
        );
        path.arcToPoint(
          Offset(center.dx, center.dy - radius),
          radius: Radius.circular(radius),
          clockwise: true,
        );
        
        // Sol taraftan biraz çıkar
        final cutPath = Path();
        cutPath.moveTo(center.dx, center.dy - radius);
        cutPath.quadraticBezierTo(
          center.dx - shadowDepth,
          center.dy,
          center.dx,
          center.dy + radius,
        );
        cutPath.lineTo(center.dx - radius - 10, center.dy + radius);
        cutPath.lineTo(center.dx - radius - 10, center.dy - radius);
        cutPath.close();
        
        // Path'ten çıkar
        return Path.combine(PathOperation.difference, path, cutPath);
      } else {
        // Sol taraf tam, sağ taraf kısmi
        path.moveTo(center.dx, center.dy - radius);
        path.arcToPoint(
          Offset(center.dx, center.dy + radius),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        path.arcToPoint(
          Offset(center.dx, center.dy - radius),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        
        final cutPath = Path();
        cutPath.moveTo(center.dx, center.dy - radius);
        cutPath.quadraticBezierTo(
          center.dx + shadowDepth,
          center.dy,
          center.dx,
          center.dy + radius,
        );
        cutPath.lineTo(center.dx + radius + 10, center.dy + radius);
        cutPath.lineTo(center.dx + radius + 10, center.dy - radius);
        cutPath.close();
        
        return Path.combine(PathOperation.difference, path, cutPath);
      }
    }
    
    path.close();
    return path;
  }
  
  void _drawCraters(Canvas canvas, Offset center, double radius) {
    if (phaseData.illumination < 0.15) return;
    
    final craterPaint = Paint()
      ..color = const Color(0xFFCCCCCC).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    
    // Küçük krater detayları
    canvas.drawCircle(
      Offset(center.dx + radius * 0.25, center.dy - radius * 0.15),
      radius * 0.06,
      craterPaint,
    );
    canvas.drawCircle(
      Offset(center.dx - radius * 0.15, center.dy + radius * 0.25),
      radius * 0.08,
      craterPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.1, center.dy + radius * 0.35),
      radius * 0.05,
      craterPaint,
    );
  }
  
  @override
  bool shouldRepaint(MoonPainter oldDelegate) => 
      oldDelegate.phaseData.illumination != phaseData.illumination;
}

