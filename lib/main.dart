/// MADAM Projesi - Giriş Noktası
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'state/dashboard_state.dart';

void main() {
  // Flutter motorunun ilklendirilmesini garanti altına alalım
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // State yönetimini tüm uygulamaya en tepeden sağlıyoruz
    ChangeNotifierProvider(
      create: (_) => DashboardState(),
      child: const MadamApp(),
    ),
  );
}
