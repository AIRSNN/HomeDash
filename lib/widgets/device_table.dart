/// MADAM Projesi - Cihaz Listesi Tablosu
import 'package:flutter/material.dart';
import '../state/dashboard_state.dart';
import '../services/device_command_service.dart';

class DeviceTable extends StatelessWidget {
  final DashboardState state;
  
  const DeviceTable({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.devices.isEmpty) {
      return const Center(child: Text('Kayıtlı cihaz bulunamadı.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.blueGrey[100]),
          columns: const [
            DataColumn(label: Text('Cihaz Adı')),
            DataColumn(label: Text('IP Adresi')),
            DataColumn(label: Text('Rol')),
            DataColumn(label: Text('Ağ Durumu')),
            DataColumn(label: Text('Ping (ms)')),
            DataColumn(label: Text('Durum Verisi (JSON)')),
            DataColumn(label: Text('Eylemler')),
          ],
          rows: state.devices.map((device) {
            final status = state.deviceStatuses[device.ip];
            final isOnline = status?.isOnline ?? false;
            final jsonSummary = status?.getSummary() ?? 'Cihaz bekleniyor...';
            
            // Son görülme saatini formatla
            String lastSeenText = '';
            if (isOnline && status?.lastSeen != null) {
               lastSeenText = '\n(${status!.lastSeen!.hour.toString().padLeft(2,'0')}:${status.lastSeen!.minute.toString().padLeft(2,'0')}:${status.lastSeen!.second.toString().padLeft(2,'0')})';
            }
            
            return DataRow(
              cells: [
                DataCell(Text(device.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(device.ip)),
                DataCell(Text(device.role)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(color: isOnline ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataCell(Text(
                  isOnline 
                  ? '${state.pingLatencies[device.ip] ?? 0} ms' 
                  : 'Timeout',
                  style: TextStyle(
                    color: isOnline ? Colors.black87 : Colors.red[300],
                    fontStyle: isOnline ? FontStyle.normal : FontStyle.italic,
                  ),
                )),
                DataCell(
                  Text(
                    '$jsonSummary$lastSeenText',
                    style: TextStyle(
                      color: isOnline ? Colors.blueGrey[800] : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Ayrıntılar / Komut',
                    onPressed: () {
                      _showDeviceDetailsDialog(
                        context,
                        device,
                        status,
                        jsonSummary,
                        isOnline,
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeviceDetailsDialog(
    BuildContext context,
    dynamic device,
    dynamic status,
    String jsonSummary,
    bool isOnline,
  ) {
    String rawDataKeys = 'Veri yok';
    if (!isOnline) {
      rawDataKeys = 'Cihaz çevrimdışı';
    } else if (status?.rawData == null || status.rawData.isEmpty) {
      rawDataKeys = 'JSON boş';
    } else {
      rawDataKeys = (status.rawData as Map<String, dynamic>).keys.join(', ');
    }

    String lastSeenStr = 'Bilinmiyor';
    if (status?.lastSeen != null) {
      final ls = status.lastSeen as DateTime;
      lastSeenStr = '${ls.hour.toString().padLeft(2, '0')}:${ls.minute.toString().padLeft(2, '0')}:${ls.second.toString().padLeft(2, '0')}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? generatedPayloadText;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${device.id} Ayrıntıları'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('IP Adresi:', device.ip),
                    _buildDetailRow(
                      'Durum:',
                      isOnline ? 'Online' : 'Offline',
                      color: isOnline ? Colors.green : Colors.red,
                    ),
                    _buildDetailRow('Son Görülme:', lastSeenStr),
                    const Divider(),
                    _buildDetailRow('Özet:', jsonSummary),
                    const SizedBox(height: 8),
                    const Text('Veri Anahtarları:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(rawDataKeys),
                    const Divider(),
                    
                    // Dry-Run Payload Alanı
                    const Text('Test Komutu (Dry-Run):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (generatedPayloadText == null)
                      const Text('Henüz test komutu hazırlanmadı', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                    else
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          border: Border.all(color: Colors.blueGrey[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          generatedPayloadText!,
                          style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                if (isOnline) // Sadece cihaz online ise komut testine izin ver
                  TextButton(
                    onPressed: () {
                      final service = DeviceCommandService();
                      final payload = service.generateDryRunPayload(device.role, device.ip);
                      setState(() {
                         // JSON görünümü gibi formatla
                        generatedPayloadText = "{\n"
                          "  'action': '${payload['action']}',\n"
                          "  'target': '${payload['target']}',\n"
                          "  'value': ${payload['value']},\n"
                          "  'deviceIp': '${payload['deviceIp']}'\n"
                          "}";
                      });
                    },
                    child: const Text('Test Komutu Hazırla'),
                  ),
                TextButton(
                   onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

