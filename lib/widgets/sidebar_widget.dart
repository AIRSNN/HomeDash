import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MADAM Projesi - Ana Navigasyon (Sidebar) Bileşeni
/// 
/// [MİMARİ NOT]: Bu modül, uygulamanın sol menüsünü ve navigasyon durumunu yönetir.
/// Kendi içinde state tutmaz (Stateless); seçilen indeks bilgisini ve tıklama
/// olaylarını callback (onItemSelected) üzerinden ana kabuğa (App Shell) iletir.
class SidebarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const SidebarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          // Sağ tarafa ince bir ayırıcı çizgi çekerek ana içerikten koparıyoruz
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SidebarBrand(),
            const SizedBox(height: 32),
            // Ana menü öğelerinin listelendiği bölüm
            _SidebarMenu(
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
            ),
            const Spacer(), // Menü öğeleri ile alt profil kısmını ayırır (esnek boşluk)
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 20),
            // Kullanıcı profil kartı
            const _SidebarProfile(),
          ],
        ),
      ),
    );
  }
}

/// Logo ve Marka (MADAM) Gösterimi
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

/// Menü Seçeneklerinin Konfigürasyonu
/// [MİMARİ NOT]: İleride yeni bir sayfa (Örn: Settings) aktif edilecekse
/// buraya yeni bir _SidebarItem eklenmesi ve ana sayfadaki IndexedStack'te
/// karşılığının oluşturulması yeterlidir.
class _SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _SidebarMenu({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SidebarItem(
          icon: Icons.dashboard_rounded,
          label: 'Dashboard',
          isActive: selectedIndex == 0,
          onTap: () => onItemSelected(0),
        ),
        const SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.memory_rounded,
          label: 'Stations',
          isActive: selectedIndex == 1,
          onTap: () => onItemSelected(1),
        ),
        const SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.auto_awesome_rounded,
          label: 'Automations',
          isActive: selectedIndex == 2,
          onTap: () => onItemSelected(2),
        ),
        const SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.analytics_rounded,
          label: 'Library',
          isActive: selectedIndex == 3, // Kütüphane İndeksi
          onTap: () => onItemSelected(3),
        ),
        const SizedBox(height: 8),
        _SidebarItem(
          icon: Icons.settings_rounded,
          label: 'Settings',
          isActive: selectedIndex == 4,
          onTap: () => onItemSelected(4),
        ),
      ],
    );
  }
}

/// Tekil Menü Butonu Tasarımı
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Aktif olma durumuna göre renk paleti değişimi
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
        onTap: onTap,
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

/// Kullanıcı Profil Kartı ve Animasyonlu Etkileşim
/// [MİMARİ NOT]: Hover (üzerine gelme) efekti için StatefulWidget kullanılmıştır.
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
                    // USER CORRECTION (Kural): MADAM User yerine Admin User kullanımı korundu.
                    'Admin User', 
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