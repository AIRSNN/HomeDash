# MADAM Projesi - Ana Baglam Dosyasi (Guncel: 10 Mart 2026)

## 1. Proje Kimligi
- Proje adi: **HomeDash**
- Kod adi: **MADAM** (Multi-Agent Device Automation Manager)
- Amac: Ev ici test ortaminda calisan, ESP8266 ve ESP32-C6 tabanli cihazlari merkezi bir Windows kontrol merkezi uzerinden izleyen ve yoneten bir IoT ekosistemidir.
- Ana kontrol uygulamasi: **Windows uzerinde calisan Flutter/Dart tabanli HomeDash dashboard**

## 2. Kisaltmalar
- **MADAM**: HomeDash projesinin kod adi
- **Master Node**: Ana kontrol sorumlulugu verilen ESP32-C6 dugum
- **Node**: Sensor / aktuator gorevli uc cihaz

## 3. Temel Hedef
Bu sistemin ilk hedefi, laboratuvar/test ortaminda calisan cihazlari guvenilir sekilde:
1. agda gormek,
2. durumlarini izlemek,
3. JSON tabanli veri alisverisi yapmak,
4. role ve sensor senaryolarini kontrollu bicimde calistirmak,
5. ileride daha buyuk akilli ev mimarisine evrilebilecek temiz bir temel olusturmaktir.

## 4. Sistem Ozeti ve Ag Topolojisi
- Ag omurgasi 192.168.55.x alt agindadir.
- **ESP8266 (192.168.55.20):** Sensor/Tetikleyici (GPIO5 -> Role)
- **ESP32-C6 (192.168.55.29):** Hedef Kontrolcu / Master (GPIO18 -> Role)
- Dashboard, Windows PC uzerinde merkezi yonetim katmanidir.
- Ilk asamada odak noktasi: **kararli temel altyapi**, estetikten once **calisan cekirdek sistem**.

## 5. Tek Dogruluk Kaynagi (SOT) Dosyalari
- `docs/00_MADAM_MASTER_CONTEXT.md` -> Projenin genel baglami
- `docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md` -> Donanim ve ag sabitleri (degismez kabul edilir)
- `docs/02_MADAM_AI_DEVELOPMENT_RULES.md` -> AI icin calisma kurallari
- `docs/03_MADAM_PHASED_ROADMAP.md` -> Faz bazli ilerleme plani
- `docs/04_MADAM_PROMPT_TEMPLATES.md` -> Tekrar kullanilabilir prompt sablonlari

## 6. Yazilim Mimarisi Ilkeleri
- **UI Katmani Korunacaktir:** `dashboard_page.dart` ve UI bilesenleri stabildir. Sol menu, ust bar ve renk gecislerine KESINLIKLE dokunulmaz.
- **M2M Logic:** Edge Trigger (Yukselen Kenar). Sadece durum OFF'tan ON'a gectiginde tetikleme yapilir.
- UI ile ag / cihaz mantigi birbirinden ayrilmalidir.
- Ag hatalari sessizce yutulmamali; loglanmalidir.
- Timer, ping ve heartbeat islemleri non-blocking olmalidir.

## 7. Ilk Asama Basari Kriteri ve Mevcut Durum
Ilk asama basari kriterleri (cihazlari agda gorme, canli durum gosterme) saglanmistir. `docs/Arduino/HomeDash/` icindeki ESP kodlari hazirdir.

**Guncel Iyilestirme Backlog'u (Mimari Kararlar):**
1. **State Yonetimi Optimizasyonu (TAMAMLANDI):** `dashboard_state.dart` icindeki polling islemi `fetch` (veriyi topla) ve `commit` (state'e yaz) olarak ayrilacak (`Future.wait` darbo gazini asmak icin).
2. **Log Tamponu (Buffer) (TAMAMLANDI):** Gereksiz UI rebuild'lerini onlemek icin loglar sinirlanacak ve `notifyListeners` opsiyonel hale getirilecek.

## 8. Kapsam Disi Olanlar (Simdilik)
- karmasik kullanici yetkilendirme
- bulut senkronizasyonu
- dis internet erisimi
- ileri seviye sifreleme / uretim seviyesi guvenlik
- otomatik OTA yasam dongusu
