/// MADAM Projesi - Sabit Ağ Ayarları
/// NOT: Bu dosya ağ sabitlerini barındırır ve değiştirilemez.
/// Değişiklik gerekirse önce '01_MADAM_HARDWARE_AND_NETWORK_SOT.md' dosyasına müracaat edin.

class NetworkConstants {
  // --- Değişmez Ağ Sabitleri ---
  static const String ssid = 'llama_iot';
  static const String password = 'testteam';
  static const String security = 'WPA2-PSK (AES)';
  static const String gateway = '192.168.55.1';
  static const String subnetMask = '255.255.255.0';
  
  static const String subnetPrefix = '192.168.55';
  
  // Dashboard Sunucu IP'si (Sadece 192.168.55.100 kullanılabilir)
  static const String serverIp = '192.168.55.100';

  // Haberleşme Sabitleri
  static const int apiPort = 8080;
  static const String contentType = 'application/json';
  static const int heartbeatIntervalSeconds = 60;
  
  // TODO: Gelecek fazlarda eklenecek JSON API endpoint yolları
  static const String endpointStatus = '/status';
  static const String endpointCommand = '/command';
}
