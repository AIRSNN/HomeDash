# MADAM HomeDash - Project State & Architecture
**Date:** March 2026
**Framework:** Flutter (Windows Desktop / Web)
**Hardware:** ESP32-C6 & ESP8266 (C++)

## 1. Project Overview
MADAM is a centralized Smart Home / IoT Dashboard. It features real-time telemetry (10s polling), immediate state updates (force refresh), device-specific terminal logs, and Machine-to-Machine (M2M) automation capabilities.

## 2. Network Topology & Hardware Nodes
* **Actuator Node (Cihaz 1):** `192.168.55.20` (ESP8266)
    * Role: `relay_node`
    * Hardware: 1x Relay (`relay_1`), 1x PIR Motion Sensor, Temp/Hum Simulation.
    * JSON Endpoints: `/status` (Returns relays and sensors data), `/command` (Supports `toggle`, `open`, `close`, `reboot`).
* **Master Node (Cihaz 2):** `192.168.55.29` (ESP32-C6)
    * Role: `primary_controller`
    * Hardware: 2x Relays (`relay_1`, `relay_2`).
    * JSON Endpoints: `/status` (Returns relays data), `/command` (Supports relay controls and `reboot`).

## 3. Flutter App Architecture (`lib/state/dashboard_state.dart`)
* **State Management:** `ChangeNotifier` (Provider).
* **Polling Mechanism:** 10-second interval fetching statuses via `PingService` and `DeviceCommandService`.
* **State Recovery:** If a device reboots/loses power, the app remembers its enforced target state (`_enforcedStates`) and automatically resyncs it upon reconnection.
* **M2M Automation:** If `192.168.55.20` motion changes from 'off' to 'on', the app automatically toggles `relay_1` on `192.168.55.29`.
* **Logging:** Two levels of logs: Global system logs (`logs`) and device-specific terminal logs (`deviceLogs[ip]`).

## 4. UI/UX State (`lib/pages/dashboard_page.dart`)
* **Design System:** Glassmorphism, Tailwind-inspired colors (Primary: `#5B13EC`, Neon Green: `#00FF41`), custom scrollbars, JetBrains Mono for logs.
* **Device Cards:** * Includes a Reboot (Restart) button with a confirmation dialog.
    * Pill menu for tab navigation: `USAGE` (active), `DEVICE`, `SETTING` (currently static UI).
    * Dynamic large tiles for controls (Relay buttons, Temp display, Motion LED).
    * Bottom panel: Real-time mini terminal showing `deviceLogs`.
* **Sidebar:** Animated hover effect (neon green glow) on the Admin profile card. Layout optimized for fullscreen to prevent overflowing of pagination buttons.

## 5. Next Immediate Goal
Transition the static `USAGE`, `DEVICE`, `SETTING` pill buttons inside the `_PrototypeDeviceCard` into functional tabs.
* **USAGE Tab:** Current view (Relay controls, Temp, Motion, Ping, Mini Terminal).
* **DEVICE Tab:** Hardware details (IP, MAC, Firmware Version, Uptime, Signal Strength).
* **SETTING Tab:** Device-specific configurations (Rename device, Automation triggers, Alert toggles).
We need to implement a stateful index or PageView inside the card to switch between these three views dynamically.