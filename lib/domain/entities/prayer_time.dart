import 'package:equatable/equatable.dart';

/// Prayer Time Entity
/// Represents a single day's prayer schedule.

class PrayerTime extends Equatable {
  final DateTime date;
  final String imsak;
  final String gunes;
  final String ogle;
  final String ikindi;
  final String aksam;
  final String yatsi;

  const PrayerTime({
    required this.date,
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
  });

  @override
  List<Object?> get props => [date, imsak, gunes, ogle, ikindi, aksam, yatsi];
}
