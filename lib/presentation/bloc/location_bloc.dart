import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../core/services/location_service.dart';
import '../../core/services/geocoding_service.dart';

// ==================== EVENTS ====================

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

/// Fetch current location and city name
class FetchLocation extends LocationEvent {}

/// Refresh location (retry)
class RefreshLocation extends LocationEvent {}

// ==================== STATE ====================

enum LocationStatus { initial, loading, success, error }

class LocationState extends Equatable {
  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final String? cityName; // "Kadıköy, İstanbul" or null
  final String? errorMessage;
  
  const LocationState({
    this.status = LocationStatus.initial,
    this.latitude,
    this.longitude,
    this.cityName,
    this.errorMessage,
  });
  
  /// Check if location coordinates are available
  bool get hasCoordinates => latitude != null && longitude != null;
  
  /// Get display name for UI
  String get displayName {
    if (status == LocationStatus.loading) {
      return 'Konum alınıyor...';
    }
    if (cityName != null && cityName!.isNotEmpty) {
      return cityName!;
    }
    if (hasCoordinates) {
      return '${latitude!.toStringAsFixed(2)}°, ${longitude!.toStringAsFixed(2)}°';
    }
    if (status == LocationStatus.error) {
      return errorMessage ?? 'Konum izni gerekli';
    }
    return 'Konum izni gerekli';
  }
  
  LocationState copyWith({
    LocationStatus? status,
    double? latitude,
    double? longitude,
    String? cityName,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
  
  @override
  List<Object?> get props => [status, latitude, longitude, cityName, errorMessage];
}

// ==================== BLOC ====================

@injectable
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  final GeocodingService _geocodingService;
  
  LocationBloc(this._locationService, this._geocodingService) 
      : super(const LocationState()) {
    on<FetchLocation>(_onFetchLocation);
    on<RefreshLocation>(_onRefreshLocation);
  }
  
  Future<void> _onFetchLocation(FetchLocation event, Emitter<LocationState> emit) async {
    // Only fetch if not already successful
    if (state.status == LocationStatus.success && state.hasCoordinates) {
      debugPrint('LocationBloc: Skipping fetch - already have location');
      return;
    }
    await _fetchLocationInternal(emit);
  }
  
  Future<void> _onRefreshLocation(RefreshLocation event, Emitter<LocationState> emit) async {
    // Force refresh even if already have location
    await _fetchLocationInternal(emit);
  }
  
  Future<void> _fetchLocationInternal(Emitter<LocationState> emit) async {
    emit(state.copyWith(status: LocationStatus.loading, clearError: true));
    
    try {
      Position? position;
      
      if (kIsWeb) {
        // Web-specific handling
        debugPrint('LocationBloc: Checking web location permission...');
        final permission = await Geolocator.checkPermission();
        
        if (permission == LocationPermission.denied) {
          final newPermission = await Geolocator.requestPermission();
          if (newPermission == LocationPermission.denied || 
              newPermission == LocationPermission.deniedForever) {
            emit(state.copyWith(
              status: LocationStatus.error,
              errorMessage: 'Konum izni verilmedi',
            ));
            return;
          }
        } else if (permission == LocationPermission.deniedForever) {
          emit(state.copyWith(
            status: LocationStatus.error,
            errorMessage: 'Konum izni engellendi',
          ));
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
            debugPrint('LocationBloc: Web attempt ${i + 1} failed: $e');
            if (i < 2) await Future.delayed(const Duration(seconds: 2));
          }
        }
      } else {
        // Mobile - use location service
        position = await _locationService.getCurrentLocation();
      }
      
      if (position == null) {
        emit(state.copyWith(
          status: LocationStatus.error,
          errorMessage: 'Konum alınamadı',
        ));
        return;
      }
      
      debugPrint('LocationBloc: Got position: ${position.latitude}, ${position.longitude}');
      
      // Emit with coordinates first (show coordinates while geocoding)
      emit(state.copyWith(
        status: LocationStatus.loading,
        latitude: position.latitude,
        longitude: position.longitude,
      ));
      
      // Reverse geocode to get city name
      final geocodingResult = await _geocodingService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      
      final cityName = geocodingResult?.formattedName;
      debugPrint('LocationBloc: Geocoding result: $cityName');
      
      emit(state.copyWith(
        status: LocationStatus.success,
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      ));
      
    } catch (e) {
      debugPrint('LocationBloc: Error - $e');
      emit(state.copyWith(
        status: LocationStatus.error,
        errorMessage: 'Konum hatası: ${e.toString()}',
      ));
    }
  }
}
