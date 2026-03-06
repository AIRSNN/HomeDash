/// MADAM Projesi - ESP Uyumlu Durum Modeli
class DeviceStatus {
  bool isOnline;
  Map<String, dynamic>? rawData;
  DateTime? lastSeen;

  DeviceStatus({this.isOnline = false, this.rawData, this.lastSeen});

  /// Cihazdan gelen JSON ile modeli günceller
  void updateFromJson(Map<String, dynamic> json) {
    isOnline = true;
    rawData = json;
    lastSeen = DateTime.now();
  }

  /// ESP'nin iç içe geçmiş JSON yapısından röle durumunu çeker
  /// Örnek: rawData['relays']['relay_1'] == "on"
  bool isRelayActive(String relayKey) {
    if (rawData == null || !rawData!.containsKey('relays')) return false;
    final relays = rawData!['relays'];
    if (relays is Map<String, dynamic>) {
      return relays[relayKey] == 'on';
    }
    return false;
  }

  /// UI'da cihazın altında görünen özet metin
  String getSummary() {
    if (!isOnline) return 'Çevrimdışı';
    if (rawData == null) return 'Veri yok';

    final role = rawData!['role'] ?? 'Cihaz';
    final status = rawData!['status'] ?? 'Aktif';
    return '$role ($status)';
  }
}
