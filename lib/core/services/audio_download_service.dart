import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'quran_service.dart';

/// =============================================================================
/// AUDIO DOWNLOAD SERVICE - Offline Audio Yöneticisi
/// =============================================================================

@lazySingleton
class AudioDownloadService {
  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();
  
  // İndirme durumu: {surahId: progress (0.0 - 1.0)}
  final Map<int, double> _downloadProgress = {};
  // İndirme iptal tokenları
  final Map<int, CancelToken> _cancelTokens = {};
  
  // Ayar anahtarları
  static const String PREF_WIFI_ONLY = 'download_wifi_only';

  /// Sureyi indir
  /// [onProgress]: İlerleme callback'i (0.0 - 1.0)
  Future<void> downloadSurah({
    required int surahId, 
    required List<Ayah> ayahs,
    Function(double)? onProgress,
  }) async {
    // 1. Wi-Fi kontrolü
    if (await _shouldRestrictDownload()) {
      throw Exception('Sadece Wi-Fi ile indirme açık ve şu an Wi-Fi bağlı değil.');
    }

    // 2. Klasör oluştur
    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory('${dir.path}/quran_audio/$surahId');
    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }

    _cancelTokens[surahId] = CancelToken();
    int downloadedCount = 0;
    int totalAyahs = ayahs.where((a) => a.audioUrl != null).length;

    try {
      // 3. Ayetleri indir (Batch processing could be added for speed)
      for (var ayah in ayahs) {
        if (_cancelTokens[surahId]?.isCancelled ?? false) break;
        if (ayah.audioUrl == null) continue;

        final fileName = '${ayah.number}.mp3';
        final savePath = '${surahDir.path}/$fileName';

        // Dosya zaten varsa geç
        if (await File(savePath).exists()) {
          downloadedCount++;
          _updateProgress(surahId, downloadedCount, totalAyahs, onProgress);
          continue;
        }

        await _dio.download(
          ayah.audioUrl!,
          savePath,
          cancelToken: _cancelTokens[surahId],
        );

        downloadedCount++;
        _updateProgress(surahId, downloadedCount, totalAyahs, onProgress);
      }
    } catch (e) {
      // Hata durumunda temizlik yapılabilir veya kalınan yerden devam mekanizması
      rethrow;
    } finally {
      _cancelTokens.remove(surahId);
      _downloadProgress.remove(surahId);
    }
  }

  void _updateProgress(int surahId, int current, int total, Function(double)? callback) {
    double progress = total > 0 ? current / total : 0.0;
    _downloadProgress[surahId] = progress;
    if (callback != null) callback(progress);
  }

  /// İndirmeyi iptal et
  void cancelDownload(int surahId) {
    _cancelTokens[surahId]?.cancel();
    _cancelTokens.remove(surahId);
    _downloadProgress.remove(surahId);
  }

  /// İndirilmiş sureyi sil
  Future<void> deleteSurah(int surahId) async {
    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory('${dir.path}/quran_audio/$surahId');
    if (await surahDir.exists()) {
      await surahDir.delete(recursive: true);
    }
  }

  /// Sure indirilmiş mi kontrol et (Basit kontrol: Klasör var mı?)
  /// Daha detaylı kontrol için tüm dosyalar sayılabilir
  Future<bool> isSurahDownloaded(int surahId) async {
    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory('${dir.path}/quran_audio/$surahId');
    return await surahDir.exists();
  }
  
  /// Yerel ses dosyası yolunu getir
  Future<String?> getLocalAudioPath(int surahId, int ayahNumber) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/quran_audio/$surahId/$ayahNumber.mp3';
    if (await File(path).exists()) {
      return path;
    }
    return null;
  }

  /// Wi-Fi kısıtlaması var mı?
  Future<bool> _shouldRestrictDownload() async {
    final prefs = await SharedPreferences.getInstance();
    final wifiOnly = prefs.getBool(PREF_WIFI_ONLY) ?? true; // Varsayılan: True
    
    if (!wifiOnly) return false;

    final connectivityResult = await _connectivity.checkConnectivity();
    // ignore: collection_methods_unrelated_type
    return !connectivityResult.contains(ConnectivityResult.wifi); 
  }

  /// İndirme durumu sorgula
  double? getDownloadProgress(int surahId) => _downloadProgress[surahId];
}
