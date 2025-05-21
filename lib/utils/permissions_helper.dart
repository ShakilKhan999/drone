import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  // Checks and requests necessary permissions for all features
  static Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location, // Needed for WiFi scan
      Permission.microphone, // Needed for acoustic detection
      Permission.bluetoothScan, // Needed for BLE scan (Android 12+)
      Permission.bluetoothConnect, // Needed for BLE connect (Android 12+)
      // Add other permissions if needed (e.g., storage for older Android if saving files directly)
    ].request();

    // Check if all essential permissions are granted
    bool locationGranted = statuses[Permission.location]?.isGranted ?? false;
    bool micGranted = statuses[Permission.microphone]?.isGranted ?? false;
    bool btScanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;
    bool btConnectGranted =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;

    // Log status for debugging
    print("Permission Statuses:");
    print("  Location: $locationGranted");
    print("  Microphone: $micGranted");
    print("  Bluetooth Scan: $btScanGranted");
    print("  Bluetooth Connect: $btConnectGranted");

    // Return true only if all required permissions are granted
    // Adjust this logic based on which features are critical
    return locationGranted && micGranted && btScanGranted && btConnectGranted;
  }

  // Individual permission checks (optional, could be useful)
  static Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> checkMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  static Future<bool> checkBluetoothScanPermission() async {
    return await Permission.bluetoothScan.isGranted;
  }

  static Future<bool> checkBluetoothConnectPermission() async {
    return await Permission.bluetoothConnect.isGranted;
  }

  // Function to open app settings if permissions are permanently denied
  static Future<void> openAppSettingsIfDenied() async {
    // Check status of a critical permission, e.g., location
    PermissionStatus status = await Permission.location.status;
    if (status.isPermanentlyDenied || status.isDenied) {
      print("Permissions denied. Opening app settings...");
      await openAppSettings();
    }
    // Repeat for other critical permissions if necessary
  }
}
