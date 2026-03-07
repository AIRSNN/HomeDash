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

  // --- GÖREV 1: Log Tamponu ve Opsiyonel Bildirim ---
  void addLog(String message, {bool notify = true}) {
    final timeStr = DateTime.now().toIso8601String().substring(11, 19);
    logs.insert(0, '[$timeStr] $message');

    // Log kapasitesini sınırlayarak bellek sızıntısını (memory leak) önlüyoruz
    if (logs.length > 50) {
      logs.removeLast();
    }

    if (notify) {
      notifyListeners();
    }
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

  // --- GÖREV 2: FETCH FAZI İÇİN YARDIMCI FONKSİYON ---
  Future<Map<String, dynamic>> _scanDevice(DeviceInfo device) async {
    int currentLatency = 0;
    DeviceStatus currentStatus = DeviceStatus(isOnline: false);

    try {
      final pingResult = await _pingService.pingDevice(device.ip);
      currentLatency = pingResult.rttMs;

      if (pingResult.isSuccess) {
        currentStatus = await _commandService.getDeviceStatus(device.ip);
      }
    } catch (e) {
      // Olası bir hata anında sessiz log atıyoruz
      addLog('Hata (${device.ip}): Bağlantı sorunu.', notify: false);
    }

    return {
      'ip': device.ip,
      'latency': currentLatency,
      'status': currentStatus,
    };
  }

  // --- GÖREV 2: ANA TARAMA FONKSİYONU (FETCH/COMMIT MİMARİSİ) ---
  Future<void> _scanAllDevices() async {
    if (_isShuttingDown || isScanning) return;
    isScanning = true;
    notifyListeners();

    int onlineCount = 0;

    // FETCH FAZI: Paralel ağ istekleri, state'e yazmadan veriyi topla
    final futures = devices.map((device) => _scanDevice(device)).toList();
    final results = await Future.wait(futures);

    // COMMIT FAZI: Toplanan sonuçları tek seferde ve güvenli bir şekilde state'e yaz
    for (var result in results) {
      final ip = result['ip'] as String;
      final latency = result['latency'] as int;
      final status = result['status'] as DeviceStatus;

      pingLatencies[ip] = latency;
      deviceStatuses[ip] = status;

      if (status.isOnline) onlineCount++;
    }

    // TARAMA SONRASI OTOMASYON KONTROLÜ
    await _checkAutomationLogic();

    isScanning = false;
    lastScanTime = DateTime.now();
    statusMessage = 'Tarama bitti. $onlineCount cihaz aktif.';

    // TEKİL BİLDİRİM: Tüm işlemler bittikten sonra arayüzü sadece 1 kez güncelle
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
        // Sessiz loglama kullanıyoruz ki arayüz hemen titremesin
        addLog(
          'OTOMASYON: $sensorIp tetiklendi! Hedef (.29) güncelleniyor.',
          notify: false,
        );

        if (targetStatus != null && targetStatus.isOnline) {
          bool success = await _commandService.sendCommand(relayIp, {
            "action": "toggle",
            "target": "relay_1",
            "deviceIp": relayIp,
          });

          if (success) {
            addLog('OTOMASYON BAŞARILI: M2M komutu uygulandı.', notify: false);
          } else {
            addLog('HATA: Otomasyon komutu iletilemedi.', notify: false);
          }
        } else {
          addLog(
            'UYARI: Hedef cihaz (.29) offline, otomasyon atlandı.',
            notify: false,
          );
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
