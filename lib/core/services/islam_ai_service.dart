import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

/// İslam-AI Service
/// Gemini Pro ile entegre akıllı İslami asistan servisi.

enum AIMode { fetva, teselli, ibadet }

@lazySingleton
class IslamAIService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Ana soru-cevap metodu
  Future<AIResponse> askQuestion({
    required String question,
    required String mezhep,
    AIMode mode = AIMode.fetva,
  }) async {
    // Analytics event
    await _analytics.logEvent(
      name: 'ai_question_asked',
      parameters: {
        'mode': mode.name,
        'mezhep': mezhep,
        'question_length': question.length,
      },
    );

    try {
      final callable = _functions.httpsCallable('askIslamicAI');
      final result = await callable.call<Map<String, dynamic>>({
        'question': question,
        'mezhep': mezhep,
        'mode': mode.name.toUpperCase(),
      });

      final data = result.data;
      
      return AIResponse(
        answer: data['answer'] ?? '',
        mode: mode,
        mezhep: mezhep,
        isFiltered: data['filtered'] ?? false,
        isSuccess: true,
      );
    } on FirebaseFunctionsException catch (e) {
      await _analytics.logEvent(
        name: 'ai_error',
        parameters: {'code': e.code, 'message': e.message},
      );
      
      return AIResponse(
        answer: _getErrorMessage(e.code),
        mode: mode,
        mezhep: mezhep,
        isFiltered: false,
        isSuccess: false,
        errorCode: e.code,
      );
    }
  }

  /// Günlük ilham içeriği
  Future<DailyInsight?> getDailyInsight({
    String type = 'hadis',
    String lang = 'tr',
  }) async {
    try {
      final callable = _functions.httpsCallable('getDailyInsight');
      final result = await callable.call<Map<String, dynamic>>({
        'type': type,
        'lang': lang,
      });

      final data = result.data;
      return DailyInsight(
        content: data['content'] ?? '',
        type: type,
        date: data['date'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'unauthenticated':
        return 'Bu özelliği kullanmak için giriş yapmalısınız.';
      case 'invalid-argument':
        return 'Lütfen geçerli bir soru girin.';
      case 'internal':
        return 'Yapay zeka şu an meşgul. Lütfen biraz sonra tekrar deneyin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}

/// AI Cevap modeli
class AIResponse {
  final String answer;
  final AIMode mode;
  final String mezhep;
  final bool isFiltered;
  final bool isSuccess;
  final String? errorCode;

  AIResponse({
    required this.answer,
    required this.mode,
    required this.mezhep,
    required this.isFiltered,
    required this.isSuccess,
    this.errorCode,
  });
}

/// Günlük İlham modeli
class DailyInsight {
  final String content;
  final String type;
  final String date;

  DailyInsight({
    required this.content,
    required this.type,
    required this.date,
  });
}
