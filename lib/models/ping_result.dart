/// MADAM Projesi - Ping Sonuç Modeli
// TODO: Bu model her bir ping işleminin TTL, ms ve başarı oranını saklar

class PingResult {
  final String ip;
  final int rttMs;
  final bool isSuccess;

  // İleriki fazlarda fail counter, timestamp eklenebilir
  PingResult({
    required this.ip,
    required this.rttMs,
    required this.isSuccess,
  });
}
