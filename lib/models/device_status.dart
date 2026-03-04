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
}
