/// MADAM Projesi - Ana Ekran (Faz 5: Görsel Dashboard)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider ekledik
import '../widgets/top_control_bar.dart';
import '../widgets/device_table.dart';
import '../state/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // NOT: _dashboardState burada 'final' olarak oluşturulmaz.
  // Provider üzerinden main.dart'taki global instance'ı kullanacağız.

  @override
  Widget build(BuildContext context) {
    // Global state'e erişim (Provider üzerinden)
    final dashboardState = Provider.of<DashboardState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MADAM | HomeDash Control Center'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C3E50), // Daha kurumsal bir koyu ton
        foregroundColor: Colors.white,
        actions: [
          // Uygulamayı güvenli kapatma butonu
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            onPressed: () => dashboardState.gracefulShutdownAndExit(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst kontrol barı (Başlat/Durdur butonları)
          TopControlBar(state: dashboardState),

          const Divider(height: 1, color: Colors.grey),

          // Cihazların listelendiği tablo alanı
          Expanded(
            child: Container(
              color: const Color(
                0xFFF4F7F6,
              ), // Hafif gri arka plan (Table için)
              child: DeviceTable(state: dashboardState),
            ),
          ),

          // --- SİSTEM GÜNLÜKLERİ (TERMINAL PANELİ) ---
          Container(
            height: 180, // Biraz daha genişlettik
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E), // Visual Studio Code terminal rengi
              border: Border(top: BorderSide(color: Colors.blueGrey, width: 2)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SYSTEM LOGS (REAL-TIME)',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    // Aktif tarama ikonu (Dönme efekti)
                    if (dashboardState.isScanning)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    reverse:
                        false, // En yeni loglar üstte kalsın diyorsan dashboard_state'de logs.insert(0) kullanıyoruz zaten
                    itemCount: dashboardState.logs.length,
                    itemBuilder: (context, index) {
                      final log = dashboardState.logs[index];
                      // Logun içeriğine göre renk verelim
                      Color logColor = Colors.greenAccent;
                      if (log.contains('OTOMASYON'))
                        logColor = Colors.orangeAccent;
                      if (log.contains('HATA')) logColor = Colors.redAccent;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '> $log',
                          style: TextStyle(
                            color: logColor,
                            fontFamily: 'Courier New',
                            fontSize: 12,
                            fontWeight: log.contains('OTOMASYON')
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
