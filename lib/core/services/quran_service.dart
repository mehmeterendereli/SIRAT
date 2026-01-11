import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// =============================================================================
/// QURAN SERVICE - Kuran-ı Kerim API Servisi
/// =============================================================================
/// 
/// alquran.cloud API ile entegrasyon
/// - Sure listesi
/// - Ayet metinleri (Arapça + Meal)
/// - Audio URL'leri
/// - Arama özelliği

@lazySingleton
class QuranService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  
  // Hafız sesleri
  static const Map<String, String> reciters = {
    'ar.alafasy': 'Mishary Rashid Alafasy',
    'ar.abdulbasitmurattal': 'Abdul Basit (Murattal)',
    'ar.abdulsamad': 'Abdul Samad',
    'ar.hudhaify': 'Ali Al-Hudhaify',
    'ar.minshawi': 'Mohamed Siddiq El-Minshawi',
  };
  
  // Türkçe meal editions
  static const Map<String, String> turkishEditions = {
    'tr.diyanet': 'Diyanet İşleri',
    'tr.yazir': 'Elmalılı Hamdi Yazır',
    'tr.ozturk': 'Yaşar Nuri Öztürk',
  };

  /// Tüm sureleri getir
  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surah'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List surahs = data['data'];
        return surahs.map((s) => Surah.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Belirli bir sureyi getir (Arapça + Meal + Audio)
  Future<SurahDetail?> getSurah({
    required int surahNumber,
    String edition = 'quran-uthmani',
    String mealEdition = 'tr.diyanet',
    String audioEdition = 'ar.alafasy',
  }) async {
    try {
      // Parallel requests for Arabic, Turkish, and Audio
      final responses = await Future.wait([
        http.get(Uri.parse('$_baseUrl/surah/$surahNumber/$edition')),
        http.get(Uri.parse('$_baseUrl/surah/$surahNumber/$mealEdition')),
        http.get(Uri.parse('$_baseUrl/surah/$surahNumber/$audioEdition')),
      ]);
      
      if (responses.every((r) => r.statusCode == 200)) {
        final arabicData = json.decode(responses[0].body)['data'];
        final turkishData = json.decode(responses[1].body)['data'];
        final audioData = json.decode(responses[2].body)['data'];
        
        final List arabicAyahs = arabicData['ayahs'];
        final List turkishAyahs = turkishData['ayahs'];
        final List audioAyahs = audioData['ayahs'];
        
        final ayahs = <Ayah>[];
        for (int i = 0; i < arabicAyahs.length; i++) {
          ayahs.add(Ayah(
            number: arabicAyahs[i]['numberInSurah'],
            numberInQuran: arabicAyahs[i]['number'],
            arabic: arabicAyahs[i]['text'],
            turkish: i < turkishAyahs.length ? turkishAyahs[i]['text'] : '',
            audioUrl: i < audioAyahs.length ? audioAyahs[i]['audio'] : null,
            juz: arabicAyahs[i]['juz'],
            page: arabicAyahs[i]['page'],
            hizbQuarter: arabicAyahs[i]['hizbQuarter'],
          ));
        }
        
        return SurahDetail(
          number: arabicData['number'],
          name: arabicData['name'],
          englishName: arabicData['englishName'],
          englishNameTranslation: arabicData['englishNameTranslation'],
          revelationType: arabicData['revelationType'],
          numberOfAyahs: arabicData['numberOfAyahs'],
          ayahs: ayahs,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Belirli bir ayeti getir
  Future<Ayah?> getAyah({
    required int surahNumber,
    required int ayahNumber,
    String mealEdition = 'tr.diyanet',
    String audioEdition = 'ar.alafasy',
  }) async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$_baseUrl/ayah/$surahNumber:$ayahNumber/quran-uthmani')),
        http.get(Uri.parse('$_baseUrl/ayah/$surahNumber:$ayahNumber/$mealEdition')),
        http.get(Uri.parse('$_baseUrl/ayah/$surahNumber:$ayahNumber/$audioEdition')),
      ]);
      
      if (responses.every((r) => r.statusCode == 200)) {
        final arabicData = json.decode(responses[0].body)['data'];
        final turkishData = json.decode(responses[1].body)['data'];
        final audioData = json.decode(responses[2].body)['data'];
        
        return Ayah(
          number: arabicData['numberInSurah'],
          numberInQuran: arabicData['number'],
          arabic: arabicData['text'],
          turkish: turkishData['text'],
          audioUrl: audioData['audio'],
          juz: arabicData['juz'],
          page: arabicData['page'],
          hizbQuarter: arabicData['hizbQuarter'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Kuran'da arama yap
  Future<List<SearchResult>> search({
    required String query,
    String edition = 'tr.diyanet',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/$query/$edition'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          final List matches = data['data']['matches'];
          return matches.map((m) => SearchResult.fromJson(m)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Jüz (cüz) getir
  Future<List<Ayah>> getJuz({
    required int juzNumber,
    String mealEdition = 'tr.diyanet',
  }) async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$_baseUrl/juz/$juzNumber/quran-uthmani')),
        http.get(Uri.parse('$_baseUrl/juz/$juzNumber/$mealEdition')),
      ]);
      
      if (responses.every((r) => r.statusCode == 200)) {
        final arabicData = json.decode(responses[0].body)['data'];
        final turkishData = json.decode(responses[1].body)['data'];
        
        final List arabicAyahs = arabicData['ayahs'];
        final List turkishAyahs = turkishData['ayahs'];
        
        final ayahs = <Ayah>[];
        for (int i = 0; i < arabicAyahs.length; i++) {
          ayahs.add(Ayah(
            number: arabicAyahs[i]['numberInSurah'],
            numberInQuran: arabicAyahs[i]['number'],
            arabic: arabicAyahs[i]['text'],
            turkish: i < turkishAyahs.length ? turkishAyahs[i]['text'] : '',
            juz: juzNumber,
            page: arabicAyahs[i]['page'],
            hizbQuarter: arabicAyahs[i]['hizbQuarter'],
            surahNumber: arabicAyahs[i]['surah']['number'],
            surahName: arabicAyahs[i]['surah']['name'],
          ));
        }
        return ayahs;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

/// =============================================================================
/// MODELS
/// =============================================================================

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
    );
  }
  
  /// Türkçe sure isimleri
  String get turkishName {
    const names = {
      1: 'Fatiha', 2: 'Bakara', 3: 'Âl-i İmran', 4: 'Nisa', 5: 'Mâide',
      6: 'En\'âm', 7: 'A\'râf', 8: 'Enfâl', 9: 'Tevbe', 10: 'Yûnus',
      11: 'Hûd', 12: 'Yûsuf', 13: 'Ra\'d', 14: 'İbrahim', 15: 'Hicr',
      16: 'Nahl', 17: 'İsrâ', 18: 'Kehf', 19: 'Meryem', 20: 'Tâ-Hâ',
      21: 'Enbiyâ', 22: 'Hac', 23: 'Mü\'minûn', 24: 'Nûr', 25: 'Furkân',
      26: 'Şuarâ', 27: 'Neml', 28: 'Kasas', 29: 'Ankebût', 30: 'Rûm',
      // ... diğer sureler için de eklenebilir
    };
    return names[number] ?? englishName;
  }
  
  /// Mekki mi Medeni mi
  bool get isMakki => revelationType == 'Meccan';
}

class SurahDetail {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<Ayah> ayahs;

  SurahDetail({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
  });
}

class Ayah {
  final int number;
  final int numberInQuran;
  final String arabic;
  final String turkish;
  final String? audioUrl;
  final int juz;
  final int page;
  final int hizbQuarter;
  final int? surahNumber;
  final String? surahName;

  Ayah({
    required this.number,
    required this.numberInQuran,
    required this.arabic,
    required this.turkish,
    this.audioUrl,
    required this.juz,
    required this.page,
    required this.hizbQuarter,
    this.surahNumber,
    this.surahName,
  });
}

class SearchResult {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String text;

  SearchResult({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.text,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      surahNumber: json['surah']['number'],
      surahName: json['surah']['name'],
      ayahNumber: json['numberInSurah'],
      text: json['text'],
    );
  }
}
