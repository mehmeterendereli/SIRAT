import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

/// Content Service for Dynamic Dashboard (Daily Verse, Hadith, etc)
/// Fetches content from Firestore to avoid mock data.

@lazySingleton
class DailyContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDailyContent(String type, String lang) async {
    try {
      final doc = await _firestore.collection('daily_content')
          .doc('${type}_$lang')
          .get();
      
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Stream<QuerySnapshot> getDailyStoriesStream() {
    return _firestore.collection('daily_content').snapshots();
  }
}
