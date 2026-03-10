/// MADAM Projesi - Cihaz Kontrol Servisi (Brute-Force Debug Versiyonu)
import 'dart:io';
import 'dart:convert';
import '../config/network_constants.dart';
import '../config/device_registry.dart';
import '../models/device_status.dart';

class DeviceCommandService {
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 2);

  void closeClient() {
    _client.close(force: true);
  }

  Future<bool> sendCommand(
    String ipAddress,
    Map<String, dynamic> commandJson,
  ) async {
    try {
      final action = commandJson['action'];
      final target = commandJson['target'];
      final deviceIp = commandJson['deviceIp'];
      final value = commandJson.containsKey('value')
          ? commandJson['value']
          : null;

      // 1. Manuel JSON String Oluşturma (PowerShell ile birebir aynı format)
      // Boşluksuz ve en yalın haliyle: {"action":"toggle","target":"relay_1","value":null}
      final String valueString = (value == null)
          ? 'null'
          : (value is bool ? value.toString() : '"$value"');
      final String manualBody =
          '{"action":"$action","target":"$target","value":$valueString}';

      final uri = Uri.http(
        '$deviceIp:${NetworkConstants.apiPort}',
        NetworkConstants.endpointCommand,
      );

      print('--- KRITIK DENEME ---');
      print('URI: $uri');
      print('MANUEL BODY: $manualBody');

      final request = await _client
          .postUrl(uri)
          .timeout(const Duration(seconds: 3));

      // 2. Hassas Header Ayarları
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Accept', 'application/json');
      request.headers.set(
        'Connection',
        'close',
      ); // ESP için bağlantıyı açık tutmaya çalışmasın

      // 3. Byte bazlı gönderim
      final bodyBytes = utf8.encode(manualBody);
      request.contentLength = bodyBytes.length;
      request.add(bodyBytes);

      final response = await request.close().timeout(
        const Duration(seconds: 3),
      );
      print('HTTP Response Status: ${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('HTTP Istek Hatasi: $e');
      return false;
    }
  }

  /// Dry-Run testi metodu (Arayüz uyumluluğu için korunmuştur)
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
      'value': null,
      'deviceIp': ipAddress,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Cihaz durumunu sorgulama (Online/Offline kontrolü)
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
