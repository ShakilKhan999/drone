import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../controllers/detection_controller.dart';
import '../models/detection_event.dart';

class LogScreen extends StatelessWidget {
  LogScreen({super.key});

  final DetectionController detectionController =
      Get.find(); // Find existing controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Log'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Obx(() {
        // Observe the detectionLog list
        if (detectionController.detectionLog.isEmpty) {
          return const Center(
            child: Text(
              'No detection events logged yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Display logs in a ListView, newest first
        return ListView.builder(
          reverse: true, // Show newest first
          itemCount: detectionController.detectionLog.length,
          itemBuilder: (context, index) {
            final event = detectionController.detectionLog[
                detectionController.detectionLog.length -
                    1 -
                    index]; // Access in reverse
            return _buildLogEntry(event);
          },
        );
      }),
    );
  }

  Widget _buildLogEntry(DetectionEvent event) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedTime = formatter.format(event.timestamp);
    final Color tileColor = event.sources.contains('Mic')
        ? Colors.orange[100]!
        : event.sources.contains('WiFi')
            ? Colors.blue[100]!
            : event.sources.contains('Bluetooth')
                ? Colors.purple[100]!
                : Colors.grey[200]!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: tileColor.withOpacity(0.5),
      child: ListTile(
        leading: Icon(
          _getIconForSource(event.sources),
          color: Colors.black87,
        ),
        title: Text(
          'Detected via: ${event.sources.join(', ')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: $formattedTime'),
            Text('Confidence: ${event.confidence.toStringAsFixed(2)}'),
            if (event.signalId != null) Text('Signal ID: ${event.signalId}'),
            if (event.rssi != null)
              Text('RSSI: ${event.rssi?.toStringAsFixed(1)} dBm'),
          ],
        ),
        isThreeLine: true, // Adjust based on content
      ),
    );
  }

  IconData _getIconForSource(List<String> sources) {
    if (sources.contains('Mic')) return Icons.mic;
    if (sources.contains('WiFi')) return Icons.wifi;
    if (sources.contains('Bluetooth')) return Icons.bluetooth;
    return Icons.help_outline; // Default icon
  }
}
