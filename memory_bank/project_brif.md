Project Name: RavenEye Lite
Platform: Flutter (Android only for MVP)
Goal: Detect FPV kamikaze drones nearby (≤100 meters) using only phone sensors (Wi-Fi, Bluetooth, Microphone) with real-time alerts — fully offline, with no external hardware or internet.

📲 Key Features
1. Wi-Fi Passive Scanner
Use wifi_iot to scan for nearby SSIDs every 5–10 seconds.

Match SSIDs against a list of known FPV-related names like:

FPV_*, DJI_*, Goggles_*, Naza*, Analog*

Log signal strength (RSSI) and channel frequency.

If an SSID matches and has strong signal (RSSI > -70), consider it a detection.

2. Bluetooth Activity Scanner
Use flutter_blue_plus to continuously scan for BLE devices.

Flag unknown BLE devices that suddenly appear with high RSSI (e.g. > -65).

Avoid known safe devices using a local blacklist.

3. Acoustic Drone Detection
Use flutter_sound or record to capture 1–2 seconds of audio continuously.

Convert it into MFCCs or log-Mel spectrogram format.

Feed audio into a TensorFlow Lite model (use tflite_flutter).

If the model predicts a drone sound with high confidence (e.g. > 0.75), trigger an alert.

4. Threat Alert System
Show full-screen modal when a detection occurs.

Show:

Detection source (WiFi / Mic / Bluetooth)

Confidence score

Estimated range (based on RSSI, if possible)

Trigger vibration and alert tone.

Option to dismiss alert.

5. Detection Log
Save all events locally using hive or shared_preferences.

Log format:

dart
Copy
Edit
class DetectionEvent {
  final DateTime timestamp;
  final List<String> sources;
  final double confidence;
  final String? signalId;
  final double? rssi;
}
6. Offline-First Mode
App must function with no internet, GPS, or external device.

All models, assets, and lists should be stored locally.

Minimal battery and processing usage (scan intervals, async operations).

📱 UI Components
🧭 Main Screen
Toggles for Wi-Fi, Mic, Bluetooth monitoring.

Status bar: “No Drone Nearby” or “⚠️ Drone Detected”

Button: “View Detection Log”

🚨 Threat Alert Modal
markdown
Copy
Edit
----------------------------
| !!! WARNING – DRONE !!!  |
|                          |
| Detected via: Mic + Wi-Fi|
| Confidence: 0.89         |
| Range: < 100m (Est.)     |
|                          |
| [Dismiss Alert]          |
----------------------------
📖 Detection Log Page
List of all detection events with:

Time

Sources

Confidence

Signal ID

🔐 Required Permissions
Microphone

Location (needed for Wi-Fi scanning on Android)

Bluetooth + Bluetooth Connect/Scan (Android 12+)

📦 Suggested Packages
Purpose	Package
Wi-Fi Scanning	wifi_iot
BLE Scanning	flutter_blue_plus
Microphone	record, flutter_sound
TensorFlow Lite	tflite_flutter
Storage	hive
Vibration	vibration
Audio Alerts	audioplayers
State Management	get

📂 File Structure (Suggested)
bash
Copy
Edit
/lib
 ├── main.dart
 ├── controllers/
 │     └── detection_controller.dart
 ├── models/
 │     └── detection_event.dart
 ├── services/
 │     ├── wifi_service.dart
 │     ├── bluetooth_service.dart
 │     ├── mic_service.dart
 │     └── tf_model_service.dart
 ├── views/
 │     ├── home_screen.dart
 │     ├── alert_modal.dart
 │     └── log_screen.dart
 └── utils/
       └── permissions_helper.dart
🧠 Notes for Developer
The app must continuously run detection in the background (for MVP, can stay in foreground).

Keep model lightweight (≤ 3MB) and ensure inference is fast (< 1 sec).

Show only one alert at a time. After alert is dismissed, detection continues.

Provide a “debug mode” to show signal strengths and raw predictions (optional).

