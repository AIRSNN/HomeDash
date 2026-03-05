#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

// --- AĞ AYARLARI ---
const char* ssid = "llama_iot";        // SSID
const char* password = "testteam";     // Şifre

// MADAM Ağ Topolojisine Göre Statik IP (Cihaz 2: .29)
IPAddress local_IP(192, 168, 55, 29);
IPAddress gateway(192, 168, 55, 1);    
IPAddress subnet(255, 255, 255, 0);

// MADAM API Portu
WebServer server(8080);

// --- DONANIM AYARLARI ---
// ESP32-C6 için uygun GPIO pinlerini kendi donanımınıza göre değiştirebilirsiniz
const int relay1Pin = 4; // 1. Röle Pini (Örnek GPIO 4)
const int relay2Pin = 5; // 2. Röle Pini (Örnek GPIO 5)

bool relay1State = false;
bool relay2State = false;

// 1. GET /status (MADAM'ın cihazı "Online" görmesi için)
void handleStatus() {
  StaticJsonDocument<256> doc;
  doc["deviceIp"] = "192.168.55.29";
  doc["role"] = "primary_controller"; // Dashboard şemanıza uygun rol
  doc["status"] = "online";
  
  JsonObject relays = doc.createNestedObject("relays");
  relays["relay_1"] = relay1State ? "on" : "off";
  relays["relay_2"] = relay2State ? "on" : "off";

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
  StaticJsonDocument<384> doc;
  DeserializationError error = deserializeJson(doc, body);

  if (error) {
    server.send(400, "application/json", "{\"error\":\"Invalid JSON\"}");
    return;
  }

  String action = doc["action"];
  String target = doc["target"];

  // Röle 1 Hedefi
  if (target == "relay_1") {
    if (action == "toggle") relay1State = !relay1State;
    else if (action == "open") relay1State = true;
    else if (action == "close") relay1State = false;
    
    digitalWrite(relay1Pin, relay1State ? HIGH : LOW);
    Serial.println("Röle 1 durumu: " + String(relay1State));
  }
  // Röle 2 Hedefi
  else if (target == "relay_2") {
    if (action == "toggle") relay2State = !relay2State;
    else if (action == "open") relay2State = true;
    else if (action == "close") relay2State = false;
    
    digitalWrite(relay2Pin, relay2State ? HIGH : LOW);
    Serial.println("Röle 2 durumu: " + String(relay2State));
  }

  // Başarı yanıtı dön
  server.send(200, "application/json", "{\"result\":\"success\", \"message\":\"Komut uygulandi\"}");
}

void setup() {
  Serial.begin(115200);
  
  // Pin ayarları ve başlangıç durumları
  pinMode(relay1Pin, OUTPUT);
  pinMode(relay2Pin, OUTPUT);
  digitalWrite(relay1Pin, LOW); 
  digitalWrite(relay2Pin, LOW); 

  // Ağ yapılandırması
  if (!WiFi.config(local_IP, gateway, subnet)) {
    Serial.println("Statik IP yapilandirmasi basarisiz!");
  }
  
  WiFi.begin(ssid, password);
  Serial.print("ESP32-C6 WiFi Baglaniliyor");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\nBaglandi!");
  Serial.print("IP Adresi: ");
  Serial.println(WiFi.localIP());

  // Sunucu Yönlendirmeleri
  server.on("/status", HTTP_GET, handleStatus);
  server.on("/command", HTTP_POST, handleCommand);
  
  server.begin();
  Serial.println("ESP32-C6 HTTP Sunucu 8080 portunda basladi.");
}

void loop() {
  server.handleClient();
}