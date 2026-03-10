/// MADAM Projesi - Prototype-aligned Dashboard App Shell (Faz 3 - Final UI V4 Device Logs + Layout Fix + Hover Effect)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/device_info.dart';
import '../state/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final PageController _devicePageController;
  int _devicePageIndex = 0;

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
            final logsHeight = screenHeight < 820 ? 80.0 : 92.0;

            return Row(
              children: [
                const _Sidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _TopHeader(state: dashboardState),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                  onNext: () =>
                                      _goToNextPage(devicePages.length),
                                ),
                              ),
                              const SizedBox(width: 24),
                              _RightPanel(state: dashboardState),
                            ],
                          ),
                        ),
                      ),
                      _SystemLogsPanel(
                        state: dashboardState,
                        height: logsHeight,
                      ),
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
}

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
                                          child: _PrototypeDeviceCard(
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

enum _DeviceCardTab { usage, device, setting }

class _PrototypeDeviceCard extends StatefulWidget {
  final DashboardState state;
  final DeviceInfo device;

  const _PrototypeDeviceCard({required this.state, required this.device});

  @override
  State<_PrototypeDeviceCard> createState() => _PrototypeDeviceCardState();
}

class _PrototypeDeviceCardState extends State<_PrototypeDeviceCard> {
  _DeviceCardTab _activeTab = _DeviceCardTab.usage;

  Future<void> _confirmReboot(BuildContext context, String ip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              'Cihazı Yeniden Başlat',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          '$ip adresli cihaz yeniden başlatılsın mı?\nGeçici bağlantı kesintisi olabilir.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'İptal',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Yeniden Başlat',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      widget.state.rebootDevice(ip);
    }
  }

  void _showDeviceDetailsDialog(
    BuildContext context,
    dynamic status,
    bool isOnline,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.device.id} Teknik Analiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP: ${widget.device.ip}'),
            Text('Rol: ${widget.device.role}'),
            Text('Durum: ${isOnline ? 'Online' : 'Offline'}'),
            const Divider(),
            const Text(
              'Ham JSON Verisi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(
                status?.rawData?.toString() ?? 'Veri yok',
                style: GoogleFonts.jetBrainsMono(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  String _readMacAddress(dynamic status) {
    final rawData = status?.rawData;
    if (rawData is Map) {
      const keys = [
        'mac',
        'macAddress',
        'mac_address',
        'wifiMac',
        'wifi_mac',
        'staMac',
        'sta_mac',
      ];
      for (final key in keys) {
        final value = rawData[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return '--:--:--:--:--:--';
  }

  String _derivePingOrder(String ip) {
    final parts = ip.split('.');
    if (parts.isEmpty) return '--';
    final last = int.tryParse(parts.last);
    if (last == null) return '--';
    return '#$last';
  }

  Widget _buildUsageContent({
    required bool compact,
    required bool isOnline,
    required int pingMs,
    required dynamic status,
  }) {
    return Column(
      key: const ValueKey(_DeviceCardTab.usage),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'PING LATENCY',
                value: isOnline ? '${pingMs}ms' : '--',
                accent: const Color(0xFF5B13EC),
                compact: compact,
                isLeft: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'STATE',
                value: isOnline ? 'Online' : 'Offline',
                accent: isOnline
                    ? const Color(0xFF00FF41)
                    : const Color(0xFF94A3B8),
                compact: compact,
                isLeft: false,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 10 : 14),
        SizedBox(
          height: compact ? 44 : 52,
          child: Row(
            children: [
              if (widget.device.role.contains('primary')) ...[
                Expanded(
                  child: _RelayControlTile(
                    label: 'CH 1',
                    isActive: status?.isRelayActive('relay_1') ?? false,
                    isOnline: isOnline,
                    onTap: () =>
                        widget.state.toggleRelay(widget.device.ip, 'relay_1'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _RelayControlTile(
                    label: 'CH 2',
                    isActive: status?.isRelayActive('relay_2') ?? false,
                    isOnline: isOnline,
                    onTap: () =>
                        widget.state.toggleRelay(widget.device.ip, 'relay_2'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: _RelayControlTile(
                    label: 'Röle',
                    isActive: status?.isRelayActive('relay_1') ?? false,
                    isOnline: isOnline,
                    onTap: () =>
                        widget.state.toggleRelay(widget.device.ip, 'relay_1'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _TempSensorTile(status: status, isOnline: isOnline),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MotionSensorTile(status: status, isOnline: isOnline),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceContent({
    required bool compact,
    required bool isOnline,
    required dynamic status,
  }) {
    final macAddress = _readMacAddress(status);
    final relay1Active = status?.isRelayActive('relay_1') ?? false;
    final relay2Active = status?.isRelayActive('relay_2') ?? false;
    final pir1Detected = status?.motionStatus == 'detected';

    return Column(
      key: const ValueKey(_DeviceCardTab.device),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DeviceSummaryRow(
                label: 'Kart',
                value: widget.device.id,
                compact: true,
              ),
              const SizedBox(height: 3),
              _DeviceSummaryRow(
                label: 'Ping sırası',
                value: _derivePingOrder(widget.device.ip),
                compact: true,
              ),
              const SizedBox(height: 3),
              _DeviceSummaryRow(
                label: 'MAC',
                value: macAddress,
                compact: true,
                mono: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1.55,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _DeviceModuleTile(
              title: 'Röle 1',
              subtitle: isOnline
                  ? (relay1Active ? 'Çıkış aktif' : 'Beklemede')
                  : 'Çevrimdışı',
              icon: Icons.power_settings_new_rounded,
              isActive: relay1Active && isOnline,
              accent: const Color(0xFF22C55E),
              compact: true,
            ),
            _DeviceModuleTile(
              title: 'Röle 2',
              subtitle: isOnline
                  ? (relay2Active ? 'Çıkış aktif' : 'Beklemede')
                  : 'Çevrimdışı',
              icon: Icons.power_settings_new_rounded,
              isActive: relay2Active && isOnline,
              accent: const Color(0xFFEF4444),
              compact: true,
            ),
            _DeviceModuleTile(
              title: 'PIR 1',
              subtitle: isOnline
                  ? (pir1Detected ? 'Hareket algılandı' : 'Hareket yok')
                  : 'Çevrimdışı',
              icon: Icons.sensors_rounded,
              isActive: pir1Detected && isOnline,
              accent: pir1Detected
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              compact: true,
            ),
            _DeviceModuleTile(
              title: 'PIR 2',
              subtitle: isOnline ? 'Ayrılmış modül' : 'Çevrimdışı',
              icon: Icons.notifications_active_rounded,
              isActive: false,
              accent: const Color(0xFF94A3B8),
              compact: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingContent({
    required bool compact,
    required bool isOnline,
  }) {
    return Column(
      key: const ValueKey(_DeviceCardTab.setting),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cihaz ayar yüzeyi',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cihaza özel tercihler ve gelişmiş kontroller için ayrılmış alan.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: compact ? 10 : 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 10 : 12),
        Row(
          children: [
            Expanded(
              child: _SettingPlaceholderTile(
                title: 'Ağ',
                value: isOnline ? 'Eşitlendi' : 'Çevrimdışı',
                icon: Icons.wifi_tethering_rounded,
                compact: compact,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SettingPlaceholderTile(
                title: 'Profil',
                value: 'Hazırlanıyor',
                icon: Icons.tune_rounded,
                compact: compact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabContent({
    required bool compact,
    required bool isOnline,
    required int pingMs,
    required dynamic status,
  }) {
    switch (_activeTab) {
      case _DeviceCardTab.device:
        return _buildDeviceContent(
          compact: compact,
          isOnline: isOnline,
          status: status,
        );
      case _DeviceCardTab.setting:
        return _buildSettingContent(
          compact: compact,
          isOnline: isOnline,
        );
      case _DeviceCardTab.usage:
        return _buildUsageContent(
          compact: compact,
          isOnline: isOnline,
          pingMs: pingMs,
          status: status,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.state.deviceStatuses[widget.device.ip];
    final isOnline = status?.isOnline ?? false;
    final pingMs = widget.state.pingLatencies[widget.device.ip] ?? 0;

    final List<String> dLogs = widget.state.deviceLogs[widget.device.ip] ?? [];
    final String log1 = dLogs.isNotEmpty ? dLogs[0] : '> _ Awaiting telemetry...';
    final String log2 = dLogs.length > 1 ? dLogs[1] : '';

    final deviceIcon = widget.device.role.toLowerCase().contains('primary')
        ? Icons.sensors_rounded
        : Icons.router_rounded;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 400;
        final outerPadding = compact ? 16.0 : 20.0;
        final telemetryHeight = compact ? 44.0 : 70.0;
        final iconBoxSize = compact ? 42.0 : 48.0;
        final bottomLogHeight = compact ? 56.0 : 88.0;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: isOnline ? 1 : 0.6,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isOnline
                    ? const Color(0xFF5B13EC).withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
                width: isOnline ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isOnline
                      ? const Color(0xFF5B13EC).withOpacity(0.12)
                      : Colors.black.withOpacity(0.02),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    outerPadding,
                    outerPadding,
                    outerPadding,
                    outerPadding - 4,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: iconBoxSize,
                            height: iconBoxSize,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? const Color(0xFF5B13EC).withOpacity(0.1)
                                  : const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Icon(
                              deviceIcon,
                              color: isOnline
                                  ? const Color(0xFF5B13EC)
                                  : const Color(0xFF64748B),
                              size: compact ? 22 : 26,
                            ),
                          ),
                          SizedBox(width: compact ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.device.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF0F172A),
                                    fontSize: compact ? 15 : 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? const Color(0xFF5B13EC)
                                            .withOpacity(0.05)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.device.ip,
                                    style: GoogleFonts.jetBrainsMono(
                                      color: isOnline
                                          ? const Color(0xFF5B13EC)
                                          : const Color(0xFF64748B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: compact ? 34 : 38,
                            height: compact ? 34 : 38,
                            child: IconButton(
                              tooltip: 'Cihazı yeniden başlat',
                              padding: EdgeInsets.zero,
                              onPressed: isOnline
                                  ? () => _confirmReboot(
                                        context,
                                        widget.device.ip,
                                      )
                                  : null,
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFFEF2F2),
                                foregroundColor: const Color(0xFFDC2626),
                              ),
                              icon: Icon(
                                Icons.restart_alt_rounded,
                                size: compact ? 18 : 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      _DeviceCardTabs(
                        activeTab: _activeTab,
                        onTabChanged: (tab) {
                          if (_activeTab == tab) return;
                          setState(() {
                            _activeTab = tab;
                          });
                        },
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _buildTabContent(
                          compact: compact,
                          isOnline: isOnline,
                          pingMs: pingMs,
                          status: status,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: outerPadding),
                  child: _WaveformDisplay(
                    pingMs: pingMs,
                    height: telemetryHeight,
                    isOnline: isOnline,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: bottomLogHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(22)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              log1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.jetBrainsMono(
                                color: isOnline
                                    ? const Color(0xFF00FF41)
                                    : const Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: log1.contains('CMD') ||
                                        log1.contains('SYS')
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (log2.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                log2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.jetBrainsMono(
                                  color: isOnline
                                      ? const Color(0xFF00FF41)
                                          .withOpacity(0.6)
                                      : const Color(0xFF94A3B8)
                                          .withOpacity(0.6),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: () => _showDeviceDetailsDialog(
                            context,
                            status,
                            isOnline,
                          ),
                          icon: const Icon(
                            Icons.analytics_outlined,
                            color: Colors.white54,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
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

class _DeviceCardTabs extends StatelessWidget {
  final _DeviceCardTab activeTab;
  final ValueChanged<_DeviceCardTab> onTabChanged;

  const _DeviceCardTabs({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DeviceTabButton(
              label: 'USAGE',
              isActive: activeTab == _DeviceCardTab.usage,
              onTap: () => onTabChanged(_DeviceCardTab.usage),
            ),
          ),
          Expanded(
            child: _DeviceTabButton(
              label: 'DEVICE',
              isActive: activeTab == _DeviceCardTab.device,
              onTap: () => onTabChanged(_DeviceCardTab.device),
            ),
          ),
          Expanded(
            child: _DeviceTabButton(
              label: 'SETTING',
              isActive: activeTab == _DeviceCardTab.setting,
              onTap: () => onTabChanged(_DeviceCardTab.setting),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DeviceTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: isActive
                    ? const Color(0xFF5B13EC)
                    : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool compact;
  final bool mono;

  const _DeviceSummaryRow({
    required this.label,
    required this.value,
    required this.compact,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = mono ? GoogleFonts.jetBrainsMono : GoogleFonts.inter;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Text(
            '$label:',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle(
              color: const Color(0xFF0F172A),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeviceModuleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final Color accent;
  final bool compact;

  const _DeviceModuleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? accent.withOpacity(0.55)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? accent : const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: isActive ? accent : accent.withOpacity(0.70),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingPlaceholderTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool compact;

  const _SettingPlaceholderTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF5B13EC),
            size: compact ? 18 : 20,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelayControlTile extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isOnline;
  final VoidCallback onTap;

  const _RelayControlTile({
    required this.label,
    required this.isActive,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOnline ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: !isOnline
              ? const Color(0xFFF1F5F9)
              : isActive
                  ? const Color(0xFF5B13EC)
                  : const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive && isOnline
                ? const Color(0xFF5B13EC)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.power_settings_new_rounded,
              size: 18,
              color: !isOnline
                  ? const Color(0xFF94A3B8)
                  : isActive
                      ? Colors.white
                      : const Color(0xFF64748B),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: !isOnline
                    ? const Color(0xFF94A3B8)
                    : isActive
                        ? Colors.white
                        : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TempSensorTile extends StatelessWidget {
  final dynamic status;
  final bool isOnline;

  const _TempSensorTile({
    required this.status,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final String tempStr = status?.temperature != null && status?.temperature > 0
        ? '${status!.temperature}°C'
        : '--';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.thermostat_rounded,
            size: 18,
            color: Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 4),
          Text(
            isOnline ? tempStr : '--',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MotionSensorTile extends StatelessWidget {
  final dynamic status;
  final bool isOnline;

  const _MotionSensorTile({
    required this.status,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasMotion = status?.motionStatus == 'detected';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !isOnline
                  ? Colors.grey
                  : (hasMotion
                      ? Colors.redAccent
                      : const Color(0xFF00FF41)),
              boxShadow: hasMotion
                  ? [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOnline ? (hasMotion ? 'MOTION' : 'CLEAR') : '--',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WaveformDisplay extends StatelessWidget {
  final int pingMs;
  final double height;
  final bool isOnline;

  const _WaveformDisplay({
    required this.pingMs,
    required this.height,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final baseHeights = [0.3, 0.5, 0.8, 0.4, 0.2, 0.6, 0.9, 0.5];
    final variation = (pingMs % 5) * 0.02;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(8, (index) {
          final h = (baseHeights[index] +
                  (index % 2 == 0 ? variation : -variation))
              .clamp(0.1, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: isOnline ? h : 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF5B13EC)
                            .withOpacity(isOnline ? 0.8 : 0.3),
                        const Color(0xFF06B6D4)
                            .withOpacity(isOnline ? 0.4 : 0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2.5),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool compact;
  final bool isLeft;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
    this.compact = false,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Text(
            value,
            maxLines: 1,
            style: GoogleFonts.inter(
              color: accent,
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w800,
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
            ? (enabled
                ? const Color(0xFF5B13EC)
                : const Color(0xFFE2E8F0))
            : Colors.white,
        foregroundColor: isPrimary
            ? Colors.white
            : (enabled
                ? const Color(0xFF0F172A)
                : const Color(0xFF94A3B8)),
        side: isPrimary
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      icon: Icon(icon),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SidebarBrand(),
            SizedBox(height: 32),
            _SidebarMenu(),
            Spacer(),
            Divider(color: Color(0xFFF1F5F9), height: 1),
            SizedBox(height: 20),
            _SidebarProfile(),
          ],
        ),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF5B13EC),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B13EC).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.hexagon_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'MADAM',
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  const _SidebarMenu();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SidebarItem(
          icon: Icons.dashboard_rounded,
          label: 'Dashboard',
          isActive: false,
        ),
        SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.memory_rounded,
          label: 'Stations',
          isActive: true,
        ),
        SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.auto_awesome_rounded,
          label: 'Automations',
          isActive: false,
        ),
        SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.analytics_rounded,
          label: 'Library',
          isActive: false,
        ),
        SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.settings_rounded,
          label: 'Settings',
          isActive: false,
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? const Color(0xFF5B13EC).withOpacity(0.1)
        : Colors.transparent;
    final fgColor = isActive
        ? const Color(0xFF5B13EC)
        : const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: fgColor, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: fgColor,
                  fontSize: 15,
                  fontWeight:
                      isActive ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- YENİ: HOVER (PARLAMA) EFEKTLİ PROFİL KARTI ---
class _SidebarProfile extends StatefulWidget {
  const _SidebarProfile();

  @override
  State<_SidebarProfile> createState() => _SidebarProfileState();
}

class _SidebarProfileState extends State<_SidebarProfile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF00FF41)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF00FF41).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F5F9),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Madam User',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'v2-stable',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatefulWidget {
  final DashboardState state;

  const _TopHeader({required this.state});

  @override
  State<_TopHeader> createState() => _TopHeaderState();
}

class _TopHeaderState extends State<_TopHeader> {
  late Timer _clockTimer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
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

class _RightPanel extends StatelessWidget {
  final DashboardState state;

  const _RightPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Favorites',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFF5B13EC),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF5B13EC).withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: const [
                  _FavoriteTile(
                    title: 'ESP32C6 Master Node',
                    subtitle: '192.168.55.29',
                    icon: Icons.router_rounded,
                    isActive: true,
                  ),
                  SizedBox(height: 12),
                  _FavoriteTile(
                    title: 'ESP8266 Actuator Node',
                    subtitle: '192.168.55.20',
                    icon: Icons.memory_rounded,
                    isActive: true,
                  ),
                  SizedBox(height: 12),
                  _FavoriteTile(
                    title: 'Edge Sensor 02',
                    subtitle: '192.168.55.21',
                    icon: Icons.cloud_off_rounded,
                    isActive: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B13EC), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B13EC).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Stack(
                children: [
                  const Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.notifications_active_rounded,
                      size: 80,
                      color: Colors.white10,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.crisis_alert_rounded,
                            color: Color(0xFFFCA5A5),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Security Alert',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          'Motion Detected!',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Zone: Outdoor Entryway',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time: 23:14:05',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
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
  }
}

class _FavoriteTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;

  const _FavoriteTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF8F9FB) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? const Color(0xFFE2E8F0)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: isActive
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF41),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF41)
                                  .withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                      ),
                    if (!isActive)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
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
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
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
                if (log.contains('OTOMASYON')) {
                  logColor = Colors.orangeAccent;
                }
                if (log.contains('HATA')) {
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