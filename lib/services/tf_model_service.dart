import 'package:tflite_flutter/tflite_flutter.dart';
// Import necessary libraries for audio processing if done here
// import 'package:path_provider/path_provider.dart'; // If model path needed
// import 'dart:typed_data'; // For input/output tensors

class TfModelService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  final String _modelPath =
      'assets/drone_detection_model.tflite'; // Ensure this model exists in assets

  TfModelService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // AllocateTensors must be called before loading the model in some versions
      // TfLite.allocateTensors(); // Check tflite_flutter docs if needed

      _interpreter = await Interpreter.fromAsset(_modelPath);
      // Optionally configure interpreter options (threads, delegates) here
      // _interpreter.allocateTensors(); // Allocate memory for input/output tensors

      _isModelLoaded = true;
      print("TFLite model loaded successfully from $_modelPath");
    } catch (e) {
      print("Error loading TFLite model: $e");
      _isModelLoaded = false;
    }
  }

  // Predicts based on pre-processed audio features (e.g., MFCCs)
  // Input shape/type depends entirely on the model's requirements
  Future<double> predict(dynamic processedAudioInput) async {
    if (!_isModelLoaded || _interpreter == null) {
      print("Model not loaded, cannot predict.");
      // Attempt to reload if failed initially?
      if (!_isModelLoaded) await _loadModel();
      if (!_isModelLoaded)
        return 0.0; // Return 0 confidence if still not loaded
    }

    try {
      // 1. Prepare Input Tensor
      // Example: Assuming input is List<List<double>> for a spectrogram/MFCC
      // Need to know the exact input shape and type expected by the model.
      // var input = [processedAudioInput]; // Adjust shape based on model [batch, height, width, channels] or similar
      // Example placeholder shape: [1, 128, 1] if input is a feature vector
      var input = [
        processedAudioInput
      ]; // THIS IS A PLACEHOLDER - NEEDS ACTUAL SHAPE

      // 2. Prepare Output Tensor
      // Example: Assuming output is probability of drone sound [1, 1] or [1, num_classes]
      // Need to know the exact output shape and type.
      var output = List.filled(1 * 1, 0.0).reshape([1, 1]); // PLACEHOLDER SHAPE

      // 3. Run Inference
      _interpreter!.run(input, output);

      // 4. Process Output
      // Example: Assuming output[0][0] is the drone probability
      double confidence = output[0][0];

      print("Prediction Confidence: $confidence");
      return confidence;
    } catch (e) {
      print("Error during TFLite inference: $e");
      return 0.0; // Return 0 confidence on error
    }
  }

  // Dispose of the interpreter when no longer needed
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    print("TFLite interpreter disposed.");
  }
}
