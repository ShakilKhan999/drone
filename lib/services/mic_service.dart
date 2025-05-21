import 'dart:async';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/detection_event.dart';
// Import the TF Model service when it's created
// import 'tf_model_service.dart';

class MicService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  // final TfModelService _tfModelService = TfModelService(); // Instantiate when available
  final double _confidenceThreshold =
      0.75; // Minimum confidence for drone detection

  StreamSubscription? _recordSub;
  StreamController<DetectionEvent>? _detectionController;

  // TODO: Load the TFLite model (likely in TfModelService)

  Stream<DetectionEvent> startRecordingAndDetection() {
    _detectionController?.close(); // Close previous stream if exists
    _detectionController = StreamController<DetectionEvent>();

    _startRecording((audioData) async {
      // TODO: Convert audioData (likely file path or raw bytes) to format needed by TFLite model (e.g., MFCCs)
      // This conversion logic might live here or in TfModelService

      // TODO: Feed processed audio to the TFLite model
      // double confidence = await _tfModelService.predict(processedAudio);

      double confidence = 0.0; // Placeholder
      bool isDroneSound = confidence > _confidenceThreshold; // Placeholder

      print(
          "Audio chunk processed. Confidence: $confidence"); // Temporary print

      if (isDroneSound) {
        _detectionController?.add(DetectionEvent(
          timestamp: DateTime.now(),
          sources: ['Mic'],
          confidence: confidence,
          // signalId: null, // No specific signal ID for mic detection
          // rssi: null,
        ));
      }
    });

    return _detectionController!.stream;
  }

  Future<void> _startRecording(Function(String path) onData) async {
    if (await Permission.microphone.request().isGranted) {
      try {
        if (await _audioRecorder.hasPermission()) {
          // Define recording configuration
          const recordConfig = RecordConfig(
            encoder: AudioEncoder.wav, // Choose appropriate encoder
            sampleRate: 16000, // Sample rate expected by model?
            numChannels: 1, // Mono channel
          );

          // Start recording to a stream or file periodically
          // Option 1: Record short snippets periodically (e.g., 1-2 seconds)
          // This requires managing file paths and potentially overlapping recordings.

          // Option 2: Record continuously and process chunks (if supported by `record` or another package)
          // The `record` package seems more file-oriented. Let's stick to periodic files for now.

          // Example: Record 2-second snippets repeatedly
          _recordPeriodically(recordConfig, Duration(seconds: 2), onData);
        }
      } catch (e) {
        print("Mic Recording Start Error: $e");
        _detectionController?.addError("Mic Recording Start Error: $e");
      }
    } else {
      print("Microphone permission denied.");
      _detectionController?.addError("Microphone permission denied.");
    }
  }

  // Helper for periodic recording
  void _recordPeriodically(RecordConfig config, Duration interval,
      Function(String path) onData) async {
    // Use a timer to trigger recording repeatedly
    Timer.periodic(interval, (timer) async {
      if (!await _audioRecorder.isRecording()) {
        // Define a unique path for each snippet
        final path =
            'audio_${DateTime.now().millisecondsSinceEpoch}.wav'; // Store in app's temp directory?
        await _audioRecorder.start(config, path: path);
        print("Started recording to $path");

        // Stop recording after the interval duration (or slightly less to avoid overlap issues)
        await Future.delayed(interval -
            Duration(milliseconds: 100)); // Stop just before next cycle
        if (await _audioRecorder.isRecording()) {
          final recordedPath = await _audioRecorder.stop();
          print("Stopped recording: $recordedPath");
          if (recordedPath != null) {
            onData(recordedPath);
            // TODO: Optionally delete the file after processing: File(recordedPath).delete();
          }
        }
      }
    });
    // Need a way to cancel this timer when stopping the service
  }

  Future<void> stopRecording() async {
    _recordSub?.cancel();
    _recordSub = null;
    await _audioRecorder.stop();
    await _audioRecorder.dispose();
    _detectionController?.close();
    _detectionController = null;
    print("Mic recording stopped and resources disposed.");
  }
}
