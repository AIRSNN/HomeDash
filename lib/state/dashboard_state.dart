/// MADAM Projesi - UI ve Durum (State) Yönetimi Merkezi
import 'dart:async';
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
  
  // Polling (Tarama) için asenkron Timer
  Timer? _pollingTimer;
  bool isPolling = false; // Döngü aktif mi?
  bool isScanning = false; // O an aktif bir tarama işlemi dönüyor mu?
  
  DateTime? lastScanTime;
  String statusMessage = 'Sistem hazır. Tarama başlatılabilir.';
  final List<String> logs = [];
  
  // Ping istatistiklerini UI'da (tabloda) göstermek için geçici map (ip -> ms)
  final Map<String, int> pingLatencies = {};

  DashboardState() {
    initializeDashboard();
  }

  void addLog(String message) {
    final timeStr = DateTime.now().toIso8601String().substring(11, 19);
    logs.insert(0, '[$timeStr] $message');
    if (logs.length > 20) {
      logs.removeLast();
    }
    notifyListeners();
  }

  void initializeDashboard() {
    // Başlangıçta tüm cihazlar 'offline' varsayılarak kaydedilir
    for (var device in devices) {
      deviceStatuses[device.ip] = DeviceStatus(isOnline: false);
      pingLatencies[device.ip] = 0;
    }
    addLog('Uygulama state başlatıldı. Cihaz listesi yüklendi.');
  }

  void startPingLoop() {
    if (isPolling) {
      addLog('Tarama zaten aktif.');
      return; 
    }
    
    isPolling = true;
    statusMessage = 'Ağ dinleme aktif.';
    addLog('Ping döngüsü başlatıldı.');
    notifyListeners();
    
    // Anında bir ilk tarama yapalım (Timer beklememesi için)
    _scanAllDevices();

    // 10 Saniyede bir tüm ağı asenkron olarak pingler
    _pollingTimer?.cancel(); // Güvenlik amaçlı eski timer varsa ez
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _scanAllDevices();
    });
  }

  void stopPingLoop() {
    if (!isPolling) return;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    isPolling = false;
    isScanning = false;
    statusMessage = 'Ağ dinleme durduruldu.';
    addLog('Ping döngüsü durduruldu.');
    notifyListeners();
  }
  
  /// Ağdaki bilinen tüm IP adreslerine (8080) asenkron TCP ping gönderir.
  Future<void> _scanAllDevices() async {
    if (isScanning) return; // Çakışmayı önle
    
    isScanning = true;
    statusMessage = 'Ağ taranıyor...';
    notifyListeners();

    int onlineCount = 0;
    
    // Tüm cihazlara eşzamanlı async operasyon başlatılır
    final futures = devices.map((device) async {
      // 1. Önce cihaz ağda var mı diye portuna bak (Ping)
      final pingResult = await _pingService.pingDevice(device.ip);
      pingLatencies[device.ip] = pingResult.rttMs;
      
      if (pingResult.isSuccess) {
        // 2. Cihaz ayaktaysa HTTP Get metoduyla json status isteği at
        final statusResult = await _commandService.getDeviceStatus(device.ip);
        deviceStatuses[device.ip] = statusResult;
        if (statusResult.isOnline) onlineCount++;
      } else {
        // Ping başarısızsa direk offline yaz
        deviceStatuses[device.ip] = DeviceStatus(isOnline: false);
      }
    }).toList();

    await Future.wait(futures);

    isScanning = false;
    lastScanTime = DateTime.now();
    statusMessage = 'Tarama tamamlandı. $onlineCount aktif cihaz bulundu.';
    addLog('Tarama bitti: ${devices.length} IP sorgulandı, $onlineCount aktif.');
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
