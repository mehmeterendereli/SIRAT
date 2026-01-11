import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../core/services/quran_service.dart';

// =============================================================================
// EVENTS
// =============================================================================

abstract class QuranEvent extends Equatable {
  const QuranEvent();
  @override
  List<Object?> get props => [];
}

class LoadSurahs extends QuranEvent {}

class LoadSurah extends QuranEvent {
  final int surahNumber;
  const LoadSurah(this.surahNumber);
  @override
  List<Object?> get props => [surahNumber];
}

class SearchQuran extends QuranEvent {
  final String query;
  const SearchQuran(this.query);
  @override
  List<Object?> get props => [query];
}

class PlayAyah extends QuranEvent {
  final int ayahIndex;
  const PlayAyah(this.ayahIndex);
  @override
  List<Object?> get props => [ayahIndex];
}

class PauseAudio extends QuranEvent {}

class StopAudio extends QuranEvent {}

class ToggleBookmark extends QuranEvent {
  final int surahNumber;
  final int ayahNumber;
  const ToggleBookmark(this.surahNumber, this.ayahNumber);
  @override
  List<Object?> get props => [surahNumber, ayahNumber];
}

// =============================================================================
// STATES
// =============================================================================

abstract class QuranState extends Equatable {
  const QuranState();
  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class SurahsLoaded extends QuranState {
  final List<Surah> surahs;
  const SurahsLoaded(this.surahs);
  @override
  List<Object?> get props => [surahs];
}

class SurahDetailLoaded extends QuranState {
  final SurahDetail surah;
  final int? playingAyahIndex;
  final bool isPlaying;
  final Set<String> bookmarks; // "surah:ayah" format
  
  const SurahDetailLoaded({
    required this.surah,
    this.playingAyahIndex,
    this.isPlaying = false,
    this.bookmarks = const {},
  });
  
  @override
  List<Object?> get props => [surah, playingAyahIndex, isPlaying, bookmarks];
  
  SurahDetailLoaded copyWith({
    SurahDetail? surah,
    int? playingAyahIndex,
    bool? isPlaying,
    Set<String>? bookmarks,
  }) {
    return SurahDetailLoaded(
      surah: surah ?? this.surah,
      playingAyahIndex: playingAyahIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

class SearchResultsLoaded extends QuranState {
  final List<SearchResult> results;
  final String query;
  const SearchResultsLoaded(this.results, this.query);
  @override
  List<Object?> get props => [results, query];
}

class QuranError extends QuranState {
  final String message;
  const QuranError(this.message);
  @override
  List<Object?> get props => [message];
}

// =============================================================================
// BLOC
// =============================================================================

@injectable
class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranService _quranService;
  final Set<String> _bookmarks = {};
  
  QuranBloc(this._quranService) : super(QuranInitial()) {
    on<LoadSurahs>(_onLoadSurahs);
    on<LoadSurah>(_onLoadSurah);
    on<SearchQuran>(_onSearchQuran);
    on<PlayAyah>(_onPlayAyah);
    on<PauseAudio>(_onPauseAudio);
    on<StopAudio>(_onStopAudio);
    on<ToggleBookmark>(_onToggleBookmark);
  }

  Future<void> _onLoadSurahs(LoadSurahs event, Emitter<QuranState> emit) async {
    emit(QuranLoading());
    
    final surahs = await _quranService.getSurahs();
    if (surahs.isNotEmpty) {
      emit(SurahsLoaded(surahs));
    } else {
      emit(const QuranError('Sureler yüklenemedi'));
    }
  }

  Future<void> _onLoadSurah(LoadSurah event, Emitter<QuranState> emit) async {
    emit(QuranLoading());
    
    final surah = await _quranService.getSurah(surahNumber: event.surahNumber);
    if (surah != null) {
      emit(SurahDetailLoaded(surah: surah, bookmarks: _bookmarks));
    } else {
      emit(const QuranError('Sure yüklenemedi'));
    }
  }

  Future<void> _onSearchQuran(SearchQuran event, Emitter<QuranState> emit) async {
    if (event.query.trim().isEmpty) return;
    
    emit(QuranLoading());
    
    final results = await _quranService.search(query: event.query);
    emit(SearchResultsLoaded(results, event.query));
  }

  void _onPlayAyah(PlayAyah event, Emitter<QuranState> emit) {
    final currentState = state;
    if (currentState is SurahDetailLoaded) {
      emit(currentState.copyWith(
        playingAyahIndex: event.ayahIndex,
        isPlaying: true,
      ));
    }
  }

  void _onPauseAudio(PauseAudio event, Emitter<QuranState> emit) {
    final currentState = state;
    if (currentState is SurahDetailLoaded) {
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  void _onStopAudio(StopAudio event, Emitter<QuranState> emit) {
    final currentState = state;
    if (currentState is SurahDetailLoaded) {
      emit(SurahDetailLoaded(
        surah: currentState.surah,
        playingAyahIndex: null,
        isPlaying: false,
        bookmarks: currentState.bookmarks,
      ));
    }
  }

  void _onToggleBookmark(ToggleBookmark event, Emitter<QuranState> emit) {
    final key = '${event.surahNumber}:${event.ayahNumber}';
    
    if (_bookmarks.contains(key)) {
      _bookmarks.remove(key);
    } else {
      _bookmarks.add(key);
    }
    
    final currentState = state;
    if (currentState is SurahDetailLoaded) {
      emit(currentState.copyWith(bookmarks: Set.from(_bookmarks)));
    }
  }
}
