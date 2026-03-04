/// MADAM Projesi - Ana Ekran İskeleti
import 'package:flutter/material.dart';
import '../widgets/top_control_bar.dart';
import '../widgets/device_table.dart';
import '../state/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // State yönetimi için instance oluşturulur
  final DashboardState _dashboardState = DashboardState();

  @override
  void initState() {
    super.initState();
    // State değiştiğinde ekranı yenile
    _dashboardState.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _dashboardState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeDash (MADAM)'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopControlBar(state: _dashboardState),
          const Divider(height: 1),
          // Cihazların listelendiği ana alan
          Expanded(
            child: DeviceTable(state: _dashboardState),
          ),
          // Alt kısımdaki yer tutucu log alanı
          Container(
            height: 150,
            color: Colors.black87,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sistem Günlükleri:',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _dashboardState.logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        '> ${_dashboardState.logs[index]}',
                        style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 13),
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
