class PoseFrameData {
  final int frameIndex; // Eklendi: Kare sırası
  final int timestampMs;
  final Map<String, double> angles; 

  PoseFrameData({
    required this.frameIndex,
    required this.timestampMs,
    required this.angles,
  });

  Map<String, dynamic> toJson() {
    return {
      'frameIndex': frameIndex,
      'timestampMs': timestampMs,
      'angles': angles.map((key, value) => MapEntry(key, double.parse(value.toStringAsFixed(2)))),
    };
  }
}