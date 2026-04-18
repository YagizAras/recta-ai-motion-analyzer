class PoseFrameData {
  final int timestampMs;
  // Açıları etiketleriyle tutuyoruz: {"right_elbow": 120.5, "left_shoulder": 45.2 ...}
  final Map<String, double> angles; 

  PoseFrameData({
    required this.timestampMs,
    required this.angles,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestampMs': timestampMs,
      // Double değerleri temizlemek için 2 basamağa yuvarlıyoruz
      'angles': angles.map((key, value) => MapEntry(key, double.parse(value.toStringAsFixed(2)))),
    };
  }
}
