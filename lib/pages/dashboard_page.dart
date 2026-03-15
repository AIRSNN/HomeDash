/// MADAM Projesi - Ana Dashboard Kabuğu (Orchestrator Shell)
///
/// [MİMARİ NOT]: Bu sayfa Faz 6 itibarıyla tamamen modüler hale getirilmiştir.
/// Kendi içinde karmaşık UI çizimleri barındırmaz. Sadece alt bileşenleri (Widget'ları)
/// doğru konumlara yerleştirir ve sayfalar arası geçişi (IndexedStack & PageView) yönetir.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/device_info.dart';
import '../state/dashboard_state.dart';
import 'library_page.dart';

// --- DIŞARIYA ÇIKARILAN MODÜLER WIDGET'LAR ---
import '../widgets/sidebar_widget.dart';
import '../widgets/top_header_widget.dart';
import '../widgets/right_panel_widget.dart';
import '../widgets/device_card_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final PageController _devicePageController;
  int _devicePageIndex = 0;
  
  // App Shell Navigasyon Durumu (0 = Dashboard, 1 = Stations, 3 = Library vb.)
  // Şu an varsayılan olarak Stations (1) açık başlatılıyor.
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _devicePageController = PageController();
  }

  @override
  void dispose() {
    _devicePageController.dispose();
    super.dispose();
  }

  /// Cihazları, ekranda 3'erli gruplar (sayfalar) halinde gösterebilmek için böler.
  List<List<DeviceInfo>> _chunkDevices(List<DeviceInfo> devices, int size) {
    final pages = <List<DeviceInfo>>[];
    for (var i = 0; i < devices.length; i += size) {
      final end = (i + size < devices.length) ? i + size : devices.length;
      pages.add(devices.sublist(i, end));
    }
    return pages;
  }

  void _goToPreviousPage() {
    if (_devicePageIndex == 0) return;
    _devicePageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextPage(int pageCount) {
    if (_devicePageIndex >= pageCount - 1) return;
    _devicePageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = Provider.of<DashboardState>(context);
    final devicePages = _chunkDevices(dashboardState.devices, 3);

    // Cihaz silinmesi gibi durumlarda sayfa endeksinin taşmasını engeller.
    if (_devicePageIndex >= devicePages.length && devicePages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _devicePageIndex = devicePages.length - 1;
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            // Küçük ekranlarda log panelini daraltıyoruz
            final logsHeight = screenHeight < 820 ? 80.0 : 92.0;

            return Row(
              children: [
                // 1. İZOLE EDİLMİŞ SOL MENÜ (SIDEBAR)
                SidebarWidget(
                  selectedIndex: _selectedNavIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedNavIndex = index;
                    });
                  },
                ),
                Expanded(
                  // ÇÖZÜM MİMARİSİ: IndexedStack sayfaları çöpe atmaz, arka planda dondurur.
                  // Böylece menüler arası geçişte state ve scroll pozisyonu kaybolmaz.
                  child: IndexedStack(
                    index: _selectedNavIndex == 3 ? 1 : 0,
                    children: [
                      // Ana Dashboard Görünümü
                      _buildStationsView(dashboardState, devicePages, logsHeight),
                      // Library (Log) Görünümü
                      const LibraryPage(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Ana (Stations) sayfasının iskeletini oluşturur.
  Widget _buildStationsView(
      DashboardState dashboardState, 
      List<List<DeviceInfo>> devicePages, 
      double logsHeight) {
    return Column(
      children: [
        // 2. İZOLE EDİLMİŞ ÜST HEADER
        TopHeaderWidget(state: dashboardState),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Orta Ana İçerik (Cihaz Kartları Listesi)
                Expanded(
                  child: _MainContent(
                    state: dashboardState,
                    devicePages: devicePages,
                    pageController: _devicePageController,
                    currentPage: _devicePageIndex,
                    onPageChanged: (value) {
                      setState(() {
                        _devicePageIndex = value;
                      });
                    },
                    onPrevious: _goToPreviousPage,
                    onNext: () => _goToNextPage(devicePages.length),
                  ),
                ),
                const SizedBox(width: 24),
                // 3. İZOLE EDİLMİŞ SAĞ BİLGİ PANELİ
                RightPanelWidget(state: dashboardState),
              ],
            ),
          ),
        ),
        
        // 4. ALT LOG PANELİ (Layout'a sıkı sıkıya bağlı olduğu için bu dosyada tutulmuştur)
        _SystemLogsPanel(
          state: dashboardState,
          height: logsHeight,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SAYFAYA ÖZEL YARDIMCI WIDGET'LAR (Layout İskeleti)
// -----------------------------------------------------------------------------

/// Orta bölümdeki beyaz güverteyi ve içindeki sayfalama (PageView) yapısını kurar.
class _MainContent extends StatelessWidget {
  final DashboardState state;
  final List<List<DeviceInfo>> devicePages;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MainContent({
    required this.state,
    required this.devicePages,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final hasDevices = devicePages.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 760;
        final deckHeight = compact ? 530.0 : 610.0;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE9ECF5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B13EC).withOpacity(0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _DeckSimpleHeader(
                        currentPage: currentPage,
                        totalPages: devicePages.length,
                        hasDevices: hasDevices,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: deckHeight,
                        child: hasDevices
                            ? PageView.builder(
                                controller: pageController,
                                itemCount: devicePages.length,
                                onPageChanged: onPageChanged,
                                itemBuilder: (context, pageIndex) {
                                  final devices = devicePages[pageIndex];
                                  return Row(
                                    children: List.generate(3, (slotIndex) {
                                      if (slotIndex >= devices.length) {
                                        return const Expanded(
                                          child: SizedBox.expand(),
                                        );
                                      }

                                      final device = devices[slotIndex];
                                      return Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: slotIndex == 2 ? 0 : 20,
                                          ),
                                          // 5. İZOLE EDİLMİŞ CİHAZ KARTI ÇAĞRILIYOR
                                          child: DeviceCardWidget(
                                            state: state,
                                            device: device,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              )
                            : const _EmptyDeckCard(),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Station pages',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF161A2D),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              _PagerButton(
                                icon: Icons.chevron_left_rounded,
                                onPressed: currentPage > 0 ? onPrevious : null,
                              ),
                              const SizedBox(width: 12),
                              _PagerButton(
                                icon: Icons.chevron_right_rounded,
                                onPressed: currentPage < devicePages.length - 1
                                    ? onNext
                                    : null,
                                isPrimary: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeckSimpleHeader extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasDevices;

  const _DeckSimpleHeader({
    required this.currentPage,
    required this.totalPages,
    required this.hasDevices,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Station Deck',
                style: GoogleFonts.inter(
                  color: const Color(0xFF161A2D),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Live nodes, telemetry and quick actions',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (hasDevices)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'PAGE ${currentPage + 1} OF $totalPages',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyDeckCard extends StatelessWidget {
  const _EmptyDeckCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          'No devices available.',
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PagerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _PagerButton({
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: isPrimary
            ? (enabled ? const Color(0xFF5B13EC) : const Color(0xFFE2E8F0))
            : Colors.white,
        foregroundColor: isPrimary
            ? Colors.white
            : (enabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8)),
        side: isPrimary
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      icon: Icon(icon),
    );
  }
}

class _SystemLogsPanel extends StatelessWidget {
  final DashboardState state;
  final double height;

  const _SystemLogsPanel({required this.state, required this.height});

  @override
  Widget build(BuildContext context) {
    final visibleLogs = state.logs.take(3).toList();

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SYSTEM LOGS (REAL-TIME)',
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              if (state.isScanning)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF38BDF8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleLogs.length,
              itemBuilder: (context, index) {
                final log = visibleLogs[index];
                Color logColor = const Color(0xFF00FF41);
                if (log.contains('OTOMASYON') || log.contains('SİSTEM KURTARMA')) {
                  logColor = Colors.orangeAccent;
                }
                if (log.contains('HATA') || log.contains('Timeout')) {
                  logColor = Colors.redAccent;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '> $log',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      color: logColor,
                      fontSize: 11,
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
    );
  }
}