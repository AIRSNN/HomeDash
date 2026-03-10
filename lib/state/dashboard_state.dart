/// MADAM Projesi - Merkezi Durum Yönetimi (M2M Otomasyon & Optimizasyon v4 - Akıllı Log Filtreleme)
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/device_info.dart';
import '../models/device_status.dart';
import '../config/device_registry.dart';
import '../services/device_command_service.dart';
import '../services/ping_service.dart';
import '../services/logging_service.dart';

class DashboardState extends ChangeNotifier {
  final List<DeviceInfo> devices = DeviceRegistry.getKnownDevices();
  final Map<String, DeviceStatus> deviceStatuses = {};

  // Titremeyi Önlemek İçin State Kilidi
  final Map<String, DateTime> _uiStateLocks = {};

  // SİSTEM KURTARMA BELLEĞİ
  final Map<String, Map<String, bool>> _enforcedStates = {};

  // CİHAZLARA ÖZEL LOG HAFIZASI
  final Map<String, List<String>> deviceLogs = {};

  // Servisler
  final PingService _pingService = PingService();
  final DeviceCommandService _commandService = DeviceCommandService();
  final LoggingService _loggingService = LoggingService(); 

  // Polling Ayarları
  Timer? _pollingTimer;
  bool isPolling = false;
  bool isScanning = false;
  bool _isShuttingDown = false;

  // Otomasyon Belleği
  String? _lastSensorState;

  DateTime? lastScanTime;
  String statusMessage = 'Sistem hazır.';
  
  // Ana Sistem Logları
  final List<String> logs = [];
  final Map<String, int> pingLatencies = {};

  DashboardState() {
    initializeDashboard();
  }

  // Genel Sistem Logu 
  void addLog(String message, {bool notify = true}) {
    final timeStr = DateTime.now().toIso8601String().substring(11, 19);
    logs.insert(0, '[$timeStr] $message');
    if (logs.length > 50) logs.removeLast();
    
    // Sistem logları her zaman diske yazılır
    _loggingService.writeLog('SYS', message);

    if (notify) notifyListeners();
  }

  // Karta Özel Log (saveToDisk parametresi eklendi - Gereksiz şişmeyi önler)
  void addDeviceLog(String ip, String message, {bool notify = true, bool saveToDisk = true}) {
    final timeStr = DateTime.now().toIso8601String().substring(11, 19);
    if (!deviceLogs.containsKey(ip)) {
      deviceLogs[ip] = [];
    }
    
    // UI için listeye ekle
    deviceLogs[ip]!.insert(0, '[$timeStr] $message');
    
    // Kart hafızası taşmasın
    if (deviceLogs[ip]!.length > 10) {
      deviceLogs[ip]!.removeLast();
    }

    // Sadece önemli olaylar (Durum değişimi, Komut, Otomasyon) diske yazılır
    if (saveToDisk) {
      _loggingService.writeLog(ip, message);
    }
    
    if (notify) notifyListeners();
  }

  void initializeDashboard() {
    for (var device in devices) {
      deviceStatuses[device.ip] = DeviceStatus(isOnline: false);
      pingLatencies[device.ip] = 0;
      deviceLogs[device.ip] = []; 
    }
    addLog('HomeDash ait sistemler başlatıldı. Cihazlar hazır.');
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

  Future<bool> toggleRelay(String ip, String targetRelay) async {
    final currentStatus = deviceStatuses[ip];
    final bool isCurrentlyActive = currentStatus?.isRelayActive(targetRelay) ?? false;
    final bool newTargetState = !isCurrentlyActive;

    _enforcedStates.putIfAbsent(ip, () => {})[targetRelay] = newTargetState;
    _uiStateLocks[ip] = DateTime.now().add(const Duration(seconds: 3));

    // Komutlar önemlidir, diske KAYDEDİLİR (saveToDisk varsayılan olarak true'dur)
    addDeviceLog(ip, 'CMD: $targetRelay -> ${newTargetState ? "ON" : "OFF"}');

    bool success = await _commandService.sendCommand(ip, {
      "action": "toggle",
      "target": targetRelay,
      "deviceIp": ip,
    });

    if (success) {
      try {
        final newStatus = await _commandService.getDeviceStatus(ip);
        deviceStatuses[ip] = newStatus;
        notifyListeners(); 
      } catch (e) {
        addLog('Hata: $ip durumu anında güncellenemedi.', notify: false);
      }
    } else {
      addDeviceLog(ip, 'HATA: Komut iletilemedi!', notify: true);
    }
    return success;
  }

  Future<bool> rebootDevice(String ip) async {
    addLog('SİSTEM: $ip yeniden başlatılıyor...', notify: true);
    addDeviceLog(ip, 'SYS_CMD: Rebooting...', notify: true);
    
    deviceStatuses[ip] = DeviceStatus(isOnline: false);
    _uiStateLocks[ip] = DateTime.now().add(const Duration(seconds: 6));
    notifyListeners();

    bool success = await _commandService.sendCommand(ip, {
      "action": "reboot",
      "target": "system",
      "deviceIp": ip,
    });

    if (!success) {
      addLog('HATA: $ip reboot komutunu alamadı.', notify: true);
      addDeviceLog(ip, 'HATA: Reboot failed.', notify: true);
    }
    return success;
  }

  Future<Map<String, dynamic>> _fetchDeviceState(DeviceInfo device) async {
    int currentLatency = 0;
    DeviceStatus currentStatus = DeviceStatus(isOnline: false);

    try {
      final pingResult = await _pingService.pingDevice(device.ip);
      currentLatency = pingResult.rttMs;

      if (pingResult.isSuccess) {
        currentStatus = await _commandService.getDeviceStatus(device.ip);
      }
    } catch (e) {
      // Sessiz hata yakalama
    }

    return {
      'ip': device.ip,
      'latency': currentLatency,
      'status': currentStatus,
    };
  }

  void _commitDeviceStates(List<Map<String, dynamic>> results) {
    final now = DateTime.now();
    int onlineCount = 0;

    for (var result in results) {
      final ip = result['ip'] as String;
      final latency = result['latency'] as int;
      final status = result['status'] as DeviceStatus;

      pingLatencies[ip] = latency;

      final lockTime = _uiStateLocks[ip];
      if (lockTime == null || now.isAfter(lockTime)) {
          
          // ÖNCEKİ DURUMU KONTROL ET (Log Bloat'u engellemek için)
          final bool wasOnline = deviceStatuses[ip]?.isOnline ?? false;
          final bool isNowOnline = status.isOnline;

          // Durumu Güncelle
          deviceStatuses[ip] = status;

          if (isNowOnline) {
            // Cihaz yeni çevrimiçi olduysa diske yaz
            if (!wasOnline) {
              addDeviceLog(ip, 'STATUS: Cihaz ağa bağlandı.', saveToDisk: true, notify: false);
            }
            
            // Rutin telemetri sadece UI'da gösterilir, DİSKE YAZILMAZ (saveToDisk: false)
            addDeviceLog(ip, 'Telemetry synced (${latency}ms)', notify: false, saveToDisk: false);

            // Recovery kontrolü
            if (_enforcedStates.containsKey(ip)) {
              final targetMap = _enforcedStates[ip]!;
              targetMap.forEach((relayName, desiredState) {
                bool actualState = status.isRelayActive(relayName);
                if (actualState != desiredState) {
                  addLog('SİSTEM KURTARMA: $ip $relayName senkronize ediliyor...', notify: false);
                  addDeviceLog(ip, 'RECOVERY: $relayName -> ${desiredState ? "ON" : "OFF"}', notify: false, saveToDisk: true);
                  
                  _uiStateLocks[ip] = DateTime.now().add(const Duration(seconds: 4));
                  _commandService.sendCommand(ip, {
                    "action": desiredState ? "open" : "close",
                    "target": relayName,
                    "deviceIp": ip,
                  });
                }
              });
            }
          } else {
            // Cihaz yeni çevrimdışı olduysa diske yaz
            if (wasOnline) {
              addDeviceLog(ip, 'STATUS: Bağlantı koptu (Host unreachable).', saveToDisk: true, notify: false);
            }
            
            // Rutin timeout sadece UI'da gösterilir, DİSKE YAZILMAZ (saveToDisk: false)
            addDeviceLog(ip, 'Timeout: Host unreachable', notify: false, saveToDisk: false);
          }
      }

      if (status.isOnline) onlineCount++;
    }

    statusMessage = 'Tarama bitti. $onlineCount cihaz aktif.';
  }

  Future<void> _scanAllDevices() async {
    if (_isShuttingDown || isScanning) return;
    isScanning = true;
    notifyListeners(); 

    final futures = devices.map((device) => _fetchDeviceState(device)).toList();
    final results = await Future.wait(futures);

    _commitDeviceStates(results);
    await _checkAutomationLogic();

    isScanning = false;
    lastScanTime = DateTime.now();
    notifyListeners(); 
  }

  Future<void> _checkAutomationLogic() async {
    const String sensorIp = "192.168.55.20";
    const String relayIp = "192.168.55.29";

    final sensorStatus = deviceStatuses[sensorIp];
    final targetStatus = deviceStatuses[relayIp];

    if (sensorStatus != null && sensorStatus.isOnline) {
      bool isCurrentlyActive = sensorStatus.isRelayActive('relay_1');
      String currentState = isCurrentlyActive ? "on" : "off";

      if (currentState == "on" && _lastSensorState == "off") {
        addLog('OTOMASYON: $sensorIp tetiklendi! Hedef (.29) güncelleniyor.', notify: false);
        
        // Otomasyon olayları diske yazılır
        addDeviceLog(sensorIp, 'EVENT: Motion triggered', notify: false, saveToDisk: true);
        addDeviceLog(relayIp, 'AUTO_CMD: relay_1 -> ON', notify: false, saveToDisk: true);

        if (targetStatus != null && targetStatus.isOnline) {
          
          final targetActive = targetStatus.isRelayActive('relay_1');
          _enforcedStates.putIfAbsent(relayIp, () => {})['relay_1'] = !targetActive; 
          _uiStateLocks[relayIp] = DateTime.now().add(const Duration(seconds: 3));
            
          bool success = await _commandService.sendCommand(relayIp, {
            "action": "toggle",
            "target": "relay_1",
            "deviceIp": relayIp,
          });

          if (success) {
            addLog('OTOMASYON BAŞARILI: M2M komutu uygulandı.', notify: false);
            try {
              final newTargetStatus = await _commandService.getDeviceStatus(relayIp);
              deviceStatuses[relayIp] = newTargetStatus;
            } catch (_) {}
          } else {
            addLog('HATA: Otomasyon komutu iletilemedi.', notify: false);
          }
        } else {
          addLog('UYARI: Hedef cihaz (.29) offline, otomasyon atlandı.', notify: false);
        }
      }

      _lastSensorState = currentState;
    }
  }

  Future<void> gracefulShutdownAndExit() async {
    if (_isShuttingDown) return;
    _isShuttingDown = true;

    addLog('Sistem kapatılıyor, bağlantılar kesiliyor...');
    _pollingTimer?.cancel();
    _commandService.closeClient();

    notifyListeners();
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