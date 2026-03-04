/// MADAM Projesi - Cihaz Listesi Tablosu
import 'package:flutter/material.dart';
import '../state/dashboard_state.dart';

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
                      // TODO: Cihaz kontrol pencereleri buraya bağlanacak
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
}

