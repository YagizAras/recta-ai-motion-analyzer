// PoseBlock Sınıfı: Uygulamanın durum yönetiminden (State Management) sorumlu ana sınıftır.

class PoseBlock {
  // Sınıf Parametreleri
  final dynamic _repository;
  bool _isRecording = false;
  final dynamic _stopwatch;
  final List<dynamic> _collectedFrames = [];
  bool _isFrameProcessing = false;

  PoseBlock(this._repository, this._stopwatch);

  // Fonksiyonları
  void _onStartRecording() {
    // Yeni bir görüntü yakalama başlatıldığında çalışır.
    _isRecording = true;
    _collectedFrames.clear();
    // stopwatch reset logic
  }

  void _onProcessFrame(dynamic currentFrame) {
    // Kameradan gelen her görüntü karesi için tetiklenir.
    if (_isFrameProcessing) return;
    
    _isFrameProcessing = true;
    // process frame logic via repository
    _isFrameProcessing = false;
  }
}
