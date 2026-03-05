# WORK_TODO.md

Bu dosya projede yapılacak işleri, alınan kararları ve bekleyen görevleri listelemek için kullanılacaktır. Ağ sabitleri ve cihaz rolleri, mevcut kod mimarisinde korunmuş olup değiştirilemez yapıdadır.

## Tamamlanan İşler
- [x] Klasör ve alt klasör iskeletinin oluşturulması (`docs`, `lib/*`, `test`).
- [x] Temel Flutter UI sınıf iskeleti (`app.dart`, `dashboard_page.dart` vb.).
- [x] SOT referans alınarak `network_constants.dart` ve `device_registry.dart` sabitleri kodlandı.
- [x] Flutter Proje Başlatması: `pubspec.yaml` ve Windows build ilklendirmesi yapıldı, const derleme hataları tamamen temizlendi.
- [x] `lib/services/ping_service.dart`: Asenkron TCP socket ping algoritması kodlandı. (Faz 2)
- [x] `lib/services/device_command_service.dart`: HTTP `GET /status` ile JSON okuma ve UI tablosuna aktarma yapıldı. (Faz 3)
- [x] Projenin Git deposu oluşturulup GitHub'a yedeklendi.
- [x] Salt-okuma cihaz ayrıntıları dialogu eklendi (`DeviceTable` satır eylemi). (Faz 4-a)
- [x] Dry-run komut önizleme: "Test Komutu Hazırla" butonu ve payload gösterimi tamamlandı. (Faz 4-a)
- [x] `device_table.dart` eksik `DeviceCommandService` importu giderildi; Windows build başarılı.
- [x] `/command` JSON şeması belgelendi: `docs/COMMAND_SCHEMA_SOT.md` oluşturuldu ve doğrulandı.

## Bekleyen Görevler (Öncelik Sırasıyla)

> ⚠️ **Kural:** Gerçek HTTP POST (`sendCommand`) yalnızca `docs/COMMAND_SCHEMA_SOT.md` onaylandıktan sonra kodlanabilir.
> ⛔ **Uyarı:** `sendCommand()` servisi tamamlanmadan UI tarafına gerçek komut bağlantısı eklenmemelidir.

1. **[SONRAKİ ADIM — Faz 4-b]** `device_command_service.dart` içindeki `sendCommand()` placeholder'ını şema-doğrulamalı gerçek HTTP POST ile değiştir:
   - `action` / `target` / `deviceIp` doğrulaması (R-01 – R-05)
   - Geçersiz kombinasyonlarda `false` dön, istek gönderme
   - Timeout + try/catch korumalı `dart:io` `HttpClient` POST
   - Yalnızca bu tek metot değiştirilmeli; başka dosya dokunulmamalı
2. **Servis doğrulandıktan sonra:** UI detay dialoguna gerçek gönder butonu eklenebilir. (Faz 4-c)
3. **İsteğe bağlı:** `flutter analyze` `info` uyarılarını gidermek için tüm `/// MADAM Projesi - ...` başlık yorumlarından sonra `library <isim>;` direktifi ekle.


