# SESSION_LOG.md

Bu dosya oturum sırasındaki önemli aşamaları, kararları ve tamamlanan adımları kaydetmek için kullanılacaktır.

## İkinci Oturum Kayıtları (Flutter İskelet Kurulumu)
- **Klasör Yapısı:** Proje genel gereksinimlerine göre `/lib` alt klasörleri (`config`, `models`, `services`, `pages`, `widgets`, `state`) ve `/docs`, `/test` gibi ana dizin iskeleti kuruldu.
- **Flutter Temel Dosyaları:** `main.dart` ve `app.dart` giriş sınıfları "HomeDash (MADAM)" olarak ilklendirildi ancak derlenebilir placeholder (iş mantığı olmayan iskelet) halinde bırakıldı.
- **Güvenli Ağ Sabitleri:** `01_MADAM_HARDWARE_AND_NETWORK_SOT.md` bağlam dosyasına sadık kalınarak `lib/config/network_constants.dart` içerisine IP (`192.168.55.100`), SSID (`llama_iot`), subnet ve mask (`255.255.255.0`) gibi veriler eklenerek korundu.
- **Donanım Kaydı:** `lib/config/device_registry.dart` dosyası güncellenerek IP `192.168.55.20-28` sensör, `.29` ise açık yorumla "Ana Kontrol Düğümü / Primary Controller" rolüne atandı.
- **UI İskeleti ve State:** `DashboardPage` stateful yapıya geçirilerek `DashboardState` ile entegre edildi, cihaz listesi `DeviceTable` aracılığıyla görüntülendi. Ping değerleri ve log satırları için yer tutucu (placeholder) nesneler konuldu.
- **Durum:** Derleme öncesi mekanik import kontrolleri yapıldı, yapısal uyumsuzluk bulunmadı. İş mantığı kodlanmadı.

