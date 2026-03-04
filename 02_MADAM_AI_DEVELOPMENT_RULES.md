# MADAM - GA ve ai için Geliştirme Kuralları

## 1. Rol Tanımı
Bu proje, Flutter/Dart ile geliştirilen bir Windows 10 dashboard ve ESP tabanlı cihaz ağından oluşur.
GA içindeki ai, bu projede bir "kod üreten yardımcı mühendis" gibi davranmalıdır; mimari sabitleri bozarak rastgele kod yazmamalıdır.

## 2. Sabit Varsayımlar
Kod üretirken aşağıdaki sabitleri koru:
- Dashboard platformu: **Windows 10**
- Uygulama çatısı: **Flutter / Dart**
- Ağ: **192.168.55.0/24**
- Dashboard IP: **192.168.55.100**
- ESP statik IP aralığı: **192.168.55.20 - 192.168.55.29**
- API portu: **8080**
- Veri modeli: **JSON**

## 3. Kod Yazım İlkeleri
- Kod modüler olsun.
- UI katmanı ile iş mantığı ayrı olsun.
- Cihaz erişimi için servis katmanı kullan.
- Sabitler `config` veya `constants` dosyasında toplansın.
- Magic number kullanılmasın.
- Hata yönetimi açık ve izlenebilir olsun.
- Sessiz başarısızlık yerine kontrollü fallback kullan.

## 4. Beklenen Dosya Ayrımı
AI kod üretirken mümkün olduğunda aşağıdaki yapıyı korusun:
- `lib/main.dart` -> giriş noktası
- `lib/app/` -> uygulama kabuğu, tema, routing
- `lib/config/` -> ağ sabitleri, cihaz aralıkları, uygulama ayarları
- `lib/models/` -> cihaz modeli, durum modeli, API model sınıfları
- `lib/services/` -> ping, HTTP, cihaz haberleşme servisleri
- `lib/controllers/` veya `lib/state/` -> state yönetimi
- `lib/screens/` -> sayfalar
- `lib/widgets/` -> tekrar kullanılabilir UI bileşenleri

## 5. Davranış Kuralları
AI aşağıdakileri kendi kendine yapmamalıdır:
- IP aralığını değiştirmek
- farklı port seçmek
- MQTT, WebSocket, Firebase, Supabase gibi yeni bağımlılıkları habersiz eklemek
- cihaz ID mantığını bozmak
- gereksiz paket bağımlılığı yüklemek
- sadece görüntü güzel olsun diye mimariyi şişirmek

## 6. Cevap Formatı
AI'dan istenecek çıktı tercihen şu düzende olmalıdır:
1. Kısa amaç özeti
2. Değişen dosya listesi
3. Her dosya için tam içerik
4. Gerekirse kurulum komutu
5. Test adımları
6. Risk veya dikkat notları

## 7. Kod Kalitesi Kuralları
- Null güvenliği korunmalı.
- Asenkron işlemlerde `async/await` doğru kullanılmalı.
- Timer ve polling mantığı arayüzü kilitlememeli.
- Kod ilk sürümde bile okunabilir olmalı.
- "Sonra düzeltiriz" diye dağınık iskelet bırakılmamalı.

## 8. Gerçeklik Kontrolü
AI önerisi aşağıdakilerden birini ihlal ediyorsa reddedilmelidir:
- mevcut donanımla fiziksel olarak uyumsuz olması
- ağ planını bozması
- Windows 10 Flutter akışını gereksiz zorlaştırması
- test yerine üretim seviyesi karmaşıklık yüklemesi

## 9. Tercih Edilen Çalışma Tarzı
Her görev küçük parçalara ayrılmalı:
- önce çalışan minimum sürüm
- sonra doğrulama
- sonra iyileştirme
- sonra refactor

Bu yaklaşım, gösterişli ama kırılgan kod üretimini engeller.
