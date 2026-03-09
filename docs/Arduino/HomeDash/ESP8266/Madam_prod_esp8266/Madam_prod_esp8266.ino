#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>

// --- AĞ AYARLARI ---
const char* ssid = "llama_iot";
const char* password = "testteam";

IPAddress local_IP(192, 168, 55, 20);
IPAddress gateway(192, 168, 55, 1);
IPAddress subnet(255, 255, 255, 0);

ESP8266WebServer server(8080);

// --- DONANIM AYARLARI ---
const int relay1Pin = 5; // D1
const int pirPin = 4;    // D2 (PIR Sensörü Data)

bool relay1State = false;
bool shouldReboot = false;
unsigned long rebootTimer = 0;

void handleStatus() {
  StaticJsonDocument<512> doc;
  doc["deviceIp"] = "192.168.55.20";
  doc["role"] = "relay_node";
  doc["status"] = "online";
  
  JsonObject relays = doc.createNestedObject("relays");
  relays["relay_1"] = relay1State ? "on" : "off";

  // SENSÖR VERİLERİ (Flutter Arayüzü İçin)
  JsonObject sensors = doc.createNestedObject("sensors");
  sensors["motion"] = (digitalRead(pirPin) == HIGH) ? "detected" : "clear";
  sensors["temperature"] = 24.5; // Simüle edilmiş ısı
  sensors["humidity"] = 48.0;

  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleCommand() {
  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"error\":\"No body\"}");
    return;
  }

  String body = server.arg("plain");
  StaticJsonDocument<256> doc;
  deserializeJson(doc, body);

  String action = doc["action"];
  String target = doc["target"];

  if (target == "system" && action == "reboot") {
    server.send(200, "application/json", "{\"result\":\"success\"}");
    shouldReboot = true;
    rebootTimer = millis();
    return;
  }

  if (target == "relay_1") {
    if (action == "toggle") relay1State = !relay1State;
    else if (action == "open") relay1State = true;
    else if (action == "close") relay1State = false;
    digitalWrite(relay1Pin, relay1State ? HIGH : LOW);
  }

  server.send(200, "application/json", "{\"result\":\"success\"}");
}

void setup() {
  Serial.begin(115200);
  pinMode(relay1Pin, OUTPUT);
  pinMode(pirPin, INPUT);
  digitalWrite(relay1Pin, LOW);

  WiFi.config(local_IP, gateway, subnet);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }

  server.on("/status", HTTP_GET, handleStatus);
  server.on("/command", HTTP_POST, handleCommand);
  server.begin();
}

void loop() {
  server.handleClient();
  if (shouldReboot && (millis() - rebootTimer > 1000)) {
    ESP.restart();
  }
}