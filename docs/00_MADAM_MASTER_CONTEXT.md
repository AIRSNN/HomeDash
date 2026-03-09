# MADAM Projesi - Ana Bağlam Dosyası (Güncel: 6 Mart 2026)

## 1. Proje Kimliği
- Proje adı: **HomeDash**
- Kod adı: **MADAM** (Multi-Agent Device Automation Manager)
- Amaç: Ev içi test ortamında çalışan, ESP8266 ve ESP32-C6 tabanlı cihazları merkezi bir Windows kontrol merkezi üzerinden izleyen ve yöneten bir IoT ekosistemidir.
- Ana kontrol uygulaması: **Windows üzerinde çalışan Flutter/Dart tabanlı HomeDash dashboard**

## 2. Kısaltmalar
- **MADAM**: HomeDash projesinin kod adı
- **Master Node**: Ana kontrol sorumluluğu verilen ESP32-C6 düğüm
- **Node**: Sensör / aktüatör görevli uç cihaz

## 3. Temel Hedef
Bu sistemin ilk hedefi, laboratuvar/test ortamında çalışan cihazları güvenilir şekilde:
1. ağda görmek,
2. durumlarını izlemek,
3. JSON tabanlı veri alışverişi yapmak,
4. röle ve sensör senaryolarını kontrollü biçimde çalıştırmak,
5. ileride daha büyük akıllı ev mimarisine evrilebilecek temiz bir temel oluşturmaktır.

## 4. Sistem Özeti & Ağ Topolojisi
- Ağ omurgası 192.168.55.x alt ağındadır.
- **ESP8266 (192.168.55.20):** Sensör/Tetikleyici (GPIO5 -> Röle)
- **ESP32-C6 (192.168.55.29):** Hedef Kontrolcü / Master (GPIO18 -> Röle)
- Dashboard, Windows PC üzerinde merkezi yönetim katmanıdır.
- İlk aşamada odak noktası: **kararlı temel altyapı**, estetikten önce **çalışan çekirdek sistem**.

## 5. Tek Doğruluk Kaynağı (SOT) Dosyaları
- `docs/00_MADAM_MASTER_CONTEXT.md` -> Projenin genel bağlamı
- `docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md` -> Donanım ve ağ sabitleri (değişmez kabul edilir)
- `docs/02_MADAM_AI_DEVELOPMENT_RULES.md` -> AI için çalışma kuralları
- `docs/03_MADAM_PHASED_ROADMAP.md` -> Faz bazlı ilerleme planı
- `docs/04_MADAM_PROMPT_TEMPLATES.md` -> Tekrar kullanılabilir prompt şablonları

## 6. Yazılım Mimarisi İlkeleri
- **UI Katmanı Korunacaktır:** `dashboard_page.dart` ve UI bileşenleri stabildir. Sol menü, üst bar ve renk geçişlerine KESİNLİKLE dokunulmaz.
- **M2M Logic:** Edge Trigger (Yükselen Kenar). Sadece durum OFF'tan ON'a geçtiğinde tetikleme yapılır.
- UI ile ağ / cihaz mantığı birbirinden ayrılmalı.
- Ağ hataları sessizce yutulmamalı; loglanmalı.
- Timer, ping ve heartbeat işlemleri non-blocking olmalı.

## 7. İlk Aşama Başarı Kriteri & Mevcut Durum
İlk aşama başarı kriterleri (cihazları ağda görme, canlı durum gösterme) sağlanmıştır. `docs/Arduino/HomeDash/` içindeki ESP kodları hazırdır.

**Güncel İyileştirme Backlog'u (Mimari Kararlar):**
1. **State Yönetimi Optimizasyonu:** `dashboard_state.dart` içindeki polling işlemi `fetch` (veriyi topla) ve `commit` (state'e yaz) olarak ayrılacak (`Future.wait` darboğazını aşmak için).
2. **Log Tamponu (Buffer):** Gereksiz UI rebuild'lerini önlemek için loglar sınırlanacak ve `notifyListeners` opsiyonel hale getirilecek.

## 8. Kapsam Dışı Olanlar (Şimdilik)
- karmaşık kullanıcı yetkilendirme
- bulut senkronizasyonu
- dış internet erişimi
- ileri seviye şifreleme / üretim seviyesi güvenlik
- otomatik OTA yaşam döngüsü
