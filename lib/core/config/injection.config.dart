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
import '../../presentation/bloc/islam_ai_bloc.dart' as _i851;
import '../../presentation/bloc/location_bloc.dart' as _i678;
import '../../presentation/bloc/prayer_bloc.dart' as _i232;
import '../../presentation/bloc/quran_bloc.dart' as _i288;
import '../network/dio_client.dart' as _i667;
import '../services/analytics_service.dart' as _i222;
import '../services/audio_download_service.dart' as _i207;
import '../services/chat_history_repository.dart' as _i474;
import '../services/daily_content_service.dart' as _i1004;
import '../services/geocoding_service.dart' as _i980;
import '../services/islam_ai_service.dart' as _i150;
import '../services/location_service.dart' as _i669;
import '../services/notification_service.dart' as _i941;
import '../services/qibla_service.dart' as _i754;
import '../services/quran_service.dart' as _i280;
import '../services/remote_config_service.dart' as _i858;
import '../services/zikirmatik_service.dart' as _i255;

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
    gh.lazySingleton<_i667.DioClient>(() => _i667.DioClient());
    gh.lazySingleton<_i222.AnalyticsService>(() => _i222.AnalyticsService());
    gh.lazySingleton<_i474.ChatHistoryRepository>(
        () => _i474.ChatHistoryRepository());
    gh.lazySingleton<_i1004.DailyContentService>(
        () => _i1004.DailyContentService());
    gh.lazySingleton<_i980.GeocodingService>(() => _i980.GeocodingService());
    gh.lazySingleton<_i150.IslamAIService>(() => _i150.IslamAIService());
    gh.lazySingleton<_i669.LocationService>(() => _i669.LocationService());
    gh.lazySingleton<_i941.NotificationService>(
        () => _i941.NotificationService());
    gh.lazySingleton<_i754.QiblaService>(() => _i754.QiblaService());
    gh.lazySingleton<_i280.QuranService>(() => _i280.QuranService());
    gh.lazySingleton<_i858.RemoteConfigService>(
        () => _i858.RemoteConfigService());
    gh.lazySingleton<_i255.ZikirmatikService>(() => _i255.ZikirmatikService());
    gh.lazySingleton<_i645.UserPreferencesRepository>(
        () => _i645.UserPreferencesRepository());
    gh.lazySingleton<_i207.AudioDownloadService>(
        () => _i207.AudioDownloadService());
    gh.lazySingleton<_i471.IPrayerRepository>(
        () => _i240.PrayerRepositoryImpl(gh<_i667.DioClient>()));
    gh.factory<_i851.IslamAIBloc>(() => _i851.IslamAIBloc(
          gh<_i150.IslamAIService>(),
          gh<_i474.ChatHistoryRepository>(),
        ));
    gh.lazySingleton<_i130.GetPrayerTimes>(
        () => _i130.GetPrayerTimes(gh<_i471.IPrayerRepository>()));
    gh.factory<_i678.LocationBloc>(() => _i678.LocationBloc(
          gh<_i669.LocationService>(),
          gh<_i980.GeocodingService>(),
        ));
    gh.factory<_i232.PrayerBloc>(() => _i232.PrayerBloc(
          gh<_i130.GetPrayerTimes>(),
          gh<_i669.LocationService>(),
          gh<_i980.GeocodingService>(),
          gh<_i645.UserPreferencesRepository>(),
        ));
    gh.factory<_i288.QuranBloc>(
        () => _i288.QuranBloc(gh<_i280.QuranService>()));
    return this;
  }
}
