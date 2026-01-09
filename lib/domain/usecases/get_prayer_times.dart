import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/prayer_time.dart';
import '../repositories/i_prayer_repository.dart';

/// Get Today's Prayer Times UseCase
@lazySingleton
class GetPrayerTimes extends UseCase<PrayerTime, PrayerParams> {
  final IPrayerRepository repository;

  GetPrayerTimes(this.repository);

  @override
  Future<Either<Failure, PrayerTime>> call(PrayerParams params) async {
    return await repository.getPrayerTimes(
      latitude: params.latitude,
      longitude: params.longitude,
      method: params.method,
      date: params.date,
    );
  }
}

class PrayerParams {
  final double latitude;
  final double longitude;
  final int method;
  final DateTime date;

  PrayerParams({
    required this.latitude,
    required this.longitude,
    required this.method,
    required this.date,
  });
}
