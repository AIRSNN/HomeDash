# MADAM - Faz Bazlı Geliştirme Yol Haritası

## Faz 0 - Temel Sabitleri Dondurma
Amaç: Proje boyunca değişmeyecek sabitleri netleştirmek.
- Donanım ve ağ haritasını sabitle
- IP ve rol planını kesinleştir
- Dosya isimlendirme standardını belirle
- AI için bağlam dosyalarını hazırla

**Çıkış kriteri:** Proje, yeni bir sohbette tek seferde doğru anlatılabiliyor olmalı.

## Faz 1 - Flutter Temel Uygulama İskeleti
Amaç: Çalışan temel dashboard kabuğunu kurmak.
- Flutter proje iskeleti
- tema ve ana pencere yapısı
- cihaz listesi ekranı
- durum satırı ve log alanı
- ayarlar / config bölümü

**Çıkış kriteri:** Uygulama açılıyor, cihaz listesi örnek veriyle render ediliyor.

## Faz 2 - Ağ Sağlığı ve Ping İzleme
Amaç: Cihaz erişilebilirliğini izlemek.
- IP aralığından cihaz listesi üret
- ping servis katmanı oluştur
- RTT, TTL, success, fail sayaçları ekle
- online / offline durum göstergesi oluştur
- non-blocking yenileme döngüsü yaz

**Çıkış kriteri:** Dashboard canlı ağ durumunu düzgün gösteriyor.

## Faz 3 - JSON API Haberleşmesi
Amaç: Ping ötesine geçip cihazlarla anlamlı veri alışverişi yapmak.
- HTTP istemci katmanı
- `GET /status` benzeri durum uç noktası
- `POST /command` benzeri komut uç noktası
- timeout ve retry davranışı
- JSON parse / validate mantığı

**Çıkış kriteri:** En az bir cihazdan durum okunuyor ve en az bir komut gönderiliyor.

## Faz 4 - Cihaz Rolleri ve Kontrol Katmanı
Amaç: Donanım işlevlerini yazılıma düzgün bağlamak.
- ESP8266 için PIR / anahtar mantığı
- ESP32-C6 için röle kontrol mantığı
- cihaz bazlı yetenek modeli
- her cihaz için supported actions yapısı

**Çıkış kriteri:** Dashboard, her cihazın rolüne uygun kontroller gösteriyor.

## Faz 5 - Otomasyon ve Kural Motoru
Amaç: Basit akıllı davranışlar eklemek.
- tetikleyici -> koşul -> aksiyon yapısı
- örnek: PIR algılandıysa röle tetikle
- zaman tabanlı görevler
- manuel override

**Çıkış kriteri:** En az bir temel otomasyon senaryosu çalışıyor.

## Faz 6 - Günlükleme ve Hata Tanılama
Amaç: Arıza ayıklamayı kolaylaştırmak.
- olay günlüğü
- hata kodu eşleştirme
- seri log anahtarlarını UI'ya taşıma
- cihaz bazlı son hata / son cevap kayıtları

**Çıkış kriteri:** Sorun olduğunda "neden" sorusuna UI içinden yaklaşılabiliyor.

## Faz 7 - Paketleme ve Saha Testi
Amaç: Kullanıma hazır test paketi oluşturmak.
- Windows build alma
- yapılandırma dosyalarını dışarı taşıma
- test senaryoları listesi hazırlama
- gerçek cihazlarla tekrar test

**Çıkış kriteri:** Tek makinede kurulup tekrar çalıştırılabilen test sürümü oluşmuş olmalı.

## Not
Bu proje için doğru yaklaşım, faz atlamadan ilerlemektir. Faz 2 sağlam değilse Faz 5 sadece cilalı kaos üretir.
