/// MADAM Projesi - Cihaz Kontrol Servisi (Faz 4-b Sema Dogrulamali + Reboot Izinli)
import 'dart:io';
import 'dart:convert';
import '../config/network_constants.dart';
import '../models/device_status.dart';

class DeviceCommandService {
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 2);

  void closeClient() {
    _client.close(force: true);
  }

  /// SOT Belgesine gore komut paketini dogrular (COMMAND_SCHEMA_SOT.md)
  bool _validatePayload(Map<String, dynamic> payload) {
    final action = payload['action'];
    final target = payload['target'];
    final deviceIp = payload['deviceIp'];
    final value = payload['value'];

    // R-01: Action alani zorunlu ve izin verilen degerlerden olmali
    // Mimar Notu: Arayuzdeki cihaz resetleme islemi icin 'reboot' ve 'reset' kalkan iznine eklendi.
    const validActions = ['toggle', 'open', 'close', 'read', 'ping', 'reboot', 'reset'];
    if (action == null || !validActions.contains(action)) return false;

    // R-02: Target alani zorunlu ve action ile uyumlu olmali
    if (['toggle', 'open', 'close'].contains(action)) {
      if (target != 'relay_1' && target != 'relay_2') return false;
    } else if (action == 'read') {
      if (target != 'sensor_data') return false;
    } else if (['ping', 'reboot', 'reset'].contains(action)) {
      // Reboot/Ping komutlarinda hedef genelde 'system' olur veya bos birakilabilir
      if (target != 'system' && target != null) return false;
    } else {
      return false; // Bilinmeyen kombinasyon (R-05)
    }

    // R-03: deviceIp zorunlu ve gecerli aralikta olmali (192.168.55.20 - 29)
    if (deviceIp == null || deviceIp is! String) return false;
    final ipParts = deviceIp.split('.');
    if (ipParts.length != 4 || '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}' != '192.168.55') {
      return false;
    }
    final lastOctet = int.tryParse(ipParts[3]);
    if (lastOctet == null || lastOctet < 20 || lastOctet > 29) return false;

    // R-04: action = "read" icin value bos olamaz
    if (action == 'read') {
      if (value == null || value.toString().trim().isEmpty) return false;
    }

    return true; // Tum testleri gecti, guvenli.
  }

  Future<bool> sendCommand(
    String ipAddress,
    Map<String, dynamic> commandJson,
  ) async {
    // 1. Sema Dogrulamasi (Zirh)
    if (!_validatePayload(commandJson)) {
      // Hangi payload'un reddedildigini terminale acikca yazdiriyoruz
      print('[$ipAddress] POST IPTAL: Gecersiz payload semasi. Reddedilen: $commandJson');
      return false;
    }

    // R-06: Timestamp yoksa ekle
    if (!commandJson.containsKey('timestamp')) {
      commandJson['timestamp'] = DateTime.now().toIso8601String();
    }

    try {
      // ESP cihazlarinin json ayrismasini bozmamak icin standart temiz encode
      final String requestBody = jsonEncode(commandJson);

      final uri = Uri.http(
        '$ipAddress:${NetworkConstants.apiPort}',
        NetworkConstants.endpointCommand,
      );

      print('[$ipAddress] POST -> $uri');
      print('PAYLOAD: $requestBody');

      final request = await _client
          .postUrl(uri)
          .timeout(const Duration(seconds: 3));

      // Hassas Header Ayarlari
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Accept', 'application/json');
      request.headers.set('Connection', 'close'); // Baglantiyi acik tutma

      // Byte bazli gonderim (Turkce karakter vs sorunu olmamasi icin)
      final bodyBytes = utf8.encode(requestBody);
      request.contentLength = bodyBytes.length;
      request.add(bodyBytes);

      final response = await request.close().timeout(
        const Duration(seconds: 3),
      );
      
      print('[$ipAddress] HTTP Status: ${response.statusCode}');

      // HTTP 2xx durumlari basarili kabul edilir
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('[$ipAddress] HTTP Istek Hatasi: $e');
      return false;
    }
  }

  /// Dry-Run testi metodu (Arayuz uyumlulugu icin korunmustur)
  Map<String, dynamic> generateDryRunPayload(String role, String ipAddress) {
    String action = role.toUpperCase().contains('RELAY')
        ? 'toggle'
        : (role.toUpperCase().contains('SENSOR') ? 'read' : 'ping');
    String target = role.toUpperCase().contains('RELAY')
        ? 'relay_1'
        : (role.toUpperCase().contains('SENSOR') ? 'sensor_data' : 'system');
    
    return {
      'action': action,
      'target': target,
      // R-04 Kurali geregi read isleminde value null olamaz, default 'all' gonderilir.
      'value': action == 'read' ? 'all' : null, 
      'deviceIp': ipAddress,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Cihaz durumunu sorgulama (Online/Offline kontrolu)
  Future<DeviceStatus> getDeviceStatus(String ipAddress) async {
    try {
      final uri = Uri.http(
        '$ipAddress:${NetworkConstants.apiPort}',
        NetworkConstants.endpointStatus,
      );
      final request = await _client
          .getUrl(uri)
          .timeout(const Duration(seconds: 2));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> jsonData =
            jsonDecode(responseBody) as Map<String, dynamic>;
        final deviceStatus = DeviceStatus(isOnline: true);
        deviceStatus.updateFromJson(jsonData);
        return deviceStatus;
      }
      return DeviceStatus(isOnline: false);
    } catch (e) {
      return DeviceStatus(isOnline: false);
    }
  }
}