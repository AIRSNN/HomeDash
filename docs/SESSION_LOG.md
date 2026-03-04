# SESSION_LOG.md

Bu dosya oturum sırasındaki önemli aşamaları, kararları ve tamamlanan adımları kaydetmek için kullanılacaktır.

## İkinci Oturum Kayıtları (Flutter İskelet Kurulumu)
- **Klasör Yapısı:** Proje genel gereksinimlerine göre `/lib` alt klasörleri (`config`, `models`, `services`, `pages`, `widgets`, `state`) ve `/docs`, `/test` gibi ana dizin iskeleti kuruldu.
- **Flutter Temel Dosyaları:** `main.dart` ve `app.dart` giriş sınıfları "HomeDash (MADAM)" olarak ilklendirildi ancak derlenebilir placeholder (iş mantığı olmayan iskelet) halinde bırakıldı.
- **Güvenli Ağ Sabitleri:** `01_MADAM_HARDWARE_AND_NETWORK_SOT.md` bağlam dosyasına sadık kalınarak `lib/config/network_constants.dart` içerisine IP (`192.168.55.100`), SSID (`llama_iot`), subnet ve mask (`255.255.255.0`) gibi veriler eklenerek korundu.
- **Donanım Kaydı:** `lib/config/device_registry.dart` dosyası güncellenerek IP `192.168.55.20-28` sensör, `.29` ise açık yorumla "Ana Kontrol Düğümü / Primary Controller" rolüne atandı.
- **UI İskeleti ve State:** `DashboardPage` stateful yapıya geçirilerek `DashboardState` ile entegre edildi, cihaz listesi `DeviceTable` aracılığıyla görüntülendi. Ping değerleri ve log satırları için yer tutucu (placeholder) nesneler konuldu.
## Bugünkü Oturum Kayıtları (Flutter Build, TCP Ping ve JSON Okuma)
- **Güvenli Windows Build:** `homedash` projesi `flutter create` ile Windows altyapısına kavuşturuldu ve `pubspec.yaml` hazırlandı. Widget ağacındaki `const` kaynaklı runtime çökmeleri giderilerek `%100` hatasız derleme sağlandı.
- **Asenkron Ağ Tarama (Faz 2):** ICMP yerine Dart `dart:io` `Socket` kütüphanesi kullanılarak eşzamanlı (non-blocking) TCP 8080 port yoklaması (`ping_service.dart`) kodlandı ve `DashboardState` timer'ı ile bağlandı.
- **HTTP JSON Durum Okuma (Faz 3):** `device_command_service.dart` üzerinden `GET /status` endpointine istek atan yapı eklendi. Çökmeyi engelleyen null-safe `DeviceStatus` fallback sistemi geliştirildi.
- **UI Entegrasyonu:** `DeviceTable` içerisine "Durum Verisi / JSON" sütunu eklendi. Gelen dinamik JSON verisi (relay, is_active, temperature vb.) parse edilerek kısa özet olarak arayüze bastırıldı. Timer aktifleştikçe UI yenilenmesi sağlandı.

**Henüz Yapılmayanlar (Sonraki Adımlar):**
- Ayrıntılar dialogu (cihaz satırı sonundaki ayarlar butonu) uygulanmadı.
- Cihazlara komut gönderme (`sendCommand`) POST işlemi uygulanmadı.
