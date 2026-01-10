import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/prayer_bloc.dart';
import '../../domain/entities/prayer_time.dart';

/// Next Prayer Card Component (REALLY Dynamic)
/// Consumes PrayerBloc for real-time API data.

class NextPrayerCard extends StatefulWidget {
  const NextPrayerCard({super.key});

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  Timer? _timer;
  String _countdown = '00:00:00';
  DateTime? _targetTime;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_targetTime != null) {
        _calculateCountdown(_targetTime!);
      }
    });
  }

  void _calculateCountdown(DateTime target) {
    final now = DateTime.now();
    if (target.isAfter(now)) {
      final diff = target.difference(now);
      setState(() {
        _countdown = _formatDuration(diff);
      });
    } else {
      setState(() {
        _countdown = '00:00:00';
      });
      // Vakit geldiğinde BLoC'u tetikleyerek yeni vakti al (veya sayfa yenilensin)
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        // Show loading for both Initial and Loading states
        if (state is PrayerInitial || state is PrayerLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is PrayerError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(state.message, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        if (state is PrayerLoaded) {
          final prayer = state.prayerTime;
          final next = _findNextPrayer(prayer);
          _targetTime = next['time'];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sıradaki Vakit: ${state.locationName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          next['name'],
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _countdown,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPrayerTimeItem(context, 'İmsak', prayer.imsak, next['name'] == 'İmsak'),
                      const SizedBox(width: 16),
                      _buildPrayerTimeItem(context, 'Güneş', prayer.gunes, next['name'] == 'Güneş'),
                      const SizedBox(width: 16),
                      _buildPrayerTimeItem(context, 'Öğle', prayer.ogle, next['name'] == 'Öğle'),
                      const SizedBox(width: 16),
                      _buildPrayerTimeItem(context, 'İkindi', prayer.ikindi, next['name'] == 'İkindi'),
                      const SizedBox(width: 16),
                      _buildPrayerTimeItem(context, 'Akşam', prayer.aksam, next['name'] == 'Akşam'),
                      const SizedBox(width: 16),
                      _buildPrayerTimeItem(context, 'Yatsı', prayer.yatsi, next['name'] == 'Yatsı'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Map<String, dynamic> _findNextPrayer(PrayerTime prayer) {
    final now = DateTime.now();

    final times = {
      'İmsak': _parseTimeToday(prayer.imsak, now),
      'Güneş': _parseTimeToday(prayer.gunes, now),
      'Öğle': _parseTimeToday(prayer.ogle, now),
      'İkindi': _parseTimeToday(prayer.ikindi, now),
      'Akşam': _parseTimeToday(prayer.aksam, now),
      'Yatsı': _parseTimeToday(prayer.yatsi, now),
    };

    for (var entry in times.entries) {
      if (entry.value.isAfter(now)) {
        return {'name': entry.key, 'time': entry.value};
      }
    }

    return {'name': 'İmsak', 'time': _parseTimeToday(prayer.imsak, now).add(const Duration(days: 1))};
  }

  /// Parse time string "HH:mm" to DateTime for today
  DateTime _parseTimeToday(String timeStr, DateTime now) {
    final parts = timeStr.split(':');
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  Widget _buildPrayerTimeItem(BuildContext context, String label, String timeStr, bool isActive) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive ? primary : theme.colorScheme.onSurface.withOpacity(0.4),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            timeStr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isActive ? primary : theme.colorScheme.onSurface,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
