# Project Context: RavenEye Lite - Android Build Troubleshooting

**Last Known Status (before interruption on 2025-05-06 ~12:53 PM):**
The project was experiencing a persistent Android build failure. The primary error was an `aapt2.exe` resource linking failure related to `android.jar` for SDK Platform 35. This prevented the Flutter application from building and running on an Android device/emulator.

**Troubleshooting Steps Attempted:**

1.  **Initial Diagnosis:**
    *   Build failed with `aapt2.exe E ... LoadedArsc.cpp:94] RES_TABLE_TYPE_TYPE entry offsets overlap actual entry data.` and `Failed to load resources table in APK 'C:\Users\USER\AppData\Local\Android\sdk\platforms\android-35\android.jar'.`
    *   Checked `android/build.gradle`: AGP `8.2.0`, Kotlin `1.9.20`.
    *   Checked `android/gradle/wrapper/gradle-wrapper.properties`: Gradle `8.2`.
    *   Checked `android/app/build.gradle`: `compileSdk = 35`, `buildToolsVersion = "35.0.0"`.

2.  **Attempt 1: Downgrade SDK Version (Hypothesis: SDK 35 unstable/incompatible)**
    *   Modified `android/app/build.gradle`:
        *   `compileSdk` from `35` to `34`.
        *   `buildToolsVersion` from `"35.0.0"` to `"34.0.0"`.
    *   Ran `flutter clean && flutter run`.
    *   **Result:** New build failure. `audioplayers_android` plugin required `compileSdk 35`. Also, a dexing error related to `record_android` plugin: `Sealed classes are not supported as program classes`.

3.  **Attempt 2: Revert SDK to 35, Address Plugin Conflicts (Hypothesis: `flutter clean` might resolve initial aapt2 error)**
    *   Modified `android/app/build.gradle` back to:
        *   `compileSdk = 35`.
        *   `buildToolsVersion = "35.0.0"`.
    *   Ran `flutter run`.
    *   **Result:** Build failed. The `record_android` dexing error persisted, and the original `aapt2.exe` error for SDK 35 returned.

4.  **Attempt 3: Downgrade AGP and Gradle (Hypothesis: AGP/Gradle incompatibility with SDK 35 or plugins)**
    *   Modified `android/build.gradle`:
        *   AGP from `8.2.0` to `8.1.4`.
    *   Modified `android/gradle/wrapper/gradle-wrapper.properties`:
        *   Gradle from `8.2` to `8.0`.
    *   Kept `compileSdk = 35`.
    *   Ran `flutter clean && flutter run`.
    *   **Result:** Build failed. The original `aapt2.exe` error for SDK 35 persisted.

5.  **Attempt 4: Reinstall SDK Platform 35 (Hypothesis: Corrupted SDK files)**
    *   User was instructed to manually reinstall Android SDK Platform 35 via Android Studio SDK Manager.
    *   User confirmed they tried this.
    *   **Result:** Build failed after reinstallation. The same `aapt2.exe` error for SDK 35 persisted.

6.  **Attempt 5: Disable AAPT2 Daemon (Hypothesis: AAPT2 daemon causing issues)**
    *   Modified `android/gradle.properties`:
        *   Added `android.aapt2.daemon.enable=false`.
    *   Ran `flutter clean && flutter run`.
    *   **Result:** Build failed. The same `aapt2.exe` error for SDK 35 persisted.

7.  **Attempt 6: Explicitly Set targetSdk (Hypothesis: Issue with `flutter.targetSdkVersion` resolution)**
    *   Modified `android/app/build.gradle`:
        *   Changed `targetSdk = flutter.targetSdkVersion` to `targetSdk = 35`.
    *   **Next Step (Interrupted):** Was about to run `flutter clean && flutter run`.

**Relevant Configuration Files (Last Known State before interruption):**

*   `android/build.gradle`:
    ```gradle
    buildscript {
        ext.kotlin_version = '1.9.20'
        repositories {
            google()
            mavenCentral()
        }
        dependencies {
            classpath 'com.android.tools.build:gradle:8.1.4' // Downgraded
            classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        }
    }
    // ... rest of file
    ```

*   `android/gradle/wrapper/gradle-wrapper.properties`:
    ```properties
    distributionBase=GRADLE_USER_HOME
    distributionPath=wrapper/dists
    zipStoreBase=GRADLE_USER_HOME
    zipStorePath=wrapper/dists
    distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip // Downgraded
    ```

*   `android/app/build.gradle`:
    ```gradle
    android {
        namespace = "com.example.raveneye"
        compileSdk = 35
        buildToolsVersion = "35.0.0"
        // ...
        defaultConfig {
            // ...
            minSdk = 26
            targetSdk = 35 // Explicitly set
            // ...
        }
        // ...
    }
    ```

*   `android/gradle.properties`:
    ```properties
    org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError
    android.useAndroidX=true
    android.enableJetifier=true
    android.aapt2.daemon.enable=false // Added
    ```

*   `pubspec.yaml` (relevant dependencies):
    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      # ...
      audioplayers: ^6.0.0 # Requires compileSdk 35
      record: ^5.0.5
      # ...
    ```

The immediate next step before the interruption was to attempt a build with `compileSdk = 35`, `targetSdk = 35`, AGP `8.1.4`, Gradle `8.0`, and AAPT2 daemon disabled.

**Updates:**

1.  **Implemented Wi-Fi Scanning Logic:**
    *   Modified `lib/services/wifi_service.dart` to implement the `scanForDrones()` method using `WiFiForIoTPlugin.loadWifiList()` to scan for Wi-Fi networks and identify potential drone SSIDs.

2.  **Implemented Bluetooth Scanning Logic:**
    *   Modified `lib/services/bluetooth_service.dart` to implement the `scanStream()` method using `FlutterBluePlus.startScan()` to scan for Bluetooth devices and identify potential drone devices based on RSSI and blacklist.

3.  **Connected Services to Controller:**
    *   Modified `lib/controllers/detection_controller.dart` to instantiate `WifiService` and `BluetoothService`, start and stop the scans, and handle detection events.

4.  **Updated UI (HomeScreen):**
    *   Modified `lib/views/home_screen.dart` to add toggle switches for Wi-Fi and Bluetooth scanning, connect them to the `DetectionController` to start and stop the scans, and navigate to the `LogScreen`.
    *   Added an `ever` listener to `lib/views/home_screen.dart` to show the alert modal when a drone is detected.

**Next Steps:**

1.  Test the Wi-Fi and Bluetooth scanning functionality on an Android device or emulator.
2.  Implement the Microphone Acoustic Detection logic.
3.  Implement the logging functionality using Hive.
4.  Add the TFLite model asset and implement the TFLite inference logic.
5.  Implement the alert modal and log screen UI.
6.  Test the complete application.
