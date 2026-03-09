/// MADAM Projesi - Giriş Noktası
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'state/dashboard_state.dart';

Future<void> main() async {
  // Flutter motorunun ilklendirilmesini garanti altına alalım
  WidgetsFlutterBinding.ensureInitialized();

  // Masaüstü pencere boyutlandırma ve merkezleme ayarları
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1480, 1020),
      minimumSize: Size(1360, 920),
      center: true,
      title: 'MADAM HomeDash',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    // State yönetimini tüm uygulamaya en tepeden sağlıyoruz
    ChangeNotifierProvider(
      create: (_) => DashboardState(),
      child: const MadamApp(),
    ),
  );
}
