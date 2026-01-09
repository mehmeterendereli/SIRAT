// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/repositories/prayer_repository_impl.dart' as _i240;
import '../../data/repositories/user_preferences_repository.dart' as _i645;
import '../../domain/repositories/i_prayer_repository.dart' as _i471;
import '../../domain/usecases/get_prayer_times.dart' as _i130;
import '../network/dio_client.dart' as _i667;
import '../services/analytics_service.dart' as _i222;
import '../services/notification_service.dart' as _i941;
import '../services/remote_config_service.dart' as _i858;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i222.AnalyticsService>(() => _i222.AnalyticsService());
    gh.lazySingleton<_i858.RemoteConfigService>(
        () => _i858.RemoteConfigService());
    gh.lazySingleton<_i645.UserPreferencesRepository>(
        () => _i645.UserPreferencesRepository());
    gh.lazySingleton<_i667.DioClient>(() => _i667.DioClient());
    gh.lazySingleton<_i941.NotificationService>(
        () => _i941.NotificationService());
    gh.lazySingleton<_i471.IPrayerRepository>(
        () => _i240.PrayerRepositoryImpl(gh<_i667.DioClient>()));
    gh.lazySingleton<_i130.GetPrayerTimes>(
        () => _i130.GetPrayerTimes(gh<_i471.IPrayerRepository>()));
    return this;
  }
}
