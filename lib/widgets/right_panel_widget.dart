import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/dashboard_state.dart';

/// MADAM Projesi - Sağ Bilgi Paneli (Right Panel) Bileşeni
/// 
/// [MİMARİ NOT]: Bu modül, ekranın sağ tarafında yer alan Favori Cihazlar
/// listesini ve Dinamik Güvenlik Alarmı (Security Alert) durum kutusunu içerir.
/// Verilerini doğrudan DashboardState üzerinden anlık olarak okur.
class RightPanelWidget extends StatelessWidget {
  final DashboardState state;

  const RightPanelWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // MİMARİ NOT: Favori listesi statik veriden kurtarılıp gerçek state listesine bağlandı.
    // Şimdilik sistemdeki ilk 3 cihazı favori olarak alıyoruz. 
    final favoriteDevices = state.devices.take(3).toList();

    // MİMARİ NOT: Güvenlik Uyarı Paneli dinamik hale getirildi. 
    // Tüm cihazlar taranıp "motionStatus == detected" olan bir cihaz varsa alarm tetikleniyor.
    final alertDeviceIp = state.deviceStatuses.entries
        .where((e) => e.value.motionStatus == 'detected')
        .map((e) => e.key)
        .firstOrNull;
    final hasSecurityAlert = alertDeviceIp != null;
    final alertTime = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}";

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
            // --- FAVORİLER BAŞLIĞI ---
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
            
            // --- FAVORİLER LİSTESİ ---
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: favoriteDevices.length,
                itemBuilder: (context, index) {
                  final dev = favoriteDevices[index];
                  final isOnline = state.deviceStatuses[dev.ip]?.isOnline ?? false;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _FavoriteTile(
                      title: dev.id,
                      subtitle: dev.ip,
                      icon: dev.role.contains('primary') ? Icons.router_rounded : Icons.memory_rounded,
                      isActive: isOnline,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            
            // --- DİNAMİK GÜVENLİK ALARMI (SECURITY ALERT) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasSecurityAlert 
                      ? [const Color(0xFFDC2626), const Color(0xFF991B1B)] // Kırmızı Alarm
                      : [const Color(0xFF5B13EC), const Color(0xFF06B6D4)], // Normal Durum
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: (hasSecurityAlert ? const Color(0xFFDC2626) : const Color(0xFF5B13EC)).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      hasSecurityAlert ? Icons.warning_rounded : Icons.shield_rounded,
                      size: 80,
                      color: Colors.white10,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasSecurityAlert ? Icons.crisis_alert_rounded : Icons.verified_user_rounded,
                            color: hasSecurityAlert ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasSecurityAlert ? 'Security Alert' : 'System Secure',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hasSecurityAlert) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
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
                          'Source IP: $alertDeviceIp',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Time: $alertTime',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ] else ...[
                         Text(
                          'All sensors are normal.',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

/// [MİMARİ NOT]: Sadece RightPanelWidget içerisinde kullanılan 
/// özel bir liste elemanı (Tile) bileşeni.
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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