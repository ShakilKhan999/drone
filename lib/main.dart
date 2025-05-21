import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'utils/permissions_helper.dart';
import 'views/home_screen.dart';
// Import your model and adapter if using Hive TypeAdapters
// import 'models/detection_event.dart';

void main() async {
  // Ensure Flutter bindings are initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  // For complex objects like DetectionEvent, you'd typically register a TypeAdapter
  // await Hive.registerAdapter(DetectionEventAdapter()); // Create this adapter first
  await Hive.initFlutter();
  // Open Hive boxes if needed (e.g., for storing logs)
  // await Hive.openBox<DetectionEvent>('detection_log');
  await Hive.openBox('app_settings'); // Example box

  // Request necessary permissions on startup
  bool permissionsGranted = await PermissionsHelper.requestAllPermissions();

  // Run the app
  runApp(RavenEyeApp(permissionsGranted: permissionsGranted));
}

class RavenEyeApp extends StatelessWidget {
  final bool permissionsGranted;

  const RavenEyeApp({super.key, required this.permissionsGranted});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RavenEye Lite',
      theme: ThemeData(
        brightness: Brightness.dark, // Dark theme
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white, // Title text color
        ),
        cardTheme: CardTheme(
          color: Colors.blueGrey[800],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent[400], // Button background
            foregroundColor: Colors.black, // Button text
          ),
        ),
        dialogBackgroundColor: Colors.blueGrey[800],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.black), // For ElevatedButton text
        ),
        iconTheme: IconThemeData(color: Colors.tealAccent[100]),
        listTileTheme: ListTileThemeData(
          iconColor: Colors.tealAccent[100],
          textColor: Colors.white,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.tealAccent[400];
            }
            return Colors.grey[600]; // Thumb color when off
          }),
          trackColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.tealAccent[400]?.withOpacity(0.5);
            }
            return Colors.grey[800]; // Track color when off
          }),
        ),
        useMaterial3: true,
      ),
      home: permissionsGranted
          ? HomeScreen()
          : const PermissionsDeniedScreen(), // Show a specific screen if permissions fail
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}

// Simple screen to show if permissions were denied on startup
class PermissionsDeniedScreen extends StatelessWidget {
  const PermissionsDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.yellow, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Permissions Required',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'RavenEye Lite requires Location, Microphone, and Bluetooth permissions to function correctly. Please grant these permissions in the app settings.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  PermissionsHelper.openAppSettingsIfDenied();
                  // Note: This won't automatically restart the app or re-check permissions here.
                  // User needs to manually restart or app needs more complex logic.
                },
                child: const Text('Open App Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
