import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/detection_event.dart';

class WifiService {
  final List<String> _knownFpvSsids = [
    'FPV_', 'DJI_', 'Goggles_', 'Naza',
    'Analog' // Case-insensitive check might be needed
  ];
  final double _rssiThreshold = -70.0; // Minimum signal strength for detection

  bool _isScanningWifi = false;

  Stream<DetectionEvent> scanForDrones() async* {
    // Ensure permissions are granted (Location is needed for WiFi scan on Android)
    if (await Permission.location.request().isGranted) {
      try {
        // Prevent multiple scans from running simultaneously
        if (_isScanningWifi) {
          print("WiFi scan already in progress.");
          return;
        }
        _isScanningWifi = true;

        // Continuously scan Wi-Fi networks
        while (true) {
          List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();

          for (var network in networks) {
            if (network.ssid == null || network.level == null) continue;

            String ssidLower = network.ssid!.toLowerCase();
            bool isFpvSsid = _knownFpvSsids
                .any((prefix) => ssidLower.startsWith(prefix.toLowerCase()));

            if (isFpvSsid && network.level! > _rssiThreshold) {
              yield DetectionEvent(
                timestamp: DateTime.now(),
                sources: ['WiFi'],
                confidence:
                    1.0, // Confidence is high if SSID matches and RSSI is strong
                signalId: network.ssid,
                rssi: network.level!.toDouble(),
              );
            }
          }
          // Scan interval (adjust as needed to balance detection speed and battery usage)
          await Future.delayed(const Duration(seconds: 5));
        }
      } catch (e) {
        print("WiFi Scan Error: $e");
        // Handle errors (e.g., Wi-Fi disabled, permissions denied after check)
      } finally {
        _isScanningWifi = false;
      }
    } else {
      print("Location permission denied for WiFi scan.");
      // Handle permission denial
    }
  }

  void stopScan() {
    // Implement a way to stop the continuous scan if needed
    // For example, set a flag to break the loop
    print("WiFi scan stopped.");
  }
}
