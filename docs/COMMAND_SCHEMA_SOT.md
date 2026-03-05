# COMMAND_SCHEMA_SOT.md
# MADAM — `/command` Endpoint JSON Şema Kaynağı (Source of Truth)

> ⚠️ **GÜVENLİK KURALI:** Gerçek HTTP POST isteği yalnızca bu belgedeki şema onaylandıktan sonra kodlanabilir.
> Bu belge onaylanmadan hiçbir `sendCommand()` çağrısı aktif edilmemelidir.
> Bilinmeyen veya tanımsız değerler içeren komutlar **reddedilmeli veya yalnızca dry-run olarak işaretlenmelidir.**

---

## 1. Endpoint Tanımı

| Özellik      | Değer                          |
|--------------|-------------------------------|
| Method       | `POST`                        |
| Path         | `/command`                    |
| Port         | `8080` (NetworkConstants.apiPort) |
| Content-Type | `application/json`            |
| Auth         | Yok (iç ağ, 192.168.55.0/24) |

---

## 2. Payload Alanları

### `action` — String, **Zorunlu**

Cihaza gönderilecek komut türü.

| Değer    | Anlamı                              | Geçerli Hedefler              |
|----------|-------------------------------------|-------------------------------|
| `toggle` | Röle veya switch durumunu değiştir  | `relay_1`, `relay_2`          |
| `open`   | Röleyi/çıkışı aç (ON)              | `relay_1`, `relay_2`          |
| `close`  | Röleyi/çıkışı kapat (OFF)          | `relay_1`, `relay_2`          |
| `read`   | Sensör verisini oku                 | `sensor_data`                 |
| `ping`   | Sistem sağlık kontrolü              | `system`                      |

> **Doğrulama:** Yukarıdaki liste dışındaki değerler geçersizdir. Bilinmeyen `action` değerleri komut reddedilmeli veya dry-run'a düşürülmelidir.

---

### `target` — String, **Zorunlu**

Komutun hedeflediği cihaz bileşeni.

| Değer         | Anlamı                                    | Geçerli Aksiyonlar            |
|---------------|-------------------------------------------|-------------------------------|
| `relay_1`     | Birincil röle çıkışı                      | `toggle`, `open`, `close`     |
| `relay_2`     | İkincil röle çıkışı (varsa)              | `toggle`, `open`, `close`     |
| `sensor_data` | Sensör okuma verisi (temp, humidity vb.) | `read`                        |
| `system`      | Genel sistem / ping hedefi               | `ping`                        |

> **Doğrulama:** `action`–`target` kombinasyonu yukarıdaki çapraz tabloya uygun olmalıdır. Uyumsuz eşleşmeler reddedilmelidir.

---

### `value` — Any, **Koşullu**

Komutla birlikte gönderilecek parametre değeri.

| `action`         | Beklenen `value` tipi | Örnek       | Zorunlu mu? |
|------------------|-----------------------|-------------|-------------|
| `toggle`         | `bool`                | `true`      | Hayır       |
| `open`           | `null` veya `bool`    | `null`      | Hayır       |
| `close`          | `null` veya `bool`    | `null`      | Hayır       |
| `read`           | `String`              | `"all"`     | Evet        |
| `ping`           | `null`                | `null`      | Hayır       |

> **Doğrulama:** `read` için `value` zorunludur ve `"all"` veya belirli bir alan adı olmalıdır.

---

### `deviceIp` — String, **Zorunlu**

Komut gönderilecek cihazın IP adresi.

- Format: IPv4 dotted-decimal — `"192.168.55.XX"`
- Geçerli aralık: `192.168.55.20` – `192.168.55.29` (device_registry.dart'taki kayıtlı cihazlar)
- **Doğrulama:** Kayıtlı cihaz listesinde bulunmayan IP adresleri reddedilmelidir.

---

### `timestamp` — String (ISO 8601), **İsteğe Bağlı**

Komutun oluşturulduğu zaman bilgisi. Loglama ve debug amacıyla eklenir.

- Format: `DateTime.now().toIso8601String()` → `"2026-03-05T11:14:22.000"`
- Gerçek komut iletiminde sunucu tarafından yoksayılabilir, sadece istemci kaydı içindir.

---

## 3. Cihaz Rolüne Göre Güvenli Payload Örnekleri

### Röle Tipi Cihaz (role içinde "RELAY" geçiyorsa)

```json
{
  "action": "toggle",
  "target": "relay_1",
  "value": true,
  "deviceIp": "192.168.55.20",
  "timestamp": "2026-03-05T11:14:22.000"
}
```

### Sensör Tipi Cihaz (role içinde "SENSOR" geçiyorsa)

```json
{
  "action": "read",
  "target": "sensor_data",
  "value": "all",
  "deviceIp": "192.168.55.22",
  "timestamp": "2026-03-05T11:14:22.000"
}
```

### Genel / Bilinmeyen Rol (fallback)

```json
{
  "action": "ping",
  "target": "system",
  "value": null,
  "deviceIp": "192.168.55.29",
  "timestamp": "2026-03-05T11:14:22.000"
}
```

---

## 4. Doğrulama Kuralları Özeti

| Kural | Açıklama |
|-------|----------|
| R-01  | `action` alanı zorunludur ve izin verilen değerler listesinden biri olmalıdır. |
| R-02  | `target` alanı zorunludur ve `action` ile uyumlu olmalıdır. |
| R-03  | `deviceIp` alanı zorunludur ve kayıtlı cihaz listesinde bulunmalıdır. |
| R-04  | `action = "read"` için `value` boş bırakılamaz. |
| R-05  | Bilinmeyen `action` veya `target` değerleri gerçek POST'ta reddedilmeli; yalnızca dry-run modunda işaretli olarak loglanabilir. |
| R-06  | `timestamp` isteğe bağlıdır; eksikse istemci ekler, sunucu yoksayabilir. |

---

## 5. Güvenlik ve Onay Kuralları

> [!CAUTION]
> **Bu belge onaylanmadan `sendCommand()` HTTP POST implementasyonu başlatılamaz.**

- Dry-run akışı (`generateDryRunPayload`) bu şemaya uygun payload üretmektedir — bu onaylanmış davranıştır.
- Gerçek POST eklenmeden önce bu belgenin kullanıcı tarafından onaylanması zorunludur.
- Onay sonrası kodlama: yalnızca `device_command_service.dart` içindeki `sendCommand()` placeholder'ı aktif edilecektir. Başka dosya değiştirilmeyecektir.

---

## 6. Sürüm

| Tarih       | Durum                  | Açıklama                        |
|-------------|------------------------|---------------------------------|
| 2026-03-05  | TASLAK — Onay Bekliyor | İlk şema tanımı oluşturuldu.    |
