# WORK_TODO.md

Bu dosya projede yapılacak işleri, alınan kararları ve bekleyen görevleri listelemek için kullanılacaktır. Ağ sabitleri ve cihaz rolleri, mevcut kod mimarisinde korunmuş olup değiştirilemez yapıdadır.

## Tamamlanan İşler
- [x] Klasör ve alt klasör iskeletinin oluşturulması (`docs`, `lib/*`, `test`).
- [x] Temel Flutter UI sınıf iskeleti (`app.dart`, `dashboard_page.dart` vb.).
- [x] Veri modellerinin taslak oluşturulması (`device_info.dart`, `device_status.dart`, `ping_result.dart`).
- [x] **Ağ ve Cihaz Sabitleri:** SOT (Tek Doğruluk Kaynağı) referans alınarak `network_constants.dart` (192.168.55.0/24 subnet, Port:8080) ve `device_registry.dart` (Sensör rolleri, Master node IP) içindeki korunaklı bilgiler kodlandı.
- [x] `DashboardState` üzerinden `DeviceTable` veri bağlama placeholder işlemleri.

## Kısmen Tamamlanan İşler
- [ ] UI Kontrol Çubuğu (buton fonksiyonları henüz iş mantığına bağlanmadı).
- [ ] Ana Sayfa Log alanı (yalnızca UI olarak var, Event Logger entegrasyonu yok).

## Bekleyen Görevler (Öncelik Sırasıyla)
1. Flutter Proje Başlatması: `pubspec.yaml` oluşturularak `flutter create . --platforms windows` ile test edilebilir hale getirilmesi.
2. `lib/services/ping_service.dart`: Ağ sağlığı ve erişilebilirliği denetleyecek (TCP socket tabanlı) ping algoritmalarının asenkron yazılması ve `DashboardState` poling döngüsüne entegrasyonu. (Faz 2)
3. `lib/services/device_command_service.dart`: HTTP/JSON parse ve error handling süreçlerini bağlayacak GET/POST yapısının kodlanıp cihaza veri atılması. (Faz 3)

---

## Sonraki Oturum İçin Devam Promptu
*Aşağıdaki metni bir sonraki AI oturumunu başlatırken kopya/yapıştır yapabilirsiniz:*
```text
Bu sohbette HomeDash (MADAM) projesinin geliştirilmesine kaldığımız yerden devam edeceğiz. Önceki oturumda Flutter klasör iskeleti, UI placeholderları, DashboardState yapısı ve bağlam dosyasından alınan sabit donanım/ağ konfigürasyonları (192.168.55.x alt ağı, statik IP rolleri) kodlanmıştı. Hiçbir sabiti bozmadan, şimdi projeyi derlenebilir hale getirmek için Flutter pubspec.yaml dosyasını (Windows platformu) tanımlamanı, ardından Faz 2 adımı olan asenkron Ping Service mantığını kodlamanı istiyorum.
```

