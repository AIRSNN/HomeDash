#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

// --- AĞ AYARLARI ---
const char* ssid = "llama_iot";
const char* password = "testteam";

IPAddress local_IP(192, 168, 55, 29);
IPAddress gateway(192, 168, 55, 1);    
IPAddress subnet(255, 255, 255, 0);

WebServer server(8080);

// --- DONANIM AYARLARI ---
const int relay1Pin = 4; 
const int relay2Pin = 5; 

bool relay1State = false;
bool relay2State = false;

// REBOOT KONTROLÜ
bool shouldReboot = false;
unsigned long rebootTimer = 0;

void handleStatus() {
  StaticJsonDocument<256> doc;
  doc["deviceIp"] = "192.168.55.29";
  doc["role"] = "primary_controller"; 
  doc["status"] = "online";
  
  JsonObject relays = doc.createNestedObject("relays");
  relays["relay_1"] = relay1State ? "on" : "off";
  relays["relay_2"] = relay2State ? "on" : "off";

  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleCommand() {
  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"error\":\"Body yok\"}");
    return;
  }

  String body = server.arg("plain");
  StaticJsonDocument<384> doc;
  deserializeJson(doc, body);

  String action = doc["action"];
  String target = doc["target"];

  // SİSTEM REBOOT
  if (target == "system" && action == "reboot") {
    server.send(200, "application/json", "{\"result\":\"success\", \"message\":\"Rebooting...\"}");
    shouldReboot = true;
    rebootTimer = millis();
    return;
  }
  
  // RÖLE KONTROLLERİ
  if (target == "relay_1") {
    if (action == "toggle") relay1State = !relay1State;
    else if (action == "open") relay1State = true;
    else if (action == "close") relay1State = false;
    digitalWrite(relay1Pin, relay1State ? HIGH : LOW);
  }
  else if (target == "relay_2") {
    if (action == "toggle") relay2State = !relay2State;
    else if (action == "open") relay2State = true;
    else if (action == "close") relay2State = false;
    digitalWrite(relay2Pin, relay2State ? HIGH : LOW);
  }

  server.send(200, "application/json", "{\"result\":\"success\"}");
}

void setup() {
  Serial.begin(115200);
  pinMode(relay1Pin, OUTPUT);
  pinMode(relay2Pin, OUTPUT);
  digitalWrite(relay1Pin, LOW); 
  digitalWrite(relay2Pin, LOW); 

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