/// MADAM Projesi - Cihaz Kontrol Servisi
import 'dart:io';
import 'dart:convert';
import '../config/network_constants.dart';
import '../models/device_status.dart';

class DeviceCommandService {
  final HttpClient _client = HttpClient()..connectionTimeout = const Duration(seconds: 2);

  // TODO: HTTP POST ile cihazlara json komut atan uç nokta buraya kurulacak
  Future<bool> sendCommand(String ipAddress, Map<String, dynamic> commandJson) async {
    // Placeholder logic
    await Future.delayed(const Duration(milliseconds: 100));
    return false; // Başarısızlık senaryosunu test etmek için şimdilik false
  }

  /// Bu metod sadece Dry-Run testi içindir. Gerçek ağ isteği yapmaz.
  Map<String, dynamic> generateDryRunPayload(String role, String ipAddress) {
    String action = 'unknown';
    String target = 'none';
    dynamic value = 0;

    if (role.toUpperCase().contains('RELAY')) {
      action = 'toggle';
      target = 'relay_1';
      value = true;
    } else if (role.toUpperCase().contains('SENSOR')) {
      action = 'read';
      target = 'sensor_data';
      value = 'all';
    } else {
      action = 'ping';
      target = 'system';
      value = null;
    }

    return {
      'action': action,
      'target': target,
      'value': value,
      'deviceIp': ipAddress,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Cihazdan HTTP GET ile /status json okumasını yapar.
  /// Çökmeyi engelleyen try-catch ve timeout korumalıdır.
  Future<DeviceStatus> getDeviceStatus(String ipAddress) async {
    try {
      final uri = Uri.http('$ipAddress:${NetworkConstants.apiPort}', NetworkConstants.endpointStatus);
      final request = await _client.getUrl(uri);
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> jsonData = jsonDecode(responseBody) as Map<String, dynamic>;
        
        final deviceStatus = DeviceStatus(isOnline: true);
        deviceStatus.updateFromJson(jsonData);
        return deviceStatus;
      } else {
        return DeviceStatus(isOnline: false);
      }
    } catch (e) {
      // Bağlantı hatası, JSON parse hatası veya Timeout durumlarında çökme yerine offline modeli döndürülür
      return DeviceStatus(isOnline: false);
    }
  }
}
