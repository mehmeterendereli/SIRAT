import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/usecases/get_prayer_times.dart';
import '../../core/services/location_service.dart';
import '../../data/repositories/user_preferences_repository.dart';

// Events
abstract class PrayerEvent extends Equatable {
  const PrayerEvent();
  @override
  List<Object> get props => [];
}

class FetchPrayerTimes extends PrayerEvent {}

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
  const PrayerLoaded(this.prayerTime, this.locationName);
  @override
  List<Object?> get props => [prayerTime, locationName];
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
  final UserPreferencesRepository userPrefs;

  PrayerBloc(this.getPrayerTimes, this.locationService, this.userPrefs) : super(PrayerInitial()) {
    on<FetchPrayerTimes>(_onFetchPrayerTimes);
  }

  Future<void> _onFetchPrayerTimes(FetchPrayerTimes event, Emitter<PrayerState> emit) async {
    emit(PrayerLoading());
    
    final position = await locationService.getCurrentLocation();
    if (position == null) {
      emit(const PrayerError('Konum izni alınamadı.'));
      return;
    }

    final method = await userPrefs.getCalculationMethod() ?? 13; // Default: Diyanet Turkey (Method 13)
    
    final result = await getPrayerTimes(PrayerParams(
      latitude: position.latitude,
      longitude: position.longitude,
      method: method,
      date: DateTime.now(),
    ));

    result.fold(
      (failure) => emit(PrayerError(failure.toString())),
      (prayerTime) => emit(PrayerLoaded(prayerTime, 'Mevcut Konum')),
    );
  }
}
