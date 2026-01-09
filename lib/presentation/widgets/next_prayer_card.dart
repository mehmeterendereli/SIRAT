import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Next Prayer Card Component (Dynamic & Active)
/// Calculates countdown and updates every second.

class NextPrayerCard extends StatefulWidget {
  const NextPrayerCard({super.key});

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  Timer? _timer;
  String _countdown = '00:00:00';
  String _nextPrayerName = 'İkindi';
  String _nextPrayerTime = '15:45';

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
      _calculateCountdown();
    });
  }

  void _calculateCountdown() {
    // TODO: Connect this to actual PrayerTimesRepository
    // For now, mockup logic for visual verification
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 15, 45); // Mock Ikindi
    
    if (target.isAfter(now)) {
      final diff = target.difference(now);
      setState(() {
        _countdown = _pathDuration(diff);
      });
    } else {
      setState(() {
        _countdown = '00:00:00';
      });
    }
  }

  String _pathDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                    'Sıradaki Vakit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nextPrayerName,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPrayerTimeItem(context, 'İmsak', '06:12', false),
                const SizedBox(width: 16),
                _buildPrayerTimeItem(context, 'Öğle', '13:05', false),
                const SizedBox(width: 16),
                _buildPrayerTimeItem(context, 'İkindi', '15:45', true),
                const SizedBox(width: 16),
                _buildPrayerTimeItem(context, 'Akşam', '18:22', false),
                const SizedBox(width: 16),
                _buildPrayerTimeItem(context, 'Yatsı', '19:54', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeItem(
    BuildContext context,
    String label,
    String time,
    bool isActive,
  ) {
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
            time,
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
