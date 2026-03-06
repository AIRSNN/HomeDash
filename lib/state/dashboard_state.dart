/// MADAM Projesi - Merkezi Durum Yönetimi (M2M Otomasyon & Optimizasyon)
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/device_info.dart';
import '../models/device_status.dart';
import '../config/device_registry.dart';
import '../services/device_command_service.dart';
import '../services/ping_service.dart';

class DashboardState extends ChangeNotifier {
  final List<DeviceInfo> devices = DeviceRegistry.getKnownDevices();
  final Map<String, DeviceStatus> deviceStatuses = {};

  // Servisler
  final PingService _pingService = PingService();
  final DeviceCommandService _commandService = DeviceCommandService();

  // Polling Ayarları
  Timer? _pollingTimer;
  bool isPolling = false;
  bool isScanning = false;
  bool _isShuttingDown = false;

  // Otomasyon Belleği (Sürekli tetiklemeyi önlemek için)
  // ESP8266'nın son durumunu saklar: "on" veya "off"
  String? _lastSensorState;

  DateTime? lastScanTime;
  String statusMessage = 'Sistem hazır.';
  final List<String> logs = [];
  final Map<String, int> pingLatencies = {};

  DashboardState() {
    initializeDashboard();
  }

  void addLog(String message) {
    final timeStr = DateTime.now().toIso8601String().substring(11, 19);
    logs.insert(0, '[$timeStr] $message');
    if (logs.length > 50) logs.removeLast(); // Log kapasitesini artırdık
    notifyListeners();
  }

  void initializeDashboard() {
    for (var device in devices) {
      deviceStatuses[device.ip] = DeviceStatus(isOnline: false);
      pingLatencies[device.ip] = 0;
    }
    addLog('Uygulama ilklendirildi. Cihazlar hazır.');
  }

  void startPingLoop() {
    if (_isShuttingDown || isPolling) return;
    isPolling = true;
    statusMessage = 'Otomasyon aktif.';
    addLog('M2M Otomasyon döngüsü başlatıldı (10 sn aralık).');

    _scanAllDevices();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _scanAllDevices();
    });
    notifyListeners();
  }

  void stopPingLoop() {
    _pollingTimer?.cancel();
    isPolling = false;
    statusMessage = 'Otomasyon durduruldu.';
    addLog('Döngü kullanıcı tarafından durduruldu.');
    notifyListeners();
  }

  /// Tüm ağı tarayan ana asenkron metod
  Future<void> _scanAllDevices() async {
    if (_isShuttingDown || isScanning) return;
    isScanning = true;
    notifyListeners();

    int onlineCount = 0;

    // Tüm cihazlara paralel olarak durum sorgusu atılır
    final futures = devices.map((device) async {
      final pingResult = await _pingService.pingDevice(device.ip);
      pingLatencies[device.ip] = pingResult.rttMs;

      if (pingResult.isSuccess) {
        final statusResult = await _commandService.getDeviceStatus(device.ip);
        deviceStatuses[device.ip] = statusResult;
        if (statusResult.isOnline) onlineCount++;
      } else {
        deviceStatuses[device.ip] = DeviceStatus(isOnline: false);
      }
    }).toList();

    await Future.wait(futures);

    // TARAMA SONRASI OTOMASYON KONTROLÜ
    await _checkAutomationLogic();

    isScanning = false;
    lastScanTime = DateTime.now();
    statusMessage = 'Tarama bitti. $onlineCount cihaz aktif.';
    notifyListeners();
  }

  /// Makineler Arası (M2M) Karar Mekanizması
  Future<void> _checkAutomationLogic() async {
    // .ino dosyalarına göre: .20 Sensör/Anahtar, .29 Hedef Röle
    const String sensorIp = "192.168.55.20";
    const String relayIp = "192.168.55.29";

    final sensorStatus = deviceStatuses[sensorIp];
    final targetStatus = deviceStatuses[relayIp];

    if (sensorStatus != null && sensorStatus.isOnline) {
      // Mevcut durumu oku
      bool isCurrentlyActive = sensorStatus.isRelayActive('relay_1');
      String currentState = isCurrentlyActive ? "on" : "off";

      // --- EDGE TRIGGER MANTIĞI ---
      // Eğer durum OFF'tan ON'a geçtiyse (Yani anahtar yeni kapandıysa/hareket algılandıysa)
      if (currentState == "on" && _lastSensorState == "off") {
        addLog('OTOMASYON: $sensorIp tetiklendi! Hedef (.29) güncelleniyor.');

        if (targetStatus != null && targetStatus.isOnline) {
          bool success = await _commandService.sendCommand(relayIp, {
            "action": "toggle",
            "target": "relay_1",
            "deviceIp": relayIp,
          });

          if (success) {
            addLog('OTOMASYON BAŞARILI: M2M komutu uygulandi.');
          } else {
            addLog('HATA: Otomasyon komutu iletilemedi.');
          }
        } else {
          addLog('UYARI: Hedef cihaz (.29) offline, otomasyon atlandi.');
        }
      }

      // Durumu bir sonraki karşılaştırma için kaydet
      _lastSensorState = currentState;
    }
  }

  /// Uygulama kapanırken kaynakları temizler
  Future<void> gracefulShutdownAndExit() async {
    if (_isShuttingDown) return;
    _isShuttingDown = true;

    addLog('Sistem kapatılıyor, bağlantılar kesiliyor...');
    _pollingTimer?.cancel();
    _commandService.closeClient();

    notifyListeners();
    // Kısa bir bekleme süresi (Logların görülmesi için)
    await Future.delayed(const Duration(seconds: 1));
    exit(0);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _commandService.closeClient();
    super.dispose();
  }
}
