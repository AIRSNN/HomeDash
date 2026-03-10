# CHANGE_CONTROL.md

Bu dosya projede yapilan mimari degisiklikleri, yeni eklenen onemli ozellikleri ve olasi kirilma (breaking change) noktalarini takip etmek icin kullanilacaktir.

## Degisiklikler
- [x] Flutter Windows build const UI duzeltmesi (Hatasiz derleme)
- [x] Faz 2: Asenkron TCP 8080 Ping Okumalari
- [x] Faz 3: JSON /status HTTP Okuma
- [x] DeviceTable UI JSON ozeti (`rawData` fallback sistemi)
- [x] GitHub (main dali) yedekleme optimizasyonu
- [x] UI layout fix: `dashboard_page.dart` icinde sabit header + scrollable body + sabit footer mimarisi ile RenderFlex overflow kalici olarak giderildi
- [x] Waveform izolasyonu: Dalga formu grafigi yalnizca USAGE sekmesinde gosterilecek sekilde sinirlandi
- [x] Faz 4-a: Salt-okuma cihaz ayrintilari dialogu (`DeviceTable` satir eylemi, `_showDeviceDetailsDialog`)
- [x] Faz 4-a: Dry-run komut onizleme - `generateDryRunPayload()` + "Test Komutu Hazirla" butonu (`device_table.dart`, `device_command_service.dart`)
- [x] `/command` JSON sema SOT belgesi olusturuldu (`docs/COMMAND_SCHEMA_SOT.md`) - 5 alan, 6 dogrulama kurali, 3 ornek payload
- [x] Faz 4-b TAMAMLANDI: Sema-dogrulamali gercek `sendCommand()` HTTP POST islemi
