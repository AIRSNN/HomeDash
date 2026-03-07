/// MADAM Projesi - Prototype-aligned Dashboard App Shell
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device_info.dart';
import '../services/device_command_service.dart';
import '../state/dashboard_state.dart';
import '../widgets/device_waveform_chart.dart';

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
            final logsHeight = screenHeight < 820 ? 92.0 : 108.0;

            return Row(
              children: [
                const _Sidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _TopHeader(state: dashboardState),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
                              const SizedBox(width: 20),
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
        final deckHeight = compact ? 448.0 : 484.0;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE9ECF5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
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
                      const SizedBox(height: 16),
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
                                            right: slotIndex == 2 ? 0 : 14,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Station pages',
                            style: TextStyle(
                              color: Color(0xFF161A2D),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              _PagerButton(
                                icon: Icons.arrow_back_rounded,
                                onPressed: currentPage > 0 ? onPrevious : null,
                              ),
                              const SizedBox(width: 10),
                              _PagerButton(
                                icon: Icons.arrow_forward_rounded,
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
                const SizedBox(height: 18),
                _SummaryCardsSection(state: state),
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Station Deck',
                style: TextStyle(
                  color: Color(0xFF161A2D),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Live nodes, telemetry and quick actions',
                style: TextStyle(
                  color: Color(0xFF8A90A2),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (hasDevices)
          Text(
            'Page ${currentPage + 1} / $totalPages',
            style: const TextStyle(
              color: Color(0xFF8A90A2),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _PrototypeDeviceCard extends StatelessWidget {
  final DashboardState state;
  final DeviceInfo device;

  const _PrototypeDeviceCard({required this.state, required this.device});

  Future<void> _handleToggle(BuildContext context, String ip) async {
    final service = DeviceCommandService();
    final success = await service.sendCommand(ip, {
      'action': 'toggle',
      'target': 'relay_1',
      'deviceIp': ip,
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Komut iletildi' : 'Baglanti hatasi'),
        backgroundColor: success ? Colors.blueGrey : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showDeviceDetailsDialog(
    BuildContext context,
    dynamic status,
    bool isOnline,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${device.id} Teknik Analiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP: ${device.ip}'),
            Text('Rol: ${device.role}'),
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
                style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
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

  Color _getLatencyColor(int ms) {
    if (ms == 0) return Colors.grey;
    if (ms < 50) return Colors.green;
    if (ms < 150) return Colors.orange;
    return Colors.red;
  }

  List<double> _buildWaveformSamples(int pingMs) {
    final base = pingMs <= 0 ? 18 : pingMs;
    return [
      (base - 10).clamp(4, 999).toDouble(),
      base.clamp(4, 999).toDouble(),
      (base + 5).clamp(4, 999).toDouble(),
      (base - 2).clamp(4, 999).toDouble(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final status = state.deviceStatuses[device.ip];
    final isOnline = status?.isOnline ?? false;
    final relay1Active = status?.isRelayActive('relay_1') ?? false;
    final pingMs = state.pingLatencies[device.ip] ?? 0;
    final lastLog = state.logs.isNotEmpty
        ? state.logs.first
        : 'No recent logs for this device yet.';
    final deviceIcon = device.role.toLowerCase().contains('primary')
        ? Icons.hub_rounded
        : Icons.memory_rounded;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 400;
        final outerPadding = compact ? 14.0 : 18.0;
        final telemetryHeight = compact ? 40.0 : 52.0;
        final iconBoxSize = compact ? 42.0 : 46.0;
        final metricGap = compact ? 8.0 : 10.0;
        final betweenGap = compact ? 10.0 : 14.0;
        final bottomLogHeight = compact ? 50.0 : 64.0;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: isOnline ? 1 : 0.72,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isOnline
                    ? const Color(0x1A5B13EC)
                    : const Color(0x1A9CA3AF),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B13EC).withOpacity(0.06),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                outerPadding,
                outerPadding,
                outerPadding,
                outerPadding - 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EEFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'NODE',
                          style: TextStyle(
                            color: Color(0xFF5B13EC),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: compact ? 34 : 38,
                        height: compact ? 34 : 38,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _handleToggle(context, device.ip),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF6F3FF),
                            foregroundColor: const Color(0xFF5B13EC),
                          ),
                          icon: Icon(
                            relay1Active
                                ? Icons.power_settings_new_rounded
                                : Icons.toggle_off_rounded,
                            size: compact ? 18 : 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  Row(
                    children: [
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B13EC), Color(0xFF8360FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          deviceIcon,
                          color: Colors.white,
                          size: compact ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: compact ? 10 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF161A2D),
                                fontSize: compact ? 14 : 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                device.ip,
                                style: const TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 11,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(isOnline: isOnline),
                    ],
                  ),
                  SizedBox(height: compact ? 12 : 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Latency',
                          value: isOnline ? '$pingMs ms' : '--',
                          accent: _getLatencyColor(pingMs),
                          compact: compact,
                        ),
                      ),
                      SizedBox(width: metricGap),
                      Expanded(
                        child: _MetricTile(
                          label: 'Relay 1',
                          value: relay1Active ? 'Active' : 'Standby',
                          accent: relay1Active
                              ? Colors.orange
                              : const Color(0xFF8A90A2),
                          compact: compact,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: betweenGap),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      compact ? 10 : 12,
                      12,
                      compact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FD),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE9ECF5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Telemetry',
                          style: TextStyle(
                            color: Color(0xFF8A90A2),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DeviceWaveformChart(
                          samples: _buildWaveformSamples(pingMs),
                          height: telemetryHeight,
                          barWidth: compact ? 6 : 7,
                          spacing: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  SizedBox(
                    height: bottomLogHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: bottomLogHeight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lastLog,
                                maxLines: compact ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF8BFFCA),
                                  fontSize: 10,
                                  fontFamily: 'Courier',
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: bottomLogHeight,
                          height: bottomLogHeight,
                          child: IconButton(
                            onPressed: () => _showDeviceDetailsDialog(
                              context,
                              status,
                              isOnline,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF2EEFF),
                              foregroundColor: const Color(0xFF5B13EC),
                            ),
                            icon: const Icon(Icons.analytics_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool compact;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, compact ? 8 : 10, 12, compact ? 8 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A90A2),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accent,
              fontSize: compact ? 14 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOnline;

  const _StatusBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.green.withOpacity(0.12)
            : Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOnline ? 'ONLINE' : 'OFFLINE',
        style: TextStyle(
          color: isOnline ? Colors.green[700] : Colors.red[700],
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _EmptyDeckCard extends StatelessWidget {
  const _EmptyDeckCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECF5)),
      ),
      child: const Center(
        child: Text(
          'No devices available.',
          style: TextStyle(
            color: Color(0xFF8A90A2),
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
            ? (enabled ? const Color(0xFF5B13EC) : const Color(0xFFE6E1F9))
            : Colors.white,
        foregroundColor: isPrimary
            ? Colors.white
            : (enabled ? const Color(0xFF161A2D) : const Color(0xFFB3B8C5)),
        side: isPrimary
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE3E7F0)),
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
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE7EAF3), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SidebarBrand(),
            SizedBox(height: 24),
            _SidebarMenu(),
            Spacer(),
            Divider(color: Color(0xFFE7EAF3), height: 1),
            SizedBox(height: 16),
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
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFF5B13EC),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hexagon_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'MADAM',
          style: TextStyle(
            color: Color(0xFF161A2D),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
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
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          isActive: false,
        ),
        SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.router_outlined,
          label: 'Stations',
          isActive: true,
        ),
        SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.auto_awesome_motion_outlined,
          label: 'Automations',
          isActive: false,
        ),
        SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.local_library_outlined,
          label: 'Library',
          isActive: false,
        ),
        SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.settings_outlined,
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
    final bgColor = isActive ? const Color(0xFFF1EBFF) : Colors.transparent;
    final fgColor = isActive
        ? const Color(0xFF5B13EC)
        : const Color(0xFF6B7280);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: fgColor, size: 21),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarProfile extends StatelessWidget {
  const _SidebarProfile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF5B13EC), Color(0xFF8D63FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Madam User',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF161A2D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'v2-stable',
                style: TextStyle(color: Color(0xFF8A90A2), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
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

  String _formatNow(DateTime value) {
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
      'Dec',
    ];

    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final year = value.year.toString();

    return '$hour:$minute, $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE7EAF3), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Control Surface',
            style: TextStyle(
              color: Color(0xFF161A2D),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.state.isPolling ? 'Automation active' : 'Automation idle',
              style: const TextStyle(
                color: Color(0xFF5B13EC),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          if (widget.state.isPolling)
            Row(
              children: [
                const Text(
                  'Loop active',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.08),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  onPressed: widget.state.stopPingLoop,
                ),
              ],
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B13EC),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
              onPressed: widget.state.startPingLoop,
            ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Exit'),
            onPressed: widget.state.gracefulShutdownAndExit,
          ),
          const SizedBox(width: 20),
          Text(
            _formatNow(_now),
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF161A2D),
                ),
              ),
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF5B13EC), Color(0xFF8D63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCardsSection extends StatelessWidget {
  final DashboardState state;

  const _SummaryCardsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final onlineCount = state.deviceStatuses.values
        .where((s) => s.isOnline)
        .length;
    final relayCount = state.deviceStatuses.values
        .where((s) => s.isOnline && s.isRelayActive('relay_1'))
        .length;
    final automationState = state.isPolling ? 'Running' : 'Idle';
    final systemState = onlineCount > 0 ? 'Nominal' : 'Offline';

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _SummaryCard(
          width: 220,
          title: 'System Status',
          value: systemState,
          subtitle: '$onlineCount active nodes',
          icon: Icons.memory_rounded,
          colors: const [Color(0xFF5B13EC), Color(0xFF8B5CFF)],
        ),
        _SummaryCard(
          width: 220,
          title: 'Central Connection',
          value: onlineCount > 0 ? 'Stable' : 'Down',
          subtitle: 'Master link monitor',
          icon: Icons.hub_rounded,
          colors: const [Color(0xFF2563EB), Color(0xFF60A5FA)],
        ),
        _SummaryCard(
          width: 220,
          title: 'Active Relays',
          value: '$relayCount',
          subtitle: 'Relay_1 outputs online',
          icon: Icons.flash_on_rounded,
          colors: const [Color(0xFF059669), Color(0xFF34D399)],
        ),
        _SummaryCard(
          width: 220,
          title: 'Automations',
          value: automationState,
          subtitle: 'Polling edge rules',
          icon: Icons.auto_mode_rounded,
          colors: const [Color(0xFFEA580C), Color(0xFFF59E0B)],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _SummaryCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.26),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
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

class _RightPanel extends StatelessWidget {
  final DashboardState state;

  const _RightPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Favorites',
                    style: TextStyle(
                      color: Color(0xFF161A2D),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5B13EC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _FavoriteTile(
              title: 'ESP32C6 Master Node',
              subtitle: '192.168.55.29',
              icon: Icons.router_rounded,
              accent: Color(0xFF5B13EC),
            ),
            const SizedBox(height: 12),
            const _FavoriteTile(
              title: 'ESP8266 Actuator Node',
              subtitle: '192.168.55.20',
              icon: Icons.memory_rounded,
              accent: Color(0xFF2563EB),
            ),
            const SizedBox(height: 12),
            const _FavoriteTile(
              title: 'Relay Channel Monitor',
              subtitle: 'Quick output control',
              icon: Icons.flash_on_rounded,
              accent: Color(0xFF059669),
            ),
            const SizedBox(height: 12),
            const _FavoriteTile(
              title: 'Automation Bridge',
              subtitle: 'Edge trigger route',
              icon: Icons.auto_mode_rounded,
              accent: Color(0xFFEA580C),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F1D1D), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.34),
                    blurRadius: 28,
                    spreadRadius: 1,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sensors_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Security Alert',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Motion Detected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Review recent node activity and cross-check logs before dispatching a command.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
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

class _FavoriteTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _FavoriteTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF161A2D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8A90A2),
                    fontSize: 12,
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
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Colors.blueGrey, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
              if (state.isScanning)
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
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleLogs.length,
              itemBuilder: (context, index) {
                final log = visibleLogs[index];
                Color logColor = Colors.greenAccent;
                if (log.contains('OTOMASYON')) {
                  logColor = Colors.orangeAccent;
                }
                if (log.contains('HATA')) {
                  logColor = Colors.redAccent;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    '> $log',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: logColor,
                      fontFamily: 'Courier New',
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
