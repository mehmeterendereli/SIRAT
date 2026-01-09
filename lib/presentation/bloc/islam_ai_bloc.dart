import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../core/services/islam_ai_service.dart';

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
  final List<ChatMessage> _messages = [];
  String _currentMezhep = 'Hanefi';

  IslamAIBloc(this._aiService) : super(IslamAIInitial()) {
    on<AskQuestion>(_onAskQuestion);
    on<ClearChat>(_onClearChat);
  }

  void setMezhep(String mezhep) {
    _currentMezhep = mezhep;
  }

  Future<void> _onAskQuestion(AskQuestion event, Emitter<IslamAIState> emit) async {
    // Kullanıcı mesajını ekle
    _messages.add(ChatMessage(
      text: event.question,
      isUser: true,
      mode: event.mode,
    ));
    
    emit(IslamAILoading());

    final response = await _aiService.askQuestion(
      question: event.question,
      mezhep: _currentMezhep,
      mode: event.mode,
    );

    if (response.isSuccess) {
      _messages.add(ChatMessage(
        text: response.answer,
        isUser: false,
        mode: event.mode,
      ));
      emit(IslamAILoaded(List.from(_messages)));
    } else {
      emit(IslamAIError(response.answer));
    }
  }

  void _onClearChat(ClearChat event, Emitter<IslamAIState> emit) {
    _messages.clear();
    emit(IslamAIInitial());
  }
}
