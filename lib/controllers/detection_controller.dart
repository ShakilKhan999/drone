import 'package:get/get.dart';
import '../models/detection_event.dart';

import 'package:get/get.dart';
import '../models/detection_event.dart';
import '../services/wifi_service.dart';
import '../services/bluetooth_service.dart';

class DetectionController extends GetxController {
  // Service instances
  final WifiService wifiService = WifiService();
  final BluetoothService bluetoothService = BluetoothService();

  // Observable list to hold detection events for the log
  var detectionLog = <DetectionEvent>[].obs;

  // Observable status for the main screen
  var detectionStatus = "Monitoring...".obs;
  var isDroneDetected = false.obs;

  // Observables to track scanning status
  var isWifiScanning = false.obs;
  var isBluetoothScanning = false.obs;

  // Start Wi-Fi scanning
  void startWifiScan() {
    isWifiScanning.value = true;
    wifiService.scanForDrones().listen((event) {
      handleDetectionEvent(event);
    });
  }

  // Stop Wi-Fi scanning
  void stopWifiScan() {
    isWifiScanning.value = false;
    wifiService.stopScan();
  }

  // Start Bluetooth scanning
  void startBluetoothScan() {
    isBluetoothScanning.value = true;
    bluetoothService.scanStream().listen((event) {
      handleDetectionEvent(event);
    });
  }

  // Stop Bluetooth scanning
  void stopBluetoothScan() {
    isBluetoothScanning.value = false;
    bluetoothService.stopScan();
  }

  // Handle a detection event
  void handleDetectionEvent(DetectionEvent event) {
    detectionLog.add(event);
    isDroneDetected.value = true; // Set to true on any detection
    detectionStatus.value = "⚠️ DRONE DETECTED ⚠️";
    // TODO: Trigger alert modal (showThreatAlert)
    print(
        "Detection Event: ${event.sources} - ${event.signalId} - ${event.rssi}");
  }

  @override
  void onClose() {
    // Stop scans when the controller is closed
    stopWifiScan();
    stopBluetoothScan();
    super.onClose();
  }
}
