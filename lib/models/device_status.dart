/// MADAM Projesi - Anlık Durum Modeli
/// Cihazın o anki değerlerini (online, röle durumu, sensör vb.) tutar.
/// Faz 3: JSON /status verisi esnek olarak rawData haritasında barındırılır.

class DeviceStatus {
  bool isOnline;
  Map<String, dynamic>? rawData;
  DateTime? lastSeen;

  DeviceStatus({
    this.isOnline = false,
    this.rawData,
    this.lastSeen,
  });

  /// Gelen JSON haritasından modeli güvenli şekilde (null-safe) günceller
  void updateFromJson(Map<String, dynamic> json) {
    isOnline = true;
    rawData = json;
    lastSeen = DateTime.now();
  }

  /// UI tablosu için JSON verilerinden kısa, okunabilir bir özet üretir
  String getSummary() {
    if (!isOnline) return 'Cihaz çevrimdışı';
    if (rawData == null || rawData!.isEmpty) return 'JSON boş / Veri yok';

    final List<String> parts = [];
    
    // Yaygın JSON alanlarını güvenli şekilde parse etme denemeleri
    if (rawData!.containsKey('relay')) {
      final val = rawData!['relay'];
      if (val is bool) {
        parts.add(val ? 'Röle: AÇIK' : 'Röle: KAPALI');
      } else {
        parts.add('Röle: $val');
      }
    }
    
    if (rawData!.containsKey('is_active')) {
      final val = rawData!['is_active'];
      if (val is bool) {
        parts.add(val ? 'Aktif' : 'Pasif');
      }
    }

    if (rawData!.containsKey('temperature')) {
      parts.add('Sıcaklık: ${rawData!['temperature']}');
    }

    if (rawData!.containsKey('humidity')) {
      parts.add('Nem: ${rawData!['humidity']}');
    }
    
    if (rawData!.containsKey('sensor')) {
      parts.add('Sensör: ${rawData!['sensor']}');
    }

    // Bilinen alan yoksa json'ın kendi özetini (veya anahtarlarını) göster
    if (parts.isEmpty) {
      return 'Bilinmeyen Veri (${rawData!.keys.take(3).join(', ')})';
    }

    return parts.join(' | ');
  }
}
