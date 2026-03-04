/// MADAM Projesi - Ping Servisi
import 'dart:io';
import '../models/ping_result.dart';
import '../config/network_constants.dart';

class PingService {
  /// Cihazın API portuna (8080) TCP socket açarak ping (erişilebilirlik) atar.
  /// İşlem asenkrondur ve UI'ı bloklamaz. Timeout korumalıdır.
  Future<PingResult> pingDevice(String ipAddress) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Belirlenen timeout süresince TCP Socket bağlantısı denenir
      final socket = await Socket.connect(
        ipAddress, 
        NetworkConstants.apiPort, 
        timeout: const Duration(seconds: 2),
      );
      
      stopwatch.stop();
      
      // Bağlantı başarılıysa hemen kapatılır. Maksat sadece ayakta olup olmadığını görmek.
      socket.destroy();
      
      return PingResult(
        ip: ipAddress, 
        rttMs: stopwatch.elapsedMilliseconds, 
        isSuccess: true,
      );
    } catch (e) {
      // Bağlantı reddedildi, timeout oldu veya ağa ulaşılamadı.
      stopwatch.stop();
      return PingResult(
        ip: ipAddress, 
        rttMs: 0, 
        isSuccess: false,
      );
    }
  }
}
