/// MADAM Projesi - Üst Kontrol Çubuğu
import 'package:flutter/material.dart';
import '../state/dashboard_state.dart';

class TopControlBar extends StatelessWidget {
  final DashboardState state;
  
  const TopControlBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final timeStr = state.lastScanTime != null 
        ? '${state.lastScanTime!.hour.toString().padLeft(2, '0')}:${state.lastScanTime!.minute.toString().padLeft(2, '0')}:${state.lastScanTime!.second.toString().padLeft(2, '0')}'
        : 'Bekliyor';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.blueGrey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ağ Kontrol Paneli',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Durum: ${state.statusMessage}',
                  style: TextStyle(color: Colors.blueGrey[700], fontSize: 13),
                ),
                Text(
                  'Son Tarama: $timeStr',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (state.isScanning)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              Text(
                state.isPolling ? 'Döngü Aktif' : 'Döngü Kapalı',
                style: TextStyle(
                  color: state.isPolling ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: state.isPolling ? state.stopPingLoop : state.startPingLoop,
                icon: Icon(state.isPolling ? Icons.stop : Icons.play_arrow),
                label: Text(state.isPolling ? 'Durdur' : 'Başlat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.isPolling ? Colors.red[100] : Colors.green[100],
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: state.gracefulShutdownAndExit,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Çıkış'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
