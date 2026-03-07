/// MADAM Projesi - Modern App Shell (Sidebar + Top Header)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/device_table.dart';
import '../state/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final dashboardState = Provider.of<DashboardState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: Row(
        children: [
          _Sidebar(state: dashboardState),
          Expanded(
            child: Column(
              children: [
                _TopHeader(state: dashboardState),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F7FC),
                    padding: const EdgeInsets.all(20),
                    child: DeviceTable(state: dashboardState),
                  ),
                ),
                _SystemLogsPanel(state: dashboardState),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final DashboardState state;

  const _Sidebar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE7EAF3), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SidebarBrand(),
            const SizedBox(height: 28),
            const _SidebarMenu(),
            const Spacer(),
            const Divider(color: Color(0xFFE7EAF3), height: 1),
            const SizedBox(height: 18),
            _SidebarProfile(state: state),
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
            size: 24,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: fgColor, size: 22),
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
  final DashboardState state;

  const _SidebarProfile({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
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

class _TopHeader extends StatelessWidget {
  final DashboardState state;

  const _TopHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7EAF3), width: 1)),
      ),
      child: Row(
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Stations',
                style: TextStyle(
                  color: Color(0xFF161A2D),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Monitor and control all MADAM edge devices.',
                style: TextStyle(color: Color(0xFF8A90A2), fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          // OTOMASYON VE DÖNGÜ KONTROLLERİ
          if (state.isPolling)
            Row(
              children: [
                const Text(
                  'Döngü Aktif',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.stop),
                  label: const Text('Durdur'),
                  onPressed: state.stopPingLoop,
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
              label: const Text('Başlat'),
              onPressed: state.startPingLoop,
            ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Çıkış'),
            onPressed: state.gracefulShutdownAndExit,
          ),
          const SizedBox(width: 24),
          // Saat Bilgisi
          const Text(
            '11:06, 07 Mar 2026',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          // Bildirim İkonu
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

class _SystemLogsPanel extends StatelessWidget {
  final DashboardState state;

  const _SystemLogsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
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
                  fontSize: 12,
                  letterSpacing: 1.2,
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
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                Color logColor = Colors.greenAccent;
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
                    style: TextStyle(
                      color: logColor,
                      fontFamily: 'Courier New',
                      fontSize: 12,
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
