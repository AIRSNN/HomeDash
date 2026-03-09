# MADAM - Tekrar Kullanılabilir Prompt Şablonları

Aşağıdaki şablonlar, GA içindeki ai ile çalışırken aynı bağlamı tekrar tekrar yazmamak için hazırlanmıştır.

---

## Şablon 1 - Proje Bağlamını Yükle
Sen HomeDash isimli, kod adı MADAM olan akıllı ev test projesinde çalışan yardımcı yazılım mühendisisin.
Sistem Windows 10 üzerinde çalışan Flutter/Dart dashboard ile, ESP8266 ve ESP32-C6 cihazlarından oluşur.
Ağ 192.168.55.0/24 yapısındadır.
Dashboard IP: 192.168.55.100
ESP statik aralığı: 192.168.55.20 - 192.168.55.29
API portu: 8080
İletişim JSON tabanlıdır.
Öncelik: çalışan, sade, modüler ve test edilebilir kod.
IP, port ve ağ mimarisini izinsiz değiştirme.
Bundan sonraki görevlerde bu bağlamı sabit kabul et.

---

## Şablon 2 - Flutter Projesi Başlat
Yukarıdaki MADAM bağlamını kullanarak Flutter/Dart için modüler bir başlangıç projesi oluştur.
İstediğim çıktı formatı:
1. Kısa mimari açıklama
2. Oluşturulacak dosya ağacı
3. Her dosyanın tam içeriği
4. Çalıştırma komutları
5. Test adımları
Ağ sabitlerini config dosyasına koy.
UI ile iş mantığını ayır.
Gereksiz paket ekleme.

---

## Şablon 3 - Ping Dashboard Geliştir
Mevcut MADAM Flutter projesini geliştir.
Amaç: 192.168.55.20 - 192.168.55.29 aralığındaki cihazları ping ile izleyen bir dashboard oluşturmak.
Her satırda şu alanlar olsun:
- cihaz adı
- IP
- RTT
- TTL
- success sayısı
- fail sayısı
- online/offline durum göstergesi
Non-blocking yenileme kullan.
Kodları dosya bazında tam ver.
Mevcut mimariyi bozma.

---

## Şablon 4 - JSON Cihaz API Katmanı
MADAM projesine cihazlarla haberleşmek için bir HTTP JSON servis katmanı ekle.
Aşağıdaki özellikleri uygula:
- temel GET durum sorgusu
- temel POST komut gönderimi
- timeout
- hata yönetimi
- parse edilen yanıt modeli
Çıktıyı mevcut dosyalara entegre olacak şekilde ver.
Sadece gerekli dosyaları değiştir.

---

## Şablon 5 - Refactor İsteği
Aşağıdaki kodları incele ve davranışı bozmadan refactor et.
Hedefler:
- daha okunabilir yapı
- gereksiz tekrarları azaltma
- sabitleri merkezileştirme
- hata yönetimini iyileştirme
- performans olarak daha verimli akış
Kurallar:
- UI çıktısı bozulmasın
- işlevsel davranış değişmesin
- tam dosya içeriklerini ver
- yapılan değişiklikleri maddeler halinde açıkla

---

## Şablon 6 - Hata Ayıklama
Aşağıdaki hata / log çıktısına göre yalnızca kök neden analizi yap.
Önce şu formatta cevap ver:
1. En olası neden
2. İkinci olası neden
3. Doğrulama adımları
4. Gerekli minimal kod düzeltmesi
Kanıtsız varsayım yapma.
Elindeki log ile desteklenmeyen sonuçları kesinmiş gibi yazma.

---

## Şablon 7 - ESP Uç Nokta Tasarımı
MADAM projesindeki ESP cihazlar için basit ve kararlı bir JSON API sözleşmesi tasarla.
Aşağıdaki uç noktaları öner:
- sağlık / hazır durumu
- sensör verisi
- röle kontrolü
- heartbeat
Çıktıda:
- endpoint listesi
- örnek request JSON
- örnek response JSON
- hata kodu önerileri
- Flutter tarafında parse notları olsun.
Aşırı karmaşık mimari önerme.

---

## Şablon 8 - Yeni Sohbet Açılışı
Bu yeni sohbette HomeDash (MADAM) akıllı ev test projesi üzerinde çalışacağız.
Temel sabitler:
- Windows 10 üzerinde Flutter/Dart dashboard
- ESP8266 + ESP32-C6 cihaz ağı
- 192.168.55.0/24 ağ yapısı
- Dashboard IP: 192.168.55.100
- ESP aralığı: 192.168.55.20 - 192.168.55.29
- Port: 8080
- JSON haberleşme
Hedef: adım adım, küçük ama çalışan modüller geliştirmek.
Önce mevcut görev için teknik plan çıkar, sonra kod ver.

