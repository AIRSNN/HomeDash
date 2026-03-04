/// MADAM Projesi - Cihaz Bilgi Modeli
// TODO: Bu model cihaz kayıt rehberinde (registry) sabit IP ve rol tutmak içindir

class DeviceInfo {
  final String id;
  final String ip;
  final String role;

  DeviceInfo({
    required this.id,
    required this.ip,
    required this.role,
  });

  // İleride fromJson / toJson metotları eklenebilir
}
