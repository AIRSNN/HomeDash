# MADAM HomeDash

MADAM HomeDash, yerel agdaki ESP tabanli cihazlari izlemek, komut gondermek ve
M2M (Machine-to-Machine) otomasyon akislari calistirmak icin gelistirilmis bir
Flutter masaustu kontrol panelidir.

## Proje Amaci

- Cihazlarin anlik online/offline durumunu takip etmek
- `GET /status` ile cihaz telemetrilerini toplamak
- `POST /command` ile role/switch komutlari gondermek
- Edge-trigger tabanli M2M otomasyon ile manuel mudahaleyi azaltmak

## Ag Semasi

- Yerel ag: `192.168.55.0/24`
- Sensor/tetik kaynagi: `192.168.55.20`
- Ana kontrol/hedef role: `192.168.55.29`
- API portu: `8080`
- Endpointler:
  - Durum okuma: `GET /status`
  - Komut gonderme: `POST /command`

## M2M Otomasyon Mantigi

`DashboardState` icindeki otomasyon, sensor cihazinin role durumundaki
`OFF -> ON` gecisini edge-trigger olarak algilar.

1. Sistem 10 saniye aralikla tum cihazlari tarar.
2. `192.168.55.20` cihazindan gelen durumdaki `relay_1` alani okunur.
3. Son durum `off`, mevcut durum `on` ise tetik olusur.
4. Hedef cihaz `192.168.55.29` online ise otomasyon komutu gonderilir.
5. Komut sonucu loglanir; basarisiz durumda hata/uyari kaydi dusulur.

Bu yaklasim, surekli tekrar eden komutlari engeller ve yalnizca gecis aninda
aksiyon alir.

## Kurulum

### Gereksinimler

- Flutter SDK (stable)
- Windows icin Visual Studio C++ Build Tools
- Ayni yerel aga bagli ESP cihazlari

### Adimlar

1. Depoyu klonlayin:
   `git clone <repo-url>`
2. Proje dizinine girin:
   `cd HomeDash`
3. Bagimliliklari yukleyin:
   `flutter pub get`
4. Analiz calistirin:
   `flutter analyze`
5. Uygulamayi baslatin:
   `flutter run -d windows`

## Proje Yapisi (Ozet)

- `lib/state/dashboard_state.dart`: polling, otomasyon ve uygulama durumu
- `lib/services/ping_service.dart`: cihaz erisilebilirlik kontrolu
- `lib/services/device_command_service.dart`: HTTP status/command iletisim katmani
- `lib/widgets/device_table.dart`: cihaz tablosu ve eylem butonlari
- `docs/`: SOT ve teknik belgeler

## Notlar

- Uygulama ic ag kullanimina gore tasarlanmistir.
- Komut semasi icin kaynak belge: `docs/COMMAND_SCHEMA_SOT.md`
- Uretim ortami oncesi timeout, loglama ve fail-safe davranislari test edilmelidir.
