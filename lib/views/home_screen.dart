import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detection_controller.dart';
import 'alert_modal.dart'; // Import alert modal
import 'log_screen.dart'; // Import log screen

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final DetectionController detectionController =
      Get.put(DetectionController());

  @override
  Widget build(BuildContext context) {
    // Observe isDroneDetected and show alert
    ever(detectionController.isDroneDetected, (bool detected) {
      if (detected) {
        showThreatAlert(context, detectionController.detectionLog.last);
        detectionController.isDroneDetected.value =
            false; // Reset after showing alert
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('RavenEye Lite'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Display
            Obx(() => Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: detectionController.isDroneDetected.value
                        ? Colors.red[700]
                        : Colors.green[700],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      detectionController.isDroneDetected.value
                          ? '⚠️ DRONE DETECTED ⚠️'
                          : 'Monitoring... No Drone Nearby',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            const SizedBox(height: 20),

            // Detection Toggles
            const Text('Enable Detection Methods:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Obx(() => _buildToggleSwitch(
                  'Wi-Fi Scanner',
                  detectionController.isWifiScanning.value,
                  (value) {
                    if (value) {
                      detectionController.startWifiScan();
                    } else {
                      detectionController.stopWifiScan();
                    }
                  },
                )),
            Obx(() => _buildToggleSwitch(
                  'Bluetooth Scanner',
                  detectionController.isBluetoothScanning.value,
                  (value) {
                    if (value) {
                      detectionController.startBluetoothScan();
                    } else {
                      detectionController.stopBluetoothScan();
                    }
                  },
                )),
            _buildToggleSwitch('Microphone Acoustic Detection', true, (value) {
              // TODO: Implement logic to start/stop Mic recording/detection via controller/service
              print("Mic Toggle: $value");
            }),

            const Spacer(), // Pushes button to the bottom

            // View Log Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => LogScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('View Detection Log',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(
      String title, bool initialValue, Function(bool) onChanged) {
    return Obx(() => SwitchListTile(
          title: Text(title),
          value: (title == 'Wi-Fi Scanner')
              ? detectionController.isWifiScanning.value
              : (title == 'Bluetooth Scanner')
                  ? detectionController.isBluetoothScanning.value
                  : false,
          onChanged: onChanged,
          activeColor: Colors.tealAccent[400],
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey[700],
        ));
  }
}
