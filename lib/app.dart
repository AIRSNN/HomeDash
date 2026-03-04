/// MADAM Projesi - Uygulama Kabuğu
import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';

class MadamApp extends StatelessWidget {
  const MadamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeDash (MADAM)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // TODO: Gelecekte özel tema (dark mode vs) eklenecek
      ),
      home: const DashboardPage(),
    );
  }
}
