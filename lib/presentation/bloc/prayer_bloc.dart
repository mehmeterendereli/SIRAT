import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/usecases/get_prayer_times.dart';
import '../../core/services/location_service.dart';
import '../../core/services/geocoding_service.dart';
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
  
  const PrayerLoaded(
    this.prayerTime, 
    this.locationName, {
    this.latitude,
    this.longitude,
  });
  
  @override
  List<Object?> get props => [prayerTime, locationName, latitude, longitude];
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

  PrayerBloc(
    this.getPrayerTimes, 
    this.locationService, 
    this.geocodingService,
    this.userPrefs,
  ) : super(PrayerInitial()) {
    on<FetchPrayerTimes>(_onFetchPrayerTimes);
    on<FetchPrayerTimesWithLocation>(_onFetchPrayerTimesWithLocation);
  }

  Future<void> _onFetchPrayerTimes(FetchPrayerTimes event, Emitter<PrayerState> emit) async {
    emit(PrayerLoading());
    
    Position? position;
    String? cityName;
    
    try {
      if (kIsWeb) {
        // Web-specific location handling
        debugPrint('PrayerBloc: Getting web location...');
        final permission = await Geolocator.checkPermission();
        
        if (permission == LocationPermission.denied) {
          final newPermission = await Geolocator.requestPermission();
          if (newPermission == LocationPermission.denied || 
              newPermission == LocationPermission.deniedForever) {
            emit(const PrayerError('Konum izni verilmedi'));
            return;
          }
        } else if (permission == LocationPermission.deniedForever) {
          emit(const PrayerError('Konum izni engellendi'));
          return;
        }
        
        // Get position with retry
        for (int i = 0; i < 3; i++) {
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 15),
              ),
            );
            if (position != null) break;
          } catch (e) {
            debugPrint('PrayerBloc: Web location attempt ${i + 1} failed: $e');
            if (i < 2) await Future.delayed(const Duration(seconds: 2));
          }
        }
      } else {
        position = await locationService.getCurrentLocation();
      }
      
      if (position == null) {
        emit(const PrayerError('Konum alınamadı'));
        return;
      }
      
      debugPrint('PrayerBloc: Got position: ${position.latitude}, ${position.longitude}');
      
      // Get city name via geocoding
      final geocodingResult = await geocodingService.reverseGeocode(
        position.latitude, 
        position.longitude,
      );
      cityName = geocodingResult?.formattedName ?? 'Konum belirlendi';
      debugPrint('PrayerBloc: Geocoding result: $cityName');
      
      // Fetch prayer times
      await _fetchAndEmitPrayerTimes(
        emit,
        position.latitude,
        position.longitude,
        cityName,
      );
      
    } catch (e) {
      debugPrint('PrayerBloc: Error - $e');
      emit(PrayerError('Hata: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchPrayerTimesWithLocation(
    FetchPrayerTimesWithLocation event, 
    Emitter<PrayerState> emit,
  ) async {
    emit(PrayerLoading());
    
    await _fetchAndEmitPrayerTimes(
      emit,
      event.latitude,
      event.longitude,
      event.cityName ?? 'Konum belirlendi',
    );
  }
  
  Future<void> _fetchAndEmitPrayerTimes(
    Emitter<PrayerState> emit,
    double latitude,
    double longitude,
    String locationName,
  ) async {
    try {
      final method = await userPrefs.getCalculationMethod() ?? 13; // Default: Diyanet Turkey
      
      debugPrint('PrayerBloc: Fetching prayer times for $latitude, $longitude (method: $method)');
      
      final result = await getPrayerTimes(PrayerParams(
        latitude: latitude,
        longitude: longitude,
        method: method,
        date: DateTime.now(),
      ));

      result.fold(
        (failure) => emit(PrayerError(failure.toString())),
        (prayerTime) => emit(PrayerLoaded(
          prayerTime, 
          locationName,
          latitude: latitude,
          longitude: longitude,
        )),
      );
    } catch (e) {
      emit(PrayerError('Vakit bilgisi alınamadı: ${e.toString()}'));
    }
  }
}
