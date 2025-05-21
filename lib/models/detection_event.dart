class DetectionEvent {
  final DateTime timestamp;
  final List<String> sources; // e.g., ['WiFi', 'Mic']
  final double confidence; // Overall confidence score (if applicable)
  final String? signalId; // e.g., SSID name, Bluetooth device ID
  final double? rssi; // Signal strength

  DetectionEvent({
    required this.timestamp,
    required this.sources,
    required this.confidence,
    this.signalId,
    this.rssi,
  });

  // Optional: Add methods for serialization if needed for Hive
  // Map<String, dynamic> toJson() => { ... };
  // factory DetectionEvent.fromJson(Map<String, dynamic> json) => { ... };
}
