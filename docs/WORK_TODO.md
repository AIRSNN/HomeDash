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
1. **Salt-okuma Ayrıntılar dialogu ekle:** Tablodaki 'Eylemler' dişlisine basıldığında `rawData` JSON verisini temiz gösteren bir UI modal eklenmesi.
2. Komut şeması standardı (MADAM kurallarına göre JSON formatı çıkartılması).
3. Dry-run komut testi (UI'dan tetiklenen, konsola log basan ama henüz GET/POST yapmayan aksiyonlar).
4. Gerçek `sendCommand` HTTP POST bağlantılarının `device_command_service.dart` içerisine uygulanması. (Faz 4)

