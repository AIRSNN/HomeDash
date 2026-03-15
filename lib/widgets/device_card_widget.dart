import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/device_info.dart';
import '../state/dashboard_state.dart';

/// MADAM Projesi - Dinamik Cihaz Kartı (Device Card) Bileşeni
/// 
/// [MİMARİ NOT]: Bu modül, ağdaki her bir cihazın (Node) durumunu, telemetrisini
/// ve ayarlarını gösteren ana arayüz bileşenidir. İçerisinde alt sekmeler (Tabs),
/// sensör göstergeleri, röle kontrolleri ve ping dalga animasyonu bulunur.
/// Veriyi doğrudan [DashboardState] üzerinden cihazın IP adresini baz alarak çeker.

enum DeviceCardTab { usage, device, setting }

class DeviceCardWidget extends StatefulWidget {
  final DashboardState state;
  final DeviceInfo device;

  const DeviceCardWidget({
    super.key,
    required this.state,
    required this.device,
  });

  @override
  State<DeviceCardWidget> createState() => _DeviceCardWidgetState();
}

class _DeviceCardWidgetState extends State<DeviceCardWidget> {
  DeviceCardTab _activeTab = DeviceCardTab.usage;

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
    required bool canInteract, // YENİ: Etkileşim yetkisi parametresi eklendi
    required int pingMs,
    required dynamic status,
  }) {
    return Column(
      key: const ValueKey(DeviceCardTab.usage),
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
                // Cihaz Online ise tarama dursa da Online görünmeye devam eder
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
                    canInteract: canInteract, // YENİ KURAL: Butonun kilitli olup olmadığını belirler
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
                    canInteract: canInteract,
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
                    canInteract: canInteract,
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
      key: const ValueKey(DeviceCardTab.device),
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
                label: 'Ping Sırası',
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
    required dynamic status,
  }) {
    final rawUptime = status?.rawData?['uptime'];
    final uptimeStr = rawUptime != null ? '$rawUptime sn' : 'Bilinmiyor';

    return Column(
      key: const ValueKey(DeviceCardTab.setting),
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
                title: 'Uptime',
                value: isOnline ? uptimeStr : '--',
                icon: Icons.timer_rounded,
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
    required bool canInteract, // Parametre eklendi
    required int pingMs,
    required dynamic status,
  }) {
    switch (_activeTab) {
      case DeviceCardTab.device:
        return _buildDeviceContent(
          compact: compact,
          isOnline: isOnline,
          status: status,
        );
      case DeviceCardTab.setting:
        return _buildSettingContent(
          compact: compact,
          isOnline: isOnline,
          status: status,
        );
      case DeviceCardTab.usage:
        return _buildUsageContent(
          compact: compact,
          isOnline: isOnline,
          canInteract: canInteract, // Alta geçirildi
          pingMs: pingMs,
          status: status,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.state.deviceStatuses[widget.device.ip];
    final isOnline = status?.isOnline ?? false;
    
    // [MİMARİ NOT]: GÜVENLİK KİLİDİ 
    // Cihaz Online olsa bile "Stop" modundaysak (isPolling false), 
    // karttaki tüm röle, reset gibi buton etkileşimlerini kilitliyoruz.
    final bool canInteract = isOnline && widget.state.isPolling;

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
                    0, 
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                            child: Text(
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
                          ),
                          SizedBox(width: 8), 
                          SizedBox(
                            width: compact ? 34 : 38,
                            height: compact ? 34 : 38,
                            child: IconButton(
                              tooltip: canInteract ? 'Cihazı yeniden başlat' : 'Sistem durduruldu (Kilitli)',
                              padding: EdgeInsets.zero,
                              // YENİ KURAL: Reset butonu canInteract kuralına bağlandı
                              onPressed: canInteract
                                  ? () => _confirmReboot(
                                        context,
                                        widget.device.ip,
                                      )
                                  : null,
                              style: IconButton.styleFrom(
                                backgroundColor: canInteract 
                                    ? const Color(0xFFFEF2F2) 
                                    : const Color(0xFFF1F5F9),
                                foregroundColor: canInteract 
                                    ? const Color(0xFFDC2626) 
                                    : const Color(0xFF94A3B8),
                              ),
                              icon: Icon(
                                Icons.restart_alt_rounded,
                                size: compact ? 18 : 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 10 : 12),
                      
                      // Rozet (Badge) Tasarımı (Değişmedi)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isOnline
                              ? const Color(0xFF5B13EC).withOpacity(0.05)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.device.ip,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(
                            color: isOnline
                                ? const Color(0xFF5B13EC)
                                : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
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
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      outerPadding,
                      0,
                      outerPadding,
                      outerPadding - 4,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _buildTabContent(
                        compact: compact,
                        isOnline: isOnline,
                        canInteract: canInteract, // Alta aktarıldı
                        pingMs: pingMs,
                        status: status,
                      ),
                    ),
                  ),
                ),

                if (_activeTab == DeviceCardTab.usage) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: outerPadding),
                    child: _WaveformDisplay(
                      pingMs: pingMs,
                      height: telemetryHeight,
                      // YENİ KURAL: Stop tuşuna basıldığında animasyon dalgaları düz çizgiye iner
                      isOnline: canInteract, 
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
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

// -----------------------------------------------------------------------------
// ALT BİLEŞENLER (Sadece Bu Dosyada Kullanılır)
// -----------------------------------------------------------------------------

class _DeviceCardTabs extends StatelessWidget {
  final DeviceCardTab activeTab;
  final ValueChanged<DeviceCardTab> onTabChanged;

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
              isActive: activeTab == DeviceCardTab.usage,
              onTap: () => onTabChanged(DeviceCardTab.usage),
            ),
          ),
          Expanded(
            child: _DeviceTabButton(
              label: 'DEVICE',
              isActive: activeTab == DeviceCardTab.device,
              onTap: () => onTabChanged(DeviceCardTab.device),
            ),
          ),
          Expanded(
            child: _DeviceTabButton(
              label: 'SETTING',
              isActive: activeTab == DeviceCardTab.setting,
              onTap: () => onTabChanged(DeviceCardTab.setting),
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
  final bool isOnline; // Kartın genel online durumu (stil için)
  final bool canInteract; // YENİ KURAL: Tıklanabilir mi?
  final VoidCallback onTap;

  const _RelayControlTile({
    required this.label,
    required this.isActive,
    required this.isOnline,
    required this.canInteract,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tıklanabilirlik kurala bağlandı
      onTap: canInteract ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // Kilitli ise pasif renk al
          color: !canInteract
              ? const Color(0xFFF1F5F9)
              : isActive
                  ? const Color(0xFF5B13EC)
                  : const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive && canInteract
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
              color: !canInteract
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
                color: !canInteract
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