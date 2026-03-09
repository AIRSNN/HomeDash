# MADAM - Donanım ve Ağ Tek Doğruluk Kaynağı

## 1. Amaç
Bu dosya, proje içindeki tüm fiziksel cihaz, IP planı ve haberleşme sabitleri için **tek referans** kabul edilir.
GA veya başka herhangi bir yapay zeka aracı kod üretirken bu dosyadaki ağ bilgilerini izinsiz değiştirmemelidir.

## 2. Ağ Altyapısı
- SSID: `llama_iot`
- Şifre: `testteam`
- Güvenlik: `WPA2-PSK (AES)`
- Gateway: `192.168.55.1`
- Alt ağ maskesi: `255.255.255.0`

## 3. IP Stratejisi
- Ağ tipi: `/24`
- Statik ESP havuzu: `192.168.55.20 - 192.168.55.29`
- DHCP havuzu: `192.168.55.100 - 192.168.55.150`
- Sunucu IP: `192.168.55.100`

### Kural
- ESP cihazlara **yalnızca** `192.168.55.20 - 192.168.55.29` aralığından statik IP atanır.
- Dashboard sunucusu **yalnızca** `192.168.55.100` IP'sini kullanır.
- Bu aralıklara taşmadan geliştirme yapılır.

## 4. Cihaz Envanteri
| Cihaz ID | Donanım | Statik IP | Rol |
|---|---|---|---|
| Cihaz 1 | ESP8266 | 192.168.55.20 | Sensör / Aktüatör Node |
| Cihaz 2 | ESP8266 | 192.168.55.21 | Sensör / Aktüatör Node |
| Cihaz 3 | ESP8266 | 192.168.55.22 | Sensör / Aktüatör Node |
| Cihaz 4 | ESP8266 | 192.168.55.23 | Sensör / Aktüatör Node |
| Cihaz 5 | ESP8266 | 192.168.55.24 | Sensör / Aktüatör Node |
| Cihaz 6 | ESP8266 | 192.168.55.25 | Sensör / Aktüatör Node |
| Cihaz 7 | ESP32-C6 | 192.168.55.26 | Sensör / Aktüatör Node |
| Cihaz 8 | ESP32-C6 | 192.168.55.27 | Sensör / Aktüatör Node |
| Cihaz 9 | ESP32-C6 | 192.168.55.28 | Sensör / Aktüatör Node |
| Cihaz 10 | ESP32-C6 | 192.168.55.29 | Ana Kontrolör (Master Node) |
| Server | Win10 PC | 192.168.55.100 | Dashboard / Merkezi Yönetim |

## 5. Haberleşme Sabitleri
- Hedef port: `8080`
- Veri tipi: `application/json`
- İletişim modeli: Asenkron JSON veri akışı
- Heartbeat aralığı: `60 saniye`
- Heartbeat kurgusu: **Non-blocking**

## 6. Seri Log Anahtarları
Aygıt yazılımı ve yardımcı araçlar, mümkün olduğunda aşağıdaki log anahtarlarını korumalıdır:
- `@READY`
- `@PONG`
- `@ERR_WIFI_FAIL`
- `@ERR_HTTP_FAIL`

## 7. Kod Üretim Kısıtları
Yapay zeka ile kod üretirken aşağıdaki sabitler değiştirilemez:
- Wi-Fi SSID ve şifre (test ortamı için)
- Gateway
- Alt ağ maskesi
- Statik IP aralığı
- Dashboard IP
- Port 8080
- JSON tabanlı haberleşme tercihi
- 60 saniyelik heartbeat mantığı

## 8. Donanım Notları
- ESP8266 düğümleri hafif sensör / aktüatör görevleri için düşünülür.
- ESP32-C6 düğümleri daha geniş kontrol, röle ve gelecekteki merkezileşmiş mantık için ayrılmıştır.
- `192.168.55.29` IP'li ESP32-C6, proje içinde ana kontrolör olarak özel öneme sahiptir.

## 9. Üretim Öncesi Uyarı
Bu dosyadaki SSID ve parola test ortamı içindir. Gerçek saha veya kalıcı kullanım öncesinde ağ bilgileri yeniden düzenlenmeli ve güvenlik seviyesi yükseltilmelidir.
