import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/usecases/get_prayer_times.dart';
import '../../core/services/location_service.dart';
import '../../core/services/geocoding_service.dart';
import '../../core/services/ip_geolocation_service.dart';
import '../../data/repositories/user_preferences_repository.dart';

// Events
abstract class PrayerEvent extends Equatable {
  const PrayerEvent();
  @override
  List<Object?> get props => [];
}

class FetchPrayerTimes extends PrayerEvent {}

/// Fetch prayer times with specific coordinates
class FetchPrayerTimesWithLocation extends PrayerEvent {
  final double latitude;
  final double longitude;
  final String? cityName;
  
  const FetchPrayerTimesWithLocation({
    required this.latitude,
    required this.longitude,
    this.cityName,
  });
  
  @override
  List<Object?> get props => [latitude, longitude, cityName];
}

// States
abstract class PrayerState extends Equatable {
  const PrayerState();
  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}
class PrayerLoading extends PrayerState {}
class PrayerLoaded extends PrayerState {
  final PrayerTime prayerTime;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final bool isApproximateLocation; // IP tabanlı konum mu?
  
  const PrayerLoaded(
    this.prayerTime, 
    this.locationName, {
    this.latitude,
    this.longitude,
    this.isApproximateLocation = false,
  });
  
  @override
  List<Object?> get props => [prayerTime, locationName, latitude, longitude, isApproximateLocation];
}
class PrayerError extends PrayerState {
  final String message;
  const PrayerError(this.message);
  @override
  List<Object> get props => [message];
}

@injectable
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final GetPrayerTimes getPrayerTimes;
  final LocationService locationService;
  final GeocodingService geocodingService;
  final UserPreferencesRepository userPrefs;
  final IpGeolocationService ipGeolocationService;

  PrayerBloc(
    this.getPrayerTimes, 
    this.locationService, 
    this.geocodingService,
    this.userPrefs,
    this.ipGeolocationService,
  ) : super(PrayerInitial()) {
    on<FetchPrayerTimes>(_onFetchPrayerTimes);
    on<FetchPrayerTimesWithLocation>(_onFetchPrayerTimesWithLocation);
  }

  Future<void> _onFetchPrayerTimes(FetchPrayerTimes event, Emitter<PrayerState> emit) async {
    emit(PrayerLoading());
    
    double? latitude;
    double? longitude;
    String? cityName;
    bool isApproximate = false;
    
    try {
      // 1. Önce GPS konum dene
      final gpsLocation = await _tryGetGpsLocation();
      
      if (gpsLocation != null) {
        latitude = gpsLocation.latitude;
        longitude = gpsLocation.longitude;
        
        // Şehir adını geocoding ile al
        final geocodingResult = await geocodingService.reverseGeocode(latitude, longitude);
        cityName = geocodingResult?.formattedName ?? 'Konum belirlendi';
        
        debugPrint('PrayerBloc: GPS location: $cityName ($latitude, $longitude)');
      } else {
        // 2. GPS başarısız - IP tabanlı konum dene
        debugPrint('PrayerBloc: GPS failed, trying IP geolocation...');
        
        final ipLocation = await ipGeolocationService.getLocationFromIp();
        
        if (ipLocation != null) {
          latitude = ipLocation.latitude;
          longitude = ipLocation.longitude;
          cityName = ipLocation.formattedName;
          isApproximate = true;
          
          debugPrint('PrayerBloc: IP location: $cityName ($latitude, $longitude)');
        } else {
          // 3. IP de başarısız - Varsayılan konum (İstanbul)
          debugPrint('PrayerBloc: IP geolocation failed, using default location');
          
          final defaultLocation = ipGeolocationService.getDefaultLocation();
          latitude = defaultLocation.latitude;
          longitude = defaultLocation.longitude;
          cityName = defaultLocation.formattedName;
          isApproximate = true;
        }
      }
      
      // Namaz vakitlerini çek
      await _fetchAndEmitPrayerTimes(
        emit,
        latitude!,
        longitude!,
        cityName!,
        isApproximate,
      );
      
    } catch (e) {
      debugPrint('PrayerBloc: Error - $e');
      
      // Son çare: Varsayılan konum ile dene
      try {
        final defaultLocation = ipGeolocationService.getDefaultLocation();
        await _fetchAndEmitPrayerTimes(
          emit,
          defaultLocation.latitude,
          defaultLocation.longitude,
          defaultLocation.formattedName,
          true,
        );
      } catch (e2) {
        emit(PrayerError('Namaz vakitleri yüklenemedi: ${e2.toString()}'));
      }
    }
  }
  
  /// GPS konum almayı dene - başarısız olursa null döner (hata fırlatmaz)
  Future<Position?> _tryGetGpsLocation() async {
    try {
      // Servis açık mı?
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('PrayerBloc: GPS services disabled');
        return null;
      }
      
      // İzin kontrol
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          debugPrint('PrayerBloc: GPS permission denied');
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('PrayerBloc: GPS permission denied forever');
        return null;
      }
      
      // Konum al
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: kIsWeb ? LocationAccuracy.low : LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('PrayerBloc: GPS error: $e');
      return null;
    }
  }
  
  Future<void> _onFetchPrayerTimesWithLocation(
    FetchPrayerTimesWithLocation event, 
    Emitter<PrayerState> emit,
  ) async {
    emit(PrayerLoading());
    
    String cityName = event.cityName ?? 'Seçilen Konum';
    
    if (event.cityName == null) {
      final geocodingResult = await geocodingService.reverseGeocode(
        event.latitude, 
        event.longitude,
      );
      cityName = geocodingResult?.formattedName ?? 'Seçilen Konum';
    }
    
    await _fetchAndEmitPrayerTimes(
      emit,
      event.latitude,
      event.longitude,
      cityName,
      false,
    );
  }
  
  Future<void> _fetchAndEmitPrayerTimes(
    Emitter<PrayerState> emit,
    double latitude,
    double longitude,
    String cityName,
    bool isApproximate,
  ) async {
    try {
      final method = await userPrefs.getCalculationMethod();
      debugPrint('PrayerBloc: Fetching prayer times for $cityName (method: $method, approx: $isApproximate)');
      
      final result = await getPrayerTimes(PrayerParams(
        latitude: latitude,
        longitude: longitude,
        method: method ?? 13, // Default: Diyanet method
        date: DateTime.now(),
      ));
      
      result.fold(
        (failure) {
          debugPrint('PrayerBloc: API error - ${failure.message}');
          emit(PrayerError('Namaz vakitleri alınamadı: ${failure.message}'));
        },
        (prayerTime) {
          debugPrint('PrayerBloc: Prayer times loaded for $cityName');
          emit(PrayerLoaded(
            prayerTime, 
            cityName,
            latitude: latitude,
            longitude: longitude,
            isApproximateLocation: isApproximate,
          ));
        },
      );
    } catch (e) {
      debugPrint('PrayerBloc: Error fetching prayer times: $e');
      emit(PrayerError('Bir hata oluştu: ${e.toString()}'));
    }
  }
}
