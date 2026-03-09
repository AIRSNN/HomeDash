# TECHNICAL_DOCS.md

## MADAM HomeDash Teknik Tasarim Notlari

Bu dokuman, `lib/state/dashboard_state.dart` icindeki iki temel yapinin teknik
aciklamasini sunar:

- Edge Trigger tabanli otomasyon karari (`OFF -> ON`)
- Provider tabanli durum yonetimi (ChangeNotifier modeli)

---

## 1. Edge Trigger (OFF -> ON) Mantigi

### 1.1 Problem Tanimi

Saha cihazlarinda ayni kosul uzun sure aktif kalabilir. Bu durumda her polling
dongusunde komut gondermek:

- ag trafigini artirir
- role cihazini gereksiz tetikler
- yan etkili tekrarli komutlara neden olur

Bu nedenle seviye-tabanli (level-trigger) yaklasim yerine gecis-tabanli
(edge-trigger) yaklasim kullanilir.

### 1.2 Durum Bellegi

`DashboardState` sinifi, sensorun bir onceki durumunu `_lastSensorState`
degiskeninde tutar.

- `currentState = "on"` veya `"off"` sensorun anlik degeridir
- `_lastSensorState` bir onceki taramanin sonucudur

### 1.3 Tetikleme Kosulu

Komut yalnizca su durumda uretilir:

- `currentState == "on"` ve `_lastSensorState == "off"`

Bu ifade, yalnizca `OFF -> ON` gecisini yakalar. Sensor uzun sure `ON`
kalirsa, tekrar komut uretilmez.

### 1.4 Yurutme Akisi

1. Polling dongusu tum cihazlardan durum toplar.
2. Sensor cihazinin (`192.168.55.20`) `relay_1` durumu okunur.
3. Edge trigger kosulu saglanirsa hedef cihaz (`192.168.55.29`) kontrol edilir.
4. Hedef online ise `sendCommand(...)` ile komut iletilir.
5. Sonuc loglanir ve `_lastSensorState` guncellenir.

### 1.5 Dayaniklilik

Bu model, degisime tepki veren bir otomasyon davranisi saglar:

- tekrarli komut spamini azaltir
- sistem loglarini anlamli hale getirir
- ag gecikmesi/ani dalgalanmalarda daha ongorulebilir davranir

---

## 2. Provider Tabanli State Yonetimi

### 2.1 Mimari Cekirdek

`DashboardState`, `ChangeNotifier` sinifindan turetilmistir. Bu tasarim:

- tek bir merkezden cihaz durumlarini yonetir
- UI katmanina reaktif bildirim (`notifyListeners`) gonderir
- servis katmanini (ping, HTTP komut, status okuma) UI'dan ayirir

### 2.2 Veri Alanlari

`DashboardState` icinde temel veri yapilari:

- `devices`: kayitli cihaz listesi
- `deviceStatuses`: IP -> DeviceStatus haritasi
- `pingLatencies`: IP -> RTT haritasi
- `logs`: isletim olay kayitlari
- `isPolling`, `isScanning`, `_isShuttingDown`: dongu ve yasam-dongusu bayraklari

### 2.3 Reaktif Guncelleme

Asagidaki olaylar sonunda `notifyListeners()` cagrilir:

- polling baslatma/durdurma
- tarama baslangic/bitis
- log ekleme
- durum metni guncelleme

Bu sayede widget agaci, state degisikliklerine otomatik senkronize olur.

### 2.4 Servis Entegrasyonu

`DashboardState`, iki servis ile koordinasyon saglar:

- `PingService`: cihazin erisilebilirligini test eder
- `DeviceCommandService`: `/status` ve `/command` HTTP islemlerini yonetir

Polling dongusunda her cihaz icin:

1. ping sonucu alinur
2. erisilebilen cihazlarda `/status` okunur
3. tum sonuclar tamamlandiktan sonra otomasyon kurali degerlendirilir

Bu siralama, karar mekanizmasinin guncel ve tutarli veri ile calismasini saglar.

### 2.5 Yasam Dongusu ve Kapanis

`gracefulShutdownAndExit()` metodu:

- timer/polling sureclerini durdurur
- acik HTTP baglantilarini kapatir
- son bir UI bildirimi yapip uygulamayi sonlandirir

Bu adimlar kaynak sizintilarini ve yarim kalan baglantilari azaltir.

---

## 3. Mühendislik Cikarimi

Bu mimari, sahada calisan IoT sistemleri icin uc temel fayda uretir:

- Gecis bazli kontrol ile deterministik otomasyon
- Provider modeli ile test edilebilir ve moduler durum yonetimi
- Servis/UI ayrimi ile genisletilebilir kod tabani

MADAM HomeDash bu yapiyla hem operasyonel izleme hem de kontrollu komut iletimi
icin dengeli bir temel sunar.
