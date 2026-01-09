import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/prayer_time.dart';

/// Prayer Repository Interface
/// Abstract contract for fetching prayer times.

abstract class IPrayerRepository {
  Future<Either<Failure, PrayerTime>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required DateTime date,
  });

  Future<Either<Failure, List<PrayerTime>>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int month,
    required int year,
  });
}
