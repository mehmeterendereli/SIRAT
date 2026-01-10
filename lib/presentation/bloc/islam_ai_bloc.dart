import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../core/services/islam_ai_service.dart';
import '../../core/services/chat_history_repository.dart';

// ============ EVENTS ============

abstract class IslamAIEvent extends Equatable {
  const IslamAIEvent();
  @override
  List<Object?> get props => [];
}

class AskQuestion extends IslamAIEvent {
  final String question;
  final AIMode mode;
  
  const AskQuestion({required this.question, this.mode = AIMode.fetva});
  
  @override
  List<Object?> get props => [question, mode];
}

class ClearChat extends IslamAIEvent {}

class LoadChatHistory extends IslamAIEvent {}

// ============ STATES ============

abstract class IslamAIState extends Equatable {
  const IslamAIState();
  @override
  List<Object?> get props => [];
}

class IslamAIInitial extends IslamAIState {}

class IslamAILoading extends IslamAIState {}

class IslamAILoaded extends IslamAIState {
  final List<ChatMessage> messages;
  
  const IslamAILoaded(this.messages);
  
  @override
  List<Object?> get props => [messages];
}

class IslamAIError extends IslamAIState {
  final String message;
  
  const IslamAIError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// ============ CHAT MESSAGE MODEL ============

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AIMode? mode;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.mode,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ============ BLOC ============

@injectable
class IslamAIBloc extends Bloc<IslamAIEvent, IslamAIState> {
  final IslamAIService _aiService;
  final ChatHistoryRepository _historyRepository;
  final List<ChatMessage> _messages = [];
  String _currentMezhep = 'Hanefi';

  IslamAIBloc(this._aiService, this._historyRepository) : super(IslamAIInitial()) {
    on<AskQuestion>(_onAskQuestion);
    on<ClearChat>(_onClearChat);
    on<LoadChatHistory>(_onLoadChatHistory);
    
    // Otomatik olarak geçmiş yükle
    add(LoadChatHistory());
  }

  void setMezhep(String mezhep) {
    _currentMezhep = mezhep;
  }

  Future<void> _onLoadChatHistory(LoadChatHistory event, Emitter<IslamAIState> emit) async {
    try {
      final history = await _historyRepository.loadTodayMessages();
      if (history.isNotEmpty) {
        _messages.clear();
        _messages.addAll(history);
        emit(IslamAILoaded(List.from(_messages)));
      }
    } catch (e) {
      // Sessizce başarısız ol, kullanıcıyı etkileme
    }
  }

  Future<void> _onAskQuestion(AskQuestion event, Emitter<IslamAIState> emit) async {
    // Kullanıcı mesajını ekle
    final userMessage = ChatMessage(
      text: event.question,
      isUser: true,
      mode: event.mode,
    );
    _messages.add(userMessage);
    
    // Firestore'a kaydet (arka planda)
    _historyRepository.saveMessage(userMessage);
    
    emit(IslamAILoading());

    final response = await _aiService.askQuestion(
      question: event.question,
      mezhep: _currentMezhep,
      mode: event.mode,
    );

    if (response.isSuccess) {
      final aiMessage = ChatMessage(
        text: response.answer,
        isUser: false,
        mode: event.mode,
      );
      _messages.add(aiMessage);
      
      // Firestore'a kaydet (arka planda)
      _historyRepository.saveMessage(aiMessage);
      
      emit(IslamAILoaded(List.from(_messages)));
    } else {
      emit(IslamAIError(response.answer));
    }
  }

  Future<void> _onClearChat(ClearChat event, Emitter<IslamAIState> emit) async {
    _messages.clear();
    await _historyRepository.clearTodaySession();
    emit(IslamAIInitial());
  }
}

