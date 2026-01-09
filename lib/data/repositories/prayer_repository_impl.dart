import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/app_config.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/i_prayer_repository.dart';

/// Prayer Repository Implementation
/// Fetches prayer times from Aladhan API.

@LazySingleton(as: IPrayerRepository)
class PrayerRepositoryImpl implements IPrayerRepository {
  final DioClient dioClient;

  PrayerRepositoryImpl(this.dioClient);

  @override
  Future<Either<Failure, PrayerTime>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required DateTime date,
  }) async {
    try {
      final response = await dioClient.instance.get(
        '${AppConfig.prayerTimesApiUrl}/timings/${date.day}-${date.month}-${date.year}',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['timings'];
        return Right(PrayerTime(
          date: date,
          imsak: data['Imsak'],
          gunes: data['Sunrise'],
          ogle: data['Dhuhr'],
          ikindi: data['Asr'],
          aksam: data['Maghrib'],
          yatsi: data['Isha'],
        ));
      } else {
        return const Left(ServerFailure('API error: Invalid response code'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTime>>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int month,
    required int year,
  }) async {
    try {
      final response = await dioClient.instance.get(
        '${AppConfig.prayerTimesApiUrl}/calendar',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'month': month,
          'year': year,
          'method': method,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        final results = data.map((item) {
          final timings = item['timings'];
          final dateStr = item['date']['readable'];
          return PrayerTime(
            date: DateTime.now(), // Simplified
            imsak: timings['Imsak'],
            gunes: timings['Sunrise'],
            ogle: timings['Dhuhr'],
            ikindi: timings['Asr'],
            aksam: timings['Maghrib'],
            yatsi: timings['Isha'],
          );
        }).toList();
        return Right(results);
      } else {
        return const Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
