# MADAM HomeDash

MADAM HomeDash, yerel ağdaki ESP8266 ve ESP32-C6 tabanlı cihazları izlemek, durum verisi toplamak, komut göndermek ve temel M2M otomasyon akışlarını çalıştırmak için geliştirilen bir Flutter Windows masaüstü kontrol panelidir.

## Proje Amacı

Bu projenin amacı:

- Yerel ağdaki cihazların erişilebilirliğini ve canlı durumunu izlemek
- `GET /status` ile cihaz telemetrilerini toplamak
- `POST /command` ile doğrulanmış cihaz komutları göndermek
- Edge-trigger tabanlı M2M otomasyon senaryoları çalıştırmak
- Dashboard yazılımı ile firmware kaynaklarını aynı repo içinde birlikte versiyonlamak

## Mevcut Kapsam

HomeDash şu anda aşağıdaki ana yeteneklere sahiptir:

- Windows üzerinde çalışan Flutter dashboard
- Cihaz kayıt listesi ve canlı durum takibi
- Asenkron ping/erişilebilirlik kontrolü
- HTTP tabanlı `/status` veri okuma
- Şema doğrulamalı `/command` gönderimi
- `OFF -> ON` edge-trigger mantığına dayalı otomasyon
- Graceful shutdown / temiz çıkış akışı
- Oturum geçmişi, backlog ve teknik SOT dokümantasyonu

## Ağ ve Sistem Özeti

Ağ ve donanım sabitleri için tek doğruluk kaynağı:

- [`docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md`](docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md)

Kısa özet:

- Ağ: `192.168.55.0/24`
- Dashboard IP: `192.168.55.100`
- ESP statik IP aralığı: `192.168.55.20 - 192.168.55.29`
- API portu: `8080`
- İletişim modeli: `application/json`

## Kurulum

### Gereksinimler

- Flutter SDK
- Windows geliştirme araçları
- Aynı yerel ağa bağlı test cihazları

### Adımlar

1. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

2. Statik analizi çalıştırın:
   ```bash
   flutter analyze
   ```

3. Uygulamayı Windows üzerinde başlatın:
   ```bash
   flutter run -d windows
   ```

4. İsteğe bağlı olarak üretim çıktısı alın:
   ```bash
   flutter build windows
   ```

## Proje Yapısı

```text
HomeDash/
├─ lib/
│  ├─ config/
│  ├─ models/
│  ├─ pages/
│  ├─ services/
│  ├─ state/
│  └─ widgets/
├─ docs/
│  ├─ 00_MADAM_MASTER_CONTEXT.md
│  ├─ 01_MADAM_HARDWARE_AND_NETWORK_SOT.md
│  ├─ 02_MADAM_AI_DEVELOPMENT_RULES.md
│  ├─ 03_MADAM_PHASED_ROADMAP.md
│  ├─ 04_MADAM_PROMPT_TEMPLATES.md
│  ├─ TECHNICAL_DOCS.md
│  ├─ COMMAND_SCHEMA_SOT.md
│  ├─ WORK_TODO.md
│  ├─ CHANGE_CONTROL.md
│  ├─ SESSION_LOG.md
│  ├─ NEXT_SESSION_PROMPT.md
│  ├─ Arduino/
│  └─ UI ve Web taslak/
├─ test/
├─ windows/
├─ pubspec.yaml
└─ README.md
```

## Dokümantasyon İndeksi

### Temel Bağlam ve Kurallar

- [`docs/00_MADAM_MASTER_CONTEXT.md`](docs/00_MADAM_MASTER_CONTEXT.md)
  Projenin genel bağlamı, sistem özeti, mimari ilkeler ve ana SOT listesi.

- [`docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md`](docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md)
  Donanım, IP planı, ağ sabitleri ve değişmemesi gereken sistem parametreleri için tek doğruluk kaynağı.

- [`docs/02_MADAM_AI_DEVELOPMENT_RULES.md`](docs/02_MADAM_AI_DEVELOPMENT_RULES.md)
  Farklı AI asistanlarıyla çalışırken korunması gereken geliştirme kuralları ve mimari sınırlar.

- [`docs/03_MADAM_PHASED_ROADMAP.md`](docs/03_MADAM_PHASED_ROADMAP.md)
  Projenin faz bazlı gelişim yol haritası.

- [`docs/04_MADAM_PROMPT_TEMPLATES.md`](docs/04_MADAM_PROMPT_TEMPLATES.md)
  Tekrar kullanılabilir prompt şablonları ve bağlam yükleme kalıpları.

### Teknik Tasarım ve API Belgeleri

- [`docs/TECHNICAL_DOCS.md`](docs/TECHNICAL_DOCS.md)
  `DashboardState`, provider tabanlı state yönetimi ve edge-trigger otomasyon mantığının teknik açıklaması.

- [`docs/COMMAND_SCHEMA_SOT.md`](docs/COMMAND_SCHEMA_SOT.md)
  `/command` endpoint'i için payload sözleşmesi, doğrulama kuralları ve örnek JSON gövdeleri.

### Operasyonel ve Süreç Belgeleri

- [`docs/WORK_TODO.md`](docs/WORK_TODO.md)
  Güncel backlog, tamamlanan işler ve sıradaki fazlar.

- [`docs/CHANGE_CONTROL.md`](docs/CHANGE_CONTROL.md)
  Mimari değişiklikler, önemli kararlar ve kırılma riski taşıyan noktalar.

- [`docs/SESSION_LOG.md`](docs/SESSION_LOG.md)
  Önceki geliştirme oturumlarının kronolojik kayıtları.

- [`docs/NEXT_SESSION_PROMPT.md`](docs/NEXT_SESSION_PROMPT.md)
  Sonraki AI oturumunu başlatmak için kullanılan geçici/handoff prompt dosyası.

### Ek Kaynaklar

- `docs/Arduino/HomeDash/`
  ESP8266 ve ESP32-C6 firmware kaynakları.

- `docs/UI ve Web taslak/`
  UI denemeleri, HTML taslakları ve yardımcı notlar.

## Tek Doğruluk Kaynakları

Aşağıdaki belgeler öncelikli referans kabul edilmelidir:

- Ağ ve donanım sabitleri için:
  [`docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md`](docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md)

- `/command` payload sözleşmesi için:
  [`docs/COMMAND_SCHEMA_SOT.md`](docs/COMMAND_SCHEMA_SOT.md)

- Proje bağlamı ve mimari çerçeve için:
  [`docs/00_MADAM_MASTER_CONTEXT.md`](docs/00_MADAM_MASTER_CONTEXT.md)

## Notlar

- README özet seviyesinde tutulmuştur; ayrıntılı teknik ve süreç belgeleri `docs/` altında yer alır.
- Farklı AI asistanlarıyla çalışırken önce `docs/00`, `docs/01`, `docs/02` ve ilgili görev belgesi okunmalıdır.
- Prompt/handoff belgeleri zamanla eskiyebilir; güncel durum için `docs/SESSION_LOG.md` ve `docs/WORK_TODO.md` birlikte değerlendirilmelidir.
