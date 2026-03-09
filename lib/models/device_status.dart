/// MADAM Projesi - Cihaz Durum Modeli (v2 - Sensör ve Çoklu Röle Destekli)
class DeviceStatus {
  bool isOnline;
  Map<String, dynamic>? rawData;

  DeviceStatus({required this.isOnline, this.rawData});

  // İstenilen rölenin aktif olup olmadığını kontrol eder
  bool isRelayActive(String relayId) {
    if (rawData == null || !rawData!.containsKey('relays')) return false;
    return rawData!['relays'][relayId] == 'on';
  }

  // --- YENİ SENSÖR VERİLERİ ---

  String get motionStatus {
    if (rawData == null || !rawData!.containsKey('sensors')) return 'clear';
    return rawData!['sensors']['motion'] ?? 'clear';
  }

  double get temperature {
    if (rawData == null || !rawData!.containsKey('sensors')) return 0.0;
    return (rawData!['sensors']['temperature'] ?? 0.0).toDouble();
  }

  double get humidity {
    if (rawData == null || !rawData!.containsKey('sensors')) return 0.0;
    return (rawData!['sensors']['humidity'] ?? 0.0).toDouble();
  }

  // Gelen JSON verisinden modeli oluşturur
  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(isOnline: json['status'] == 'online', rawData: json);
  }

  // Eski command servisinin hata vermemesi için eksik olan güncelleme metodu eklendi
  void updateFromJson(Map<String, dynamic> json) {
    isOnline = json['status'] == 'online';
    rawData = json;
  }
}
