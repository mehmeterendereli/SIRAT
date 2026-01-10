import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../presentation/bloc/islam_ai_bloc.dart';
import 'islam_ai_service.dart';

/// =============================================================================
/// CHAT HISTORY REPOSITORY
/// =============================================================================
/// 
/// Firestore'da AI chat geçmişini saklar ve yükler.
/// Kullanıcı bazlı izolasyon sağlar.

@lazySingleton
class ChatHistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Kullanıcının chat koleksiyonu referansı
  CollectionReference<Map<String, dynamic>>? _getChatCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ai_chats');
  }
  
  /// Mevcut oturumun ID'si (günlük bazda)
  String _getSessionId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  /// Mesaj kaydet
  Future<void> saveMessage(ChatMessage message) async {
    final collection = _getChatCollection();
    if (collection == null) return; // Giriş yapılmamış
    
    final sessionId = _getSessionId();
    
    await collection.doc(sessionId).set({
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    await collection
        .doc(sessionId)
        .collection('messages')
        .add({
          'text': message.text,
          'isUser': message.isUser,
          'timestamp': Timestamp.fromDate(message.timestamp),
          'mode': message.mode?.name,
        });
  }
  
  /// Bugünün mesajlarını yükle
  Future<List<ChatMessage>> loadTodayMessages() async {
    final collection = _getChatCollection();
    if (collection == null) return [];
    
    final sessionId = _getSessionId();
    
    try {
      final snapshot = await collection
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          text: data['text'] ?? '',
          isUser: data['isUser'] ?? true,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
          mode: _parseMode(data['mode']),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Son 7 günün oturumlarını listele
  Future<List<ChatSession>> loadRecentSessions() async {
    final collection = _getChatCollection();
    if (collection == null) return [];
    
    try {
      final snapshot = await collection
          .orderBy('lastUpdated', descending: true)
          .limit(7)
          .get();
      
      return snapshot.docs.map((doc) => ChatSession(
        sessionId: doc.id,
        lastUpdated: (doc.data()['lastUpdated'] as Timestamp?)?.toDate(),
      )).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Belirli bir oturumun mesajlarını yükle
  Future<List<ChatMessage>> loadSessionMessages(String sessionId) async {
    final collection = _getChatCollection();
    if (collection == null) return [];
    
    try {
      final snapshot = await collection
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          text: data['text'] ?? '',
          isUser: data['isUser'] ?? true,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
          mode: _parseMode(data['mode']),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Bugünün oturumunu temizle
  Future<void> clearTodaySession() async {
    final collection = _getChatCollection();
    if (collection == null) return;
    
    final sessionId = _getSessionId();
    final messagesRef = collection.doc(sessionId).collection('messages');
    
    final snapshot = await messagesRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
  
  AIMode? _parseMode(String? mode) {
    if (mode == null) return null;
    switch (mode.toLowerCase()) {
      case 'fetva': return AIMode.fetva;
      case 'teselli': return AIMode.teselli;
      case 'ibadet': return AIMode.ibadet;
      default: return null;
    }
  }
}

/// Chat oturumu bilgisi
class ChatSession {
  final String sessionId;
  final DateTime? lastUpdated;
  
  ChatSession({
    required this.sessionId,
    this.lastUpdated,
  });
  
  /// Oturum tarihini formatla (örn: "11 Ocak 2026")
  String get formattedDate {
    final parts = sessionId.split('-');
    if (parts.length == 3) {
      final months = [
        '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
      ];
      final day = int.tryParse(parts[2]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 0;
      final year = parts[0];
      return '$day ${months[month]} $year';
    }
    return sessionId;
  }
}
