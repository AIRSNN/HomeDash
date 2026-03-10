/// MADAM Projesi - Kütüphane (Log İzleme ve Tanılama) Sayfası
/// Başlangıç: Faz 6 (Gelişmiş Hata Tanılama ve Günlükleme)
/// Açıklama: Arka planda kaydedilen günlük sistem loglarını UI üzerinde listeleyen, takvim destekli arayüz bileşeni.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/logging_service.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final LoggingService _loggingService = LoggingService();
  List<String> _logs = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    final logs = await _loggingService.readLogs(_selectedDate);
    setState(() {
      // En yeni logların en üstte görünmesi için listeyi ters çeviriyoruz
      _logs = logs.reversed.toList();
      _isLoading = false;
    });
  }

  // Takvimden Tarih Seçme Dialogu
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B13EC),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchLogs(); // Yeni tarihe göre logları diskten çek
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Color _getLogColor(String log) {
    if (log.contains('HATA') || log.contains('Timeout') || log.contains('fail')) return Colors.redAccent;
    if (log.contains('OTOMASYON') || log.contains('RECOVERY')) return Colors.orangeAccent;
    if (log.contains('CMD')) return Colors.cyanAccent;
    return const Color(0xFF00FF41); // Varsayılan yeşil (sistem logları)
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ÜST BİLGİ ALANI VE TAKVİM BUTONU
        Container(
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Library',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Geçmiş olay günlükleri ve donanım telemetrisi',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              
              // Tıklanabilir Takvim Butonu
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF5B13EC)),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(_selectedDate),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _fetchLogs,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Yenile', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF5B13EC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),

        // LOG TERMİNAL EKRANI
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Koyu Terminal Arka Planı
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1E293B), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B13EC).withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Terminal Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.terminal_rounded, color: Color(0xFF38BDF8), size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'MADAM_CORE_DUMP // READ_ONLY',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // İçerik
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                        : _logs.isEmpty || (_logs.length == 1 && _logs[0].contains('bulunamadı'))
                            ? Center(
                                child: Text(
                                  _logs.isNotEmpty ? _logs[0] : 'Kayıt bulunamadı.',
                                  style: GoogleFonts.jetBrainsMono(color: const Color(0xFF64748B)),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  if (log.trim().isEmpty) return const SizedBox.shrink();
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: SelectableText(
                                      '> $log',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: _getLogColor(log),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}