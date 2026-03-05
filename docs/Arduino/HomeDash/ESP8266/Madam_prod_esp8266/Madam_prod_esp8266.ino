#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>

// --- AĞ AYARLARI ---
const char* ssid = "llama_iot";        // Kendi SSID'nizi girin
const char* password = "testteam";  // Kendi şifrenizi girin

// MADAM Ağ Topolojisine Göre Statik IP (Cihaz 1: .20)
IPAddress local_IP(192, 168, 55, 20);
IPAddress gateway(192, 168, 55, 1);    // Router IP'niz farklıysa güncelleyin
IPAddress subnet(255, 255, 255, 0);

// MADAM API Portu
ESP8266WebServer server(8080);

// --- DONANIM AYARLARI ---
const int relay1Pin = 5; // NodeMCU'da D1 pini (GPIO5)
bool relay1State = false; // Başlangıçta kapalı

// 1. GET /status (MADAM'ın cihazı "Online" görmesi için)
void handleStatus() {
  StaticJsonDocument<200> doc;
  doc["deviceIp"] = "192.168.55.20";
  doc["role"] = "relay_node";
  doc["status"] = "online";
  
  JsonObject relays = doc.createNestedObject("relays");
  relays["relay_1"] = relay1State ? "on" : "off";

  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

// 2. POST /command (MADAM'ın komut göndermesi için)
void handleCommand() {
  if (server.hasArg("plain") == false) {
    server.send(400, "application/json", "{\"error\":\"Body not received\"}");
    return;
  }

  String body = server.arg("plain");
  StaticJsonDocument<256> doc;
  DeserializationError error = deserializeJson(doc, body);

  if (error) {
    server.send(400, "application/json", "{\"error\":\"Invalid JSON\"}");
    return;
  }

  String action = doc["action"];
  String target = doc["target"];

  // Röle 1 Hedefi İçin Şema Doğrulaması
  if (target == "relay_1") {
    if (action == "toggle") {
      relay1State = !relay1State;
    } else if (action == "open") {
      relay1State = true;
    } else if (action == "close") {
      relay1State = false;
    }
    // Donanımı güncelle
    digitalWrite(relay1Pin, relay1State ? HIGH : LOW);
    Serial.println("Röle 1 durumu güncellendi: " + String(relay1State));
  }

  // Başarı yanıtı dön
  server.send(200, "application/json", "{\"result\":\"success\", \"message\":\"Komut uygulandi\"}");
}

void setup() {
  Serial.begin(115200);
  
  // Pin ayarları
  pinMode(relay1Pin, OUTPUT);
  digitalWrite(relay1Pin, LOW); // Başlangıçta güvenli durum (kapalı)

  // Ağ yapılandırması
  if (!WiFi.config(local_IP, gateway, subnet)) {
    Serial.println("Statik IP yapilandirmasi basarisiz!");
  }
  
  WiFi.begin(ssid, password);
  Serial.print("WiFi Baglaniliyor");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\nBaglandi!");
  Serial.print("IP Adresi: ");
  Serial.println(WiFi.localIP());

  // Sunucu Yönlendirmeleri (Endpoints)
  server.on("/status", HTTP_GET, handleStatus);
  server.on("/command", HTTP_POST, handleCommand);
  
  // Sunucuyu başlat
  server.begin();
  Serial.println("HTTP Sunucu 8080 portunda basladi.");
}

void loop() {
  // Gelen HTTP isteklerini dinle
  server.handleClient();
}