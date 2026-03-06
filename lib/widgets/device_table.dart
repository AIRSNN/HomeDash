/// MADAM Projesi - Gelişmiş Cihaz Listesi ve Kontrol Paneli
import 'package:flutter/material.dart';
import '../state/dashboard_state.dart';
import '../services/device_command_service.dart';

class DeviceTable extends StatelessWidget {
  final DashboardState state;

  const DeviceTable({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Kayıtlı cihaz bulunamadı.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith(
            (states) => Colors.blueGrey[50],
          ),
          horizontalMargin: 20,
          columnSpacing: 35,
          columns: const [
            DataColumn(
              label: Text(
                'Tip/ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'IP Adresi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Ağ Durumu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Ping',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Röle 1 Durumu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Hızlı Kontrol',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Detaylar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: state.devices.map((device) {
            final status = state.deviceStatuses[device.ip];
            final isOnline = status?.isOnline ?? false;
            final relay1Active = status?.isRelayActive('relay_1') ?? false;

            // Rol bazlı ikon seçimi
            IconData deviceIcon = Icons.developer_board;
            if (device.role == 'relay_node') deviceIcon = Icons.sensors;
            if (device.role == 'primary_controller')
              deviceIcon = Icons.lightbulb_outline;

            return DataRow(
              cells: [
                // 1. Cihaz ID ve İkon
                DataCell(
                  Row(
                    children: [
                      Icon(
                        deviceIcon,
                        size: 20,
                        color: isOnline ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        device.id,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // 2. IP Adresi
                DataCell(
                  Text(
                    device.ip,
                    style: const TextStyle(fontFamily: 'Courier'),
                  ),
                ),
                // 3. Online/Offline Badge
                DataCell(_buildStatusBadge(isOnline)),
                // 4. Ping Gecikmesi
                DataCell(
                  Text(
                    isOnline ? '${state.pingLatencies[device.ip]} ms' : '--',
                    style: TextStyle(
                      color: _getLatencyColor(
                        state.pingLatencies[device.ip] ?? 0,
                      ),
                    ),
                  ),
                ),
                // 5. Canlı Röle Durumu (ESP'den gelen gerçek veri)
                DataCell(
                  isOnline
                      ? Icon(
                          relay1Active ? Icons.flash_on : Icons.flash_off,
                          color: relay1Active ? Colors.orange : Colors.grey,
                        )
                      : const Text("-"),
                ),
                // 6. Hızlı Kontrol Switch
                DataCell(
                  isOnline
                      ? Switch(
                          value: relay1Active,
                          activeColor: Colors.orange,
                          onChanged: (val) => _handleToggle(context, device.ip),
                        )
                      : const Text("Erişilemez"),
                ),
                // 7. Detay Dialog Butonu
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined),
                    onPressed: () => _showDeviceDetailsDialog(
                      context,
                      device,
                      status,
                      isOnline,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Durum Rozeti Oluşturucu
  Widget _buildStatusBadge(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor: isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isOnline ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLatencyColor(int ms) {
    if (ms == 0) return Colors.grey;
    if (ms < 50) return Colors.green;
    if (ms < 150) return Colors.orange;
    return Colors.red;
  }

  Future<void> _handleToggle(BuildContext context, String ip) async {
    final service = DeviceCommandService();
    bool success = await service.sendCommand(ip, {
      'action': 'toggle',
      'target': 'relay_1',
      'deviceIp': ip,
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Komut İletildi' : 'Bağlantı Hatası'),
        backgroundColor: success ? Colors.blueGrey : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Mevcut dialog metodunuzu optimize edilmiş haliyle koruyoruz
  void _showDeviceDetailsDialog(
    BuildContext context,
    dynamic device,
    dynamic status,
    bool isOnline,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${device.id} Teknik Analiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP: ${device.ip}'),
            Text('Rol: ${device.role}'),
            const Divider(),
            Text(
              'Ham JSON Verisi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(
                status?.rawData?.toString() ?? 'Veri yok',
                style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
