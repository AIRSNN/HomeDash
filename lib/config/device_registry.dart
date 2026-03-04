/// MADAM Projesi - Donanım Envanteri
/// NOT: Bu dosya bilinen statik cihaz listesini (IP ve Roller) barındırır ve değiştirilemez.
/// Değişiklik gerekirse '01_MADAM_HARDWARE_AND_NETWORK_SOT.md' dosyasına müracaat edin.

import '../models/device_info.dart';

class DeviceRegistry {
  // --- Değişmez Statik ESP Cihaz Listesi (192.168.55.20 - 192.168.55.29) ---
  static List<DeviceInfo> getKnownDevices() {
    return [
      DeviceInfo(id: 'Cihaz 1', ip: '192.168.55.20', role: 'Sensör / Aktüatör Node'),
      DeviceInfo(id: 'Cihaz 2', ip: '192.168.55.21', role: 'Sensör / Aktüatör Node'),
      DeviceInfo(id: 'Cihaz 3', ip: '192.168.55.22', role: 'Sensör / Aktüatör Node'),
      DeviceInfo(id: 'Cihaz 4', ip: '192.168.55.23', role: 'Sensör / Aktüatör Node'),
      DeviceInfo(id: 'Cihaz 5', ip: '192.168.55.24', role: 'Sensör / Aktüatör Node'),
      DeviceInfo(id: 'Cihaz 6', ip: '192.168.55.25', role: 'Sensör / Aktüatör Node'),
      DeviceInfo(id: 'Cihaz 7', ip: '192.168.55.26', role: 'Sensör / Aktüatör Node'),
      DeviceInfo(id: 'Cihaz 8', ip: '192.168.55.27', role: 'Sensör / Aktüatör Node'),
      DeviceInfo(id: 'Cihaz 9', ip: '192.168.55.28', role: 'Sensör / Aktüatör Node'),
      // NOT: Cihaz 10 özel bir konumda Ana Kontrol Düğümü (Master Node) olarak atanmıştır.
      DeviceInfo(id: 'Cihaz 10', ip: '192.168.55.29', role: 'Ana Kontrol Düğümü / Primary Controller'),
    ];
  }
}
