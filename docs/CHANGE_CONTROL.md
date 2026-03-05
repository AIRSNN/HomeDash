# CHANGE_CONTROL.md

Bu dosya projede yapılan mimari değişiklikleri, yeni eklenen önemli özellikleri ve olası kırılma (breaking change) noktalarını takip etmek için kullanılacaktır.

## Değişiklikler
- [x] Flutter Windows build const UI düzeltmesi (Hatasız derleme)
- [x] Faz 2: Asenkron TCP 8080 Ping Okumaları
- [x] Faz 3: JSON /status HTTP Okuma
- [x] DeviceTable UI JSON özeti (`rawData` fallback sistemi)
- [x] GitHub (main dalı) yedekleme optimizasyonu
- [x] Faz 4-a: Salt-okuma cihaz ayrıntıları dialogu (`DeviceTable` satır eylemi, `_showDeviceDetailsDialog`)
- [x] Faz 4-a: Dry-run komut önizleme — `generateDryRunPayload()` + "Test Komutu Hazırla" butonu (`device_table.dart`, `device_command_service.dart`)
- [x] `/command` JSON şema SOT belgesi oluşturuldu (`docs/COMMAND_SCHEMA_SOT.md`) — 5 alan, 6 doğrulama kuralı, 3 örnek payload
- [ ] **Faz 4-b BEKLEMEDE:** Şema-doğrulamalı gerçek `sendCommand()` HTTP POST — yalnızca `device_command_service.dart`
