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
      backgroundColor: const Color(0xFFF8F9FB), // background-light
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
        final deckHeight = compact ? 540.0 : 640.0;

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
                      // Tailwind glass-shadow: rgba(91, 19, 236, 0.08)
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Station Deck',
                style: TextStyle(
                  color: Color(0xFF161A2D),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Live nodes, telemetry and quick actions',
                style: TextStyle(
                  color: Color(0xFF64748B),
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
              style: const TextStyle(
                color: Color(0xFF94A3B8),
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
    if (ms < 50) return const Color(0xFF00FF41); // cockpit green
    if (ms < 150) return Colors.orange;
    return Colors.redAccent;
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
        : '[SYSTEM] Awaiting stream...';
    final deviceIcon = device.role.toLowerCase().contains('primary')
        ? Icons.sensors_rounded
        : Icons.router_rounded;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 400;
        final outerPadding = compact ? 16.0 : 20.0;
        final telemetryHeight = compact ? 44.0 : 54.0;
        final iconBoxSize = compact ? 42.0 : 48.0;
        final metricGap = compact ? 10.0 : 12.0;
        final bottomLogHeight = compact ? 56.0 : 68.0;

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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B13EC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.memory_rounded,
                              size: 16,
                              color: Color(0xFF5B13EC),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: compact ? 34 : 38,
                            height: compact ? 34 : 38,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () =>
                                  _handleToggle(context, device.ip),
                              style: IconButton.styleFrom(
                                backgroundColor: isOnline
                                    ? const Color(0xFF5B13EC)
                                    : const Color(0xFFF1F5F9),
                                foregroundColor: isOnline
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                              ),
                              icon: Icon(
                                relay1Active
                                    ? Icons.power_settings_new_rounded
                                    : Icons.power_settings_new_rounded,
                                size: compact ? 18 : 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      Row(
                        children: [
                          Container(
                            width: iconBoxSize,
                            height: iconBoxSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Icon(
                              deviceIcon,
                              color: const Color(0xFF64748B),
                              size: compact ? 22 : 26,
                            ),
                          ),
                          SizedBox(width: compact ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
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
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    device.ip,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11,
                                      fontFamily: 'JetBrains Mono',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 16 : 20),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'LATENCY',
                              value: isOnline ? '${pingMs}ms' : '--',
                              accent: const Color(0xFF5B13EC),
                              compact: compact,
                            ),
                          ),
                          SizedBox(width: metricGap),
                          Expanded(
                            child: _MetricTile(
                              label: 'RELAY STATE',
                              value: relay1Active ? 'Active' : 'Standby',
                              accent: const Color(0xFF0EA5E9),
                              compact: compact,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 8),
                        child: DeviceWaveformChart(
                          samples: _buildWaveformSamples(pingMs),
                          height: telemetryHeight,
                          barWidth: compact ? 6 : 8,
                          spacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Dark Log Strip as seen in the HTML prototype
                Container(
                  width: double.infinity,
                  height: bottomLogHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A), // Tailwind slate-900
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(22),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lastLog,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF00FF41), // Cockpit Green
                                fontSize: 10,
                                fontFamily: 'JetBrains Mono',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isOnline) ...[
                              const SizedBox(height: 4),
                              const Text(
                                '> _ Awaiting sync...',
                                style: TextStyle(
                                  color: Color(0xFF00FF41),
                                  fontSize: 10,
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showDeviceDetailsDialog(context, status, isOnline),
                        icon: const Icon(
                          Icons.analytics_outlined,
                          color: Colors.white54,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent,
            fontSize: compact ? 16 : 18,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Text(
          'No devices available.',
          style: TextStyle(
            color: Color(0xFF64748B),
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

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
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
        const Text(
          'MADAM',
          style: TextStyle(
            color: Color(0xFF0F172A),
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
                style: TextStyle(
                  color: fgColor,
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Madam User',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'v2-stable',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontFamily: 'JetBrains Mono',
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
      'Dec',
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
            children: const [
              Text(
                'Active Stations',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Smart home devices real-time telemetry.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          if (widget.state.isPolling)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Automation Active',
                style: TextStyle(
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
              label: const Text('Stop'),
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
              label: const Text('Start'),
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
            label: const Text('Exit'),
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
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(_now),
                style: const TextStyle(
                  color: Color(0xFF64748B),
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
                    ),
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
            // Tailwind glass-shadow
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
                const Expanded(
                  child: Text(
                    'Favorites',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
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
                    backgroundColor: const Color(0xFF5B13EC).withOpacity(0.1),
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
            // Tailwind Security Alert with Active Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF5B13EC),
                    Color(0xFF06B6D4),
                  ], // Primary to Cyan (active-gradient)
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B13EC).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
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
                        children: const [
                          Icon(
                            Icons.crisis_alert_rounded,
                            color: Color(0xFFFCA5A5),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Security Alert',
                            style: TextStyle(
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
                        child: const Text(
                          'Motion Detected!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Zone: Outdoor Entryway',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Time: 23:14:05',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontFamily: 'JetBrains Mono',
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
          color: isActive ? const Color(0xFFE2E8F0) : Colors.transparent,
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
                ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
                              color: const Color(0xFF00FF41).withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
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
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontFamily: 'JetBrains Mono',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SYSTEM LOGS (REAL-TIME)',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
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
                Color logColor = const Color(
                  0xFF00FF41,
                ); // Cockpit green defaults
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
                    style: TextStyle(
                      color: logColor,
                      fontFamily: 'JetBrains Mono',
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
