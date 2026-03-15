import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/dashboard_state.dart';

/// MADAM Projesi - Üst Kontrol Çubuğu (Top Header) Bileşeni
/// 
/// [MİMARİ NOT]: Bu modül, uygulamanın üst kısmındaki canlı saat, tarih,
/// aktif istasyon durumu ve motor kontrollerini (Start/Stop Ping Loop) barındırır.
/// Kendi içindeki canlı saati güncelleyebilmek için StatefulWidget olarak tasarlanmıştır.
class TopHeaderWidget extends StatefulWidget {
  final DashboardState state;

  const TopHeaderWidget({super.key, required this.state});

  @override
  State<TopHeaderWidget> createState() => _TopHeaderWidgetState();
}

class _TopHeaderWidgetState extends State<TopHeaderWidget> {
  late Timer _clockTimer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Saat bilgisini her saniye güncelleyen yerel döngü
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime value) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final year = value.year.toString();
    return '$day $month $year'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.80),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Sol Başlık Bölümü
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Stations',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Smart home devices real-time telemetry.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          
          // Otomasyon Aktif/Pasif Rozeti
          if (widget.state.isPolling)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Automation Active',
                style: GoogleFonts.inter(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Spacer(),
          
          // Sistem Kontrol Butonları (Start/Stop)
          if (widget.state.isPolling)
            ElevatedButton.icon(
              onPressed: widget.state.stopPingLoop,
              icon: const Icon(Icons.stop_rounded, size: 18),
              label: Text(
                'Stop',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: widget.state.startPingLoop,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(
                'Start',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF5B13EC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const SizedBox(width: 12),
          
          // Çıkış (Exit) Butonu
          OutlinedButton.icon(
            onPressed: widget.state.gracefulShutdownAndExit,
            icon: const Icon(Icons.exit_to_app_rounded, size: 18),
            label: Text(
              'Exit',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 24),
          
          // Canlı Saat ve Tarih
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(_now),
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(_now),
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 24),
          
          // Bildirim İkonu
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B13EC).withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Color(0xFF64748B),
                ),
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}