import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Zikirmatik Service
/// Akıllı zikir sayacı, titreşim profilleri ve bulut senkronizasyonu.

@lazySingleton
class ZikirmatikService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Popüler zikirler
  static const List<ZikirType> defaultZikirs = [
    ZikirType(id: 'subhanallah', name: 'Sübhanallah', arabic: 'سُبْحَانَ اللَّه', target: 33),
    ZikirType(id: 'elhamdulillah', name: 'Elhamdülillah', arabic: 'الْحَمْدُ لِلَّه', target: 33),
    ZikirType(id: 'allahuekber', name: 'Allahu Ekber', arabic: 'اللَّهُ أَكْبَر', target: 33),
    ZikirType(id: 'lailaheillallah', name: 'La ilahe illallah', arabic: 'لَا إِلَٰهَ إِلَّا اللَّه', target: 100),
    ZikirType(id: 'salavat', name: 'Salavat', arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّد', target: 100),
    ZikirType(id: 'istigfar', name: 'İstiğfar', arabic: 'أَسْتَغْفِرُ اللَّه', target: 100),
    ZikirType(id: 'esmaul_husna', name: 'Esmaül Hüsna', arabic: 'يَا اللَّه', target: 99),
  ];

  /// Zikir sayısını artır
  Future<ZikirResult> incrementZikir(String zikirId, int currentCount) async {
    final newCount = currentCount + 1;
    final zikir = defaultZikirs.firstWhere((z) => z.id == zikirId);
    
    // Titreşim kontrolü
    await _handleVibration(newCount, zikir.target);
    
    // Local kaydet
    await _saveLocalCount(zikirId, newCount);
    
    // Cloud senkronizasyon
    await _syncToCloud(zikirId, newCount);

    // Rozet kontrolü
    final badge = _checkForBadge(zikirId, newCount);

    return ZikirResult(
      count: newCount,
      isTargetReached: newCount >= zikir.target,
      isMultipleOf33: newCount % 33 == 0,
      earnedBadge: badge,
    );
  }

  /// Titreşim profilleri
  Future<void> _handleVibration(int count, int target) async {
    if (count % 33 == 0) {
      // Her 33'te uzun titreşim
      await HapticFeedback.heavyImpact();
    } else if (count == target) {
      // Hedefe ulaşınca çift titreşim
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } else if (count % 10 == 0) {
      // Her 10'da hafif titreşim
      await HapticFeedback.lightImpact();
    } else {
      // Normal dokunuşta hafif feedback
      await HapticFeedback.selectionClick();
    }
  }

  /// Local kayıt
  Future<void> _saveLocalCount(String zikirId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('zikir_$zikirId', count);
    
    // Bugünün tarihiyle kaydet
    final today = DateTime.now().toIso8601String().split('T')[0];
    final dailyKey = 'zikir_${zikirId}_$today';
    final dailyCount = prefs.getInt(dailyKey) ?? 0;
    await prefs.setInt(dailyKey, dailyCount + 1);
  }

  /// Cloud senkronizasyon
  Future<void> _syncToCloud(String zikirId, int count) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('zikirs')
        .doc(zikirId)
        .set({
          'total': count,
          'lastUpdated': FieldValue.serverTimestamp(),
          'dailyCounts': {
            today: FieldValue.increment(1),
          },
        }, SetOptions(merge: true));
  }

  /// Rozet kontrolü
  String? _checkForBadge(String zikirId, int totalCount) {
    // Salavat için özel rozet
    if (zikirId == 'salavat') {
      if (totalCount == 1000) return '🌹 Gül Kokulu';
      if (totalCount == 10000) return '🏆 Salavat Ustası';
    }
    
    // Genel rozetler
    if (totalCount == 1000) return '⭐ Bin Zikir';
    if (totalCount == 10000) return '🌟 On Bin Zikir';
    if (totalCount == 100000) return '💎 Zikir Şampiyonu';
    
    return null;
  }

  /// Bugünkü istatistikleri getir
  Future<DailyStats> getDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    int totalToday = 0;
    Map<String, int> breakdown = {};
    
    for (final zikir in defaultZikirs) {
      final count = prefs.getInt('zikir_${zikir.id}_$today') ?? 0;
      totalToday += count;
      if (count > 0) {
        breakdown[zikir.name] = count;
      }
    }
    
    return DailyStats(
      totalToday: totalToday,
      breakdown: breakdown,
      date: today,
    );
  }

  /// Zikir sayısını sıfırla
  Future<void> resetZikir(String zikirId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('zikir_$zikirId', 0);
  }

  /// Cloud'dan toplam sayıları çek
  Future<Map<String, int>> getCloudTotals() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('zikirs')
        .get();

    return {
      for (final doc in snapshot.docs)
        doc.id: (doc.data()['total'] as int?) ?? 0,
    };
  }
}

/// Zikir türü modeli
class ZikirType {
  final String id;
  final String name;
  final String arabic;
  final int target;

  const ZikirType({
    required this.id,
    required this.name,
    required this.arabic,
    required this.target,
  });
}

/// Zikir sonucu modeli
class ZikirResult {
  final int count;
  final bool isTargetReached;
  final bool isMultipleOf33;
  final String? earnedBadge;

  ZikirResult({
    required this.count,
    required this.isTargetReached,
    required this.isMultipleOf33,
    this.earnedBadge,
  });
}

/// Günlük istatistik modeli
class DailyStats {
  final int totalToday;
  final Map<String, int> breakdown;
  final String date;

  DailyStats({
    required this.totalToday,
    required this.breakdown,
    required this.date,
  });
}
