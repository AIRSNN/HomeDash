# MADAM Projesi - Ana Bağlam Dosyası

## 1. Proje Kimliği
- Proje adı: **HomeDash**
- Kod adı: **MADAM**
- Amaç: Ev içi test ortamında çalışan, ESP8266 ve ESP32-C6 tabanlı cihazları merkezi bir Windows 10 PC üzerinden izleyen ve yöneten bir akıllı ev sistemi geliştirmek.
- Ana kontrol uygulaması: **Windows 10 üzerinde çalışan Flutter/Dart tabanlı HomeDash dashboard**
- Geliştirme yöntemi: Kod üretimi ve iterasyon için **Google Antigravity (GA)** içinde çalışan **Gemini 3.1 Pro High (ai)** kullanılarak prompt-tabanlı geliştirme

## 2. Kısaltmalar
- **GA**: Google Antigravity
- **ai**: Gemini 3.1 Pro High
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

## 4. Sistem Özeti
- Ağ omurgası 192.168.55.x alt ağındadır.
- ESP cihazlar statik IP ile çalışır.
- Dashboard, Windows 10 PC üzerinde merkezi yönetim katmanıdır.
- Cihazlar ile dashboard arasında hafif, anlaşılır ve hata ayıklaması kolay bir JSON haberleşme modeli tercih edilir.
- İlk aşamada odak noktası: **kararlı temel altyapı**, estetikten önce **çalışan çekirdek sistem**.

## 5. Tek Doğruluk Kaynağı Dosyaları
Bu proje ilerledikçe yeni sohbetlerde önce aşağıdaki dosyalar referans alınmalıdır:
- `00_MADAM_MASTER_CONTEXT.md` -> Projenin genel bağlamı
- `01_MADAM_HARDWARE_AND_NETWORK_SOT.md` -> Donanım ve ağ sabitleri (değişmez kabul edilir)
- `02_MADAM_AI_DEVELOPMENT_RULES.md` -> GA/ai için çalışma kuralları
- `03_MADAM_PHASED_ROADMAP.md` -> Faz bazlı ilerleme planı
- `04_MADAM_PROMPT_TEMPLATES.md` -> Tekrar kullanılabilir prompt şablonları

## 6. Mevcut Test Topolojisi
Bilinen test senaryosu:
- Bir veya daha fazla **ESP8266** düğümü sensör / aktüatör rolünde kullanılacak.
- Bir veya daha fazla **ESP32-C6** düğümü röle / merkez kontrol görevlerinde kullanılacak.
- Windows 10 PC, hem ağ izleme hem de dashboard arayüzü tarafında merkezi düğümdür.
- El çizimi şemaya göre:
  - ESP8266 tarafında PIR ve anahtar girişi düşünülüyor.
  - ESP32-C6 tarafında birden fazla röle çıkışı planlanıyor.

## 7. Yazılım Mimarisi İlkeleri
- Flutter/Dart kodu modüler olmalı.
- UI ile ağ / cihaz mantığı birbirinden ayrılmalı.
- Cihaz listesi, IP yapılandırması ve protokol sabitleri tek yerde tutulmalı.
- Ağ hataları sessizce yutulmamalı; loglanmalı.
- Timer, ping ve heartbeat işlemleri non-blocking olmalı.
- Her cihaz için ileride şu katmanlar düşünülmeli:
  - Discovery / kayıt
  - Health monitoring
  - Telemetry
  - Command / control
  - Automation rules

## 8. İlk Aşama Başarı Kriteri
İlk aşama tamamlanmış sayılabilmesi için:
- HomeDash açılmalı,
- cihaz listesi yüklenmeli,
- ağdaki hedef IP'ler izlenebilmeli,
- canlı durum (online/offline) gösterilebilmeli,
- en az bir ESP8266 ve bir ESP32-C6 ile temel iletişim doğrulanmalıdır.

## 9. Kapsam Dışı Olanlar (Şimdilik)
Aşağıdakiler ilk çekirdeğin dışında tutulmalıdır:
- karmaşık kullanıcı yetkilendirme
- bulut senkronizasyonu
- dış internet erişimi
- ileri seviye şifreleme / üretim seviyesi güvenlik
- otomatik OTA yaşam döngüsü
- çok katmanlı veritabanı mimarisi

## 10. Çalışma Notu
Bu proje, önce laboratuvar gerçekliği ile uyumlu şekilde sade ve doğrulanabilir ilerlemelidir. "Mükemmel görünen ama sahada kırılan" yapı yerine, küçük ama sağlam çalışan modüller tercih edilmelidir.
