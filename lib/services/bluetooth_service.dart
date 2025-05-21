import 'dart:async'; // Import for StreamController

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/detection_event.dart';

class BluetoothService {
  final double _rssiThreshold =
      -65.0; // Minimum signal strength for potential detection
  // TODO: Implement a local blacklist for known safe devices (e.g., based on MAC address or name)
  final List<String> _safeDeviceIds =
      []; // Example: ['MAC_ADDRESS_1', 'DEVICE_NAME_2']

  bool _isScanningBluetooth = false;
  StreamController<DetectionEvent>? _detectionController;

  Stream<DetectionEvent> scanStream() {
    _detectionController?.close(); // Close previous stream if exists
    _detectionController = StreamController<DetectionEvent>();

    _startScanWithPermissions((ScanResult r) {
      bool isSafe = _safeDeviceIds.contains(r.device.remoteId.toString()) ||
          (r.device.localName.isNotEmpty &&
              _safeDeviceIds.contains(r.device.localName));

      if (!isSafe && r.rssi > _rssiThreshold) {
        _detectionController!.add(DetectionEvent(
          timestamp: DateTime.now(),
          sources: ['Bluetooth'],
          confidence: 0.7, // Confidence based on RSSI and unknown device status
          signalId: r.device.remoteId.toString(),
          rssi: r.rssi.toDouble(),
        ));
      }
    });

    return _detectionController!.stream;
  }

  Future<void> _startScanWithPermissions(Function(ScanResult) onResult) async {
    // Ensure Bluetooth permissions are granted (Android 12+ requires BLUETOOTH_SCAN and BLUETOOTH_CONNECT)
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted) {
      try {
        // Prevent multiple scans from running simultaneously
        if (_isScanningBluetooth) {
          print("Bluetooth scan already in progress.");
          return;
        }
        _isScanningBluetooth = true;

        // Check if adapter is on
        if (await FlutterBluePlus.adapterState.first ==
            BluetoothAdapterState.on) {
          await FlutterBluePlus.startScan(timeout: null); // Continuous scan
          FlutterBluePlus.scanResults.listen((results) {
            for (ScanResult r in results) {
              onResult(r);
            }
          }, onError: (e) => print("ScanResults Error: $e"));
        } else {
          print("Bluetooth adapter is off.");
          // Optionally, prompt user to turn on Bluetooth
        }
      } catch (e) {
        print("Bluetooth Start Scan Error: $e");
      } finally {
        _isScanningBluetooth = false;
      }
    } else {
      print("Bluetooth permissions denied.");
    }
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    _detectionController?.close();
    _detectionController = null;
    print("Bluetooth scan stopped.");  }
}
