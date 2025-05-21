import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detection_controller.dart'; // To dismiss the alert potentially
import '../models/detection_event.dart'; // To display event details

// This function can be called to show the alert dialog
void showThreatAlert(BuildContext context, DetectionEvent event) {
  // Potentially use Get.dialog for easier management if using GetX navigation
  showDialog(
    context: context,
    barrierDismissible: false, // User must explicitly dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.red[900]?.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.yellowAccent, width: 2),
        ),
        title: const Center(
          child: Text(
            '!!! WARNING – DRONE DETECTED !!!',
            style: TextStyle(
                color: Colors.yellowAccent, fontWeight: FontWeight.bold),
          ),
        ),
        content: SingleChildScrollView(
          // Use SingleChildScrollView if content might overflow
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important for AlertDialog content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildInfoRow('Detected via:', event.sources.join(' + ')),
              _buildInfoRow('Confidence:', event.confidence.toStringAsFixed(2)),
              if (event.rssi != null)
                _buildInfoRow('Signal Strength (RSSI):',
                    '${event.rssi?.toStringAsFixed(1)} dBm'),
              if (event.signalId != null)
                _buildInfoRow('Signal ID:', event.signalId!),
              // Basic range estimation (very rough)
              if (event.rssi != null)
                _buildInfoRow('Estimated Range:', _estimateRange(event.rssi!)),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.red[900],
              ),
              child: const Text('Dismiss Alert',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                // Optionally update controller state
                // Get.find<DetectionController>().dismissAlert();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 16),
        children: [
          TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

// Very basic and likely inaccurate range estimation based on RSSI
String _estimateRange(double rssi) {
  if (rssi > -50) return '< 20m (Very Close)';
  if (rssi > -65) return '< 50m (Close)';
  if (rssi > -75) return '< 100m (Nearby)';
  return '> 100m (Far)';
}
