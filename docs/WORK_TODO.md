# WORK_TODO.md

Bu dosya projede yapılacak işleri, alınan kararları ve bekleyen görevleri listelemek için kullanılacaktır. Ağ sabitleri ve cihaz rolleri, mevcut kod mimarisinde korunmuş olup değiştirilemez yapıdadır.

## Tamamlanan İşler
- [x] Klasör ve alt klasör iskeletinin oluşturulması (`docs`, `lib/*`, `test`).
- [x] Temel Flutter UI sınıf iskeleti (`app.dart`, `dashboard_page.dart` vb.).
- [x] SOT (Tek Doğruluk Kaynağı) referans alınarak `network_constants.dart` ve `device_registry.dart` sabitleri kodlandı.
- [x] Flutter Proje Başlatması: `pubspec.yaml` ve Windows build ilklendirmesi yapıldı, const derleme hataları tamamen temizlendi.
- [x] `lib/services/ping_service.dart`: Ağ sağlığı asenkron TCP socket ping algoritması kodlandı. (Faz 2)
- [x] `lib/services/device_command_service.dart`: HTTP `GET /status` yapısıyla JSON okuma ve UI Tablosuna ('JSON Özeti') aktarma işlemi yapıldı. (Faz 3)
- [x] Projenin Git deposu oluşturulup GitHub'a (HomeDash repocusuna) yedeklendi.

## Bekleyen Görevler (Öncelik Sırasıyla)

> ⚠️ **Kural:** Gerçek HTTP POST (`sendCommand`) yalnızca `/command` JSON şeması onaylandıktan sonra eklenebilir.

1. **`/command` JSON şemasını tanımla:** Cihaza gönderilecek komutun `action`, `target`, `value`, `deviceIp` alanlarını ve olası değer kümelerini bir MADAM SOT dokümanıyla belgele. Kodlama yapılmaz; yalnızca şema netleştirilir.
2. **Şema onayından sonra:** Gerçek `sendCommand` HTTP POST bağlantısını `device_command_service.dart` içerisine ekle. (Faz 4-b)
3. **İsteğe bağlı:** `flutter analyze` `info` uyarılarını gidermek için tüm `/// MADAM Projesi - ...` başlık yorumlarından sonra `library <isim>;` direktifi ekle.

## Tamamlanan İşler
- [x] Klasör ve alt klasör iskeletinin oluşturulması (`docs`, `lib/*`, `test`).
- [x] Temel Flutter UI sınıf iskeleti (`app.dart`, `dashboard_page.dart` vb.).
- [x] SOT referans alınarak `network_constants.dart` ve `device_registry.dart` sabitleri kodlandı.
- [x] Flutter Proje Başlatması: `pubspec.yaml` ve Windows build ilklendirmesi yapıldı, const derleme hataları temizlendi.
- [x] `lib/services/ping_service.dart`: Asenkron TCP socket ping algoritması kodlandı. (Faz 2)
- [x] `lib/services/device_command_service.dart`: HTTP `GET /status` ile JSON okuma ve UI tablosuna aktarma yapıldı. (Faz 3)
- [x] Projenin Git deposu oluşturulup GitHub'a yedeklendi.
- [x] Salt-okuma cihaz ayrıntıları dialogu eklendi (`DeviceTable` satır eylemi). (Faz 4-a)
- [x] Dry-run komut önizleme: "Test Komutu Hazırla" butonu ve payload gösterimi tamamlandı. (Faz 4-a)
- [x] `device_table.dart` eksik `DeviceCommandService` importu giderildi; Windows build başarılı.

