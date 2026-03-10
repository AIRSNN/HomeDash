/// MADAM Projesi - Yerel Dosya Loglama Servisi
/// Başlangıç: Faz 6 (Gelişmiş Hata Tanılama ve Günlükleme)
/// Açıklama: DashboardState üzerinden gelen sistem ve cihaz loglarını kuyruk (queue) mimarisiyle asenkron çakışmaları (race condition) önleyerek diske yazar.
import 'dart:io';

class LoggingService {
  // Singleton Pattern
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  // Çakışmaları önlemek için yazma kuyruğu
  final List<String> _writeQueue = [];
  bool _isWriting = false;

  String get _logDirectory {
    final dir = Directory('${Directory.current.path}/logs');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir.path;
  }

  String get _currentLogFilePath {
    final now = DateTime.now();
    final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return '$_logDirectory/madam_log_$dateString.txt';
  }

  /// Logu doğrudan diske yazmak yerine güvenli kuyruğa (Queue) ekler
  void writeLog(String category, String message) {
    final now = DateTime.now();
    final timeStr = now.toIso8601String().substring(11, 19);
    final logLine = '[$timeStr] [$category] $message\n';
    
    _writeQueue.add(logLine);
    _processQueue(); // Kuyruğu eritmeyi başlat
  }

  /// Kuyruktaki verileri sırayla ve toplu olarak diske yazar (Çakışmayı önler)
  Future<void> _processQueue() async {
    if (_isWriting || _writeQueue.isEmpty) return;
    _isWriting = true;

    try {
      final file = File(_currentLogFilePath);
      final buffer = StringBuffer();
      
      // Kuyruktaki tüm hazır logları tek bir buffera al (Performans artışı)
      while (_writeQueue.isNotEmpty) {
        buffer.write(_writeQueue.removeAt(0));
      }
      
      // Tek seferde dosyaya ekle
      await file.writeAsString(buffer.toString(), mode: FileMode.append, flush: true);
    } catch (e) {
      print('LOG YAZMA HATASI: $e');
    } finally {
      _isWriting = false;
      // Biz yazarken yeni log geldiyse döngüyü tekrar tetikle
      if (_writeQueue.isNotEmpty) {
        _processQueue();
      }
    }
  }

  /// Belirli bir günün loglarını okur (Library UI için)
  Future<List<String>> readLogs(DateTime date) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final file = File('$_logDirectory/madam_log_$dateString.txt');
      
      if (await file.exists()) {
        return await file.readAsLines();
      }
      return ['[$dateString] Bu tarihe ait sistem kaydı bulunamadı.'];
    } catch (e) {
      return ['Log dosyası okunurken hata oluştu: $e'];
    }
  }
}