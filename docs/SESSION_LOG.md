# SESSION_LOG.md

Bu dosya oturum sirasindaki onemli asamalari, kararlari ve tamamlanan adimlari kaydetmek icin kullanilacaktir.

## Architecture Update (2026-03-10)
- `dashboard_state.dart` uzerinde Fetch/Commit mimarisi kurularak cihaz polling dongusu optimize edildi.
- UI darbo gazlari ve RenderFlex tasmalar tamamen giderildi.
- Log hafizasi sinirlandirilarak bellek sizintilarinin onune gecildi.
- Sistem Phase 6 (Gunlukleme) ve Phase 7 (Paketleme) asamalarina hazir hale geldi.

## Session Update - UI Stabilization & Phase 4-a Completion (2026-03-10)
- "RenderFlex overflow" tasinti hatasi, `dashboard_page.dart` icerisinde sabit ust bilgi (header), esnek/kaydirilabilir orta alan (scrollable body) ve sabit alt log alani (footer) mimarisi kurularak kalici olarak cozuldu.
- Dalga formu (Waveform) grafigi yalnizca USAGE sekmesine izole edildi.
- Faz 4-a (Ayrintilar Dialogu ve Dry-run Onizleme) ozellikleri hicbir zarar gormeden yeni arayuz zirhi icine entegre edildi.
- UI tamamen stabil hale getirildi ve Git yedegi alindi. Siradaki hedef Faz 4-b olarak belirlendi.

## Phase 4-b Validation & Resilience (2026-03-10)
- Reboot/reset komutlari guvenlik kalkanina eklendi.
- Try/Catch bloklarinin `HttpException` durumlarinda uygulamayi cokmekten kurtardigi teyit edildi.
- ESP firmware'leri ile %100 uyum saglandi.

## Ikinci Oturum Kayitlari (Flutter Iskelet Kurulumu)
- **Klasor Yapisi:** Proje genel gereksinimlerine gore `/lib` alt klasorleri (`config`, `models`, `services`, `pages`, `widgets`, `state`) ve `/docs`, `/test` gibi ana dizin iskeleti kuruldu.
- **Flutter Temel Dosyalari:** `main.dart` ve `app.dart` giris siniflari "HomeDash (MADAM)" olarak ilklendirildi ancak derlenebilir placeholder (is mantigi olmayan iskelet) halinde birakildi.
- **Guvenli Ag Sabitleri:** `docs/01_MADAM_HARDWARE_AND_NETWORK_SOT.md` baglam dosyasina sadik kalinarak `lib/config/network_constants.dart` icerisine IP (`192.168.55.100`), SSID (`llama_iot`), subnet ve mask (`255.255.255.0`) gibi veriler eklenerek korundu.
- **Donanim Kaydi:** `lib/config/device_registry.dart` dosyasi guncellenerek IP `192.168.55.20-28` sensor, `.29` ise acik yorumla "Ana Kontrol Dugumu / Primary Controller" rolune atandi.
- **UI Iskeleti ve State:** `DashboardPage` stateful yapiya gecirilerek `DashboardState` ile entegre edildi, cihaz listesi `DeviceTable` araciligiyla goruntulendi. Ping degerleri ve log satirlari icin yer tutucu (placeholder) nesneler konuldu.

## Bugunku Oturum Kayitlari (Flutter Build, TCP Ping ve JSON Okuma)
- **Guvenli Windows Build:** `homedash` projesi `flutter create` ile Windows altyapisina kavusturuldu ve `pubspec.yaml` hazirlandi. Widget agacindaki `const` kaynakli runtime cokmeleri giderilerek `%100` hatasiz derleme saglandi.
- **Asenkron Ag Tarama (Faz 2):** ICMP yerine Dart `dart:io` `Socket` kutuphanesi kullanilarak eszamanli (non-blocking) TCP 8080 port yoklamasi (`ping_service.dart`) kodlandi ve `DashboardState` timer'i ile baglandi.
- **HTTP JSON Durum Okuma (Faz 3):** `device_command_service.dart` uzerinden `GET /status` endpointine istek atan yapi eklendi. Cokmeyi engelleyen null-safe `DeviceStatus` fallback sistemi gelistirildi.
- **UI Entegrasyonu:** `DeviceTable` icerisine "Durum Verisi / JSON" sutunu eklendi. Gelen dinamik JSON verisi (relay, is_active, temperature vb.) parse edilerek kisa ozet olarak arayuze bastirildi. Timer aktiflestikce UI yenilenmesi saglandi.

## Bugunku Oturum Kayitlari - Ayrintilar Dialogu ve Dry-Run Onizleme (2026-03-05)
- **Ayrintilar Dialogu (Faz 4-a):** `DeviceTable` satir eylemlerine (`settings` ikonu) bagli salt-okuma bir cihaz detay dialogu eklendi. Dialog; IP, durum (Online/Offline), son gorulme saati, JSON ozeti ve `rawData` anahtar listesini gostermektedir.
- **Dry-Run Komut Onizleme:** Dialog icine "Test Komutu Hazirla" butonu entegre edildi. Buton yalnizca cihaz online iken gorunur; tiklandiginda `DeviceCommandService.generateDryRunPayload()` cagrilir, uretilen payload (`action`, `target`, `value`, `deviceIp`) dialog icinde monospace kutuda gosterilir. Hicbir HTTP istegi yapilmaz.
- **Eksik Import Giderildi:** `DeviceCommandService` sinifi `device_table.dart` icinde kullaniliyor ancak import edilmemisti; `lib/services/device_command_service.dart` import satiri eklenerek derleme hatasi temizlendi.
- **Windows Build Basarili:** `flutter build windows` calistirildi, `homedash.exe` basariyla uretildi (cikis kodu 0). `flutter analyze` sifir hata dondurdu (yalnizca `info`-seviyesi doc comment uyarilari).
- **`/command` JSON Sema SOT Olusturuldu:** `docs/COMMAND_SCHEMA_SOT.md` belgesi tum payload alanlarini (`action`, `target`, `value`, `deviceIp`, `timestamp`), izin verilen degerleri, dogrulama kurallarini (R-01-R-06) ve 3 ornek payload'i icerecek bicimde hazirlandi ve dogrulandi.
- **Gercek `sendCommand()` Uygulamasi TAMAMLANMADI:** Schema-dogrulamali HTTP POST implementasyonu bu oturumda baslatildi ancak agent kesintisi nedeniyle tamamlanamadi. `device_command_service.dart` icindeki `sendCommand()` hala placeholder durumundaydi ve degistirilmemisti. Bu gorev sonraki oturuma ertelendi.

**Bu Oturumun Sonu - Kararli Durum:**
Proje `flutter build windows` ile basariyla derlenmekte, dry-run komut onizlemesi calismakta, gercek POST devre disiydi. Sonraki adim: sema onayi alindiktan sonra `sendCommand()` implementasyonu.

## Session Update - Phase 4-b Completed (2026-03-05)
- Implemented real `sendCommand()` in `lib/services/device_command_service.dart`.
- Added schema validation for `action`, `target`, `deviceIp`, `value` (R-01..R-05).
- Validation failure returns `false` and sends no request.
- Valid requests use `HttpClient` POST to `http://<deviceIp>:8080/command`.
- Payload includes: `action`, `target`, `value`, `deviceIp`, `timestamp`.
- Timeout + try/catch added; non-2xx responses return failure.

## Session Update - Phase 4-c Completed (2026-03-05)
- Added `Gercek Komut Gonder` button in Device Details dialog next to dry-run action.
- Button calls `DeviceCommandService.sendCommand()` for selected device payload.
- Result feedback is shown with SnackBar:
- Success: `Komut basariyla gonderildi`
- Failure: `Komut gonderilemedi!`
- Existing `Test Komutu Hazirla` dry-run flow was preserved.

## Session Update - Graceful Shutdown / Clean Exit (2026-03-05)
- Top control bar'a ayri bir `Cikis` butonu eklendi (`Icons.exit_to_app`, kirmizi outlined stil).
- Buton, `DashboardState.gracefulShutdownAndExit()` metodunu cagiracak sekilde baglandi.
- Kapatma sirasinda polling timer hemen iptal ediliyor, tarama durumlari kapatiliyor ve yeni taramalar bloklaniyor.
- `DeviceCommandService` icindeki `HttpClient` baglantilari `close(force: true)` ile kapatilarak portlar serbest birakiliyor.
- Son adimda uygulama `exit(0)` ile temiz sekilde sonlandiriliyor.

## Session Update - Firmware Sources Added (2026-03-05)
- ESP8266 ve ESP32-C6 firmware kaynak kodlari ayni repository altina eklendi.
- Yeni klasor yolu: `docs/Arduino/HomeDash/...`
- Amac: donanim (firmware) ve dashboard yazilimini tek repoda birlikte versiyonlamak.
