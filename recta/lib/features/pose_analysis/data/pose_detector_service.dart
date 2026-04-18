import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

//mlkit burada başlatılıyor /features/presentation/pages/pose_camera_page.dart 'tan
//gelen verileri buraya vereceğiz

/// Bu sınıf, Google ML Kit Pose Detection paketini projemizden izole etmek için
/// yazılmış bir sarmalayıcıdır (Wrapper/Service).
class PoseDetectorService {
  // 1. Modelin Tanımlanması
  late final PoseDetector _poseDetector;

  PoseDetectorService() {
    // 2. Modelin Başlatılması (Constructor)
    // Performans (Risk 4) için 'base' modeli seçiyoruz. 
    // 'accurate' (kesin) model de var ama mobil cihazda canlı analiz için çok ağırdır.
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream, // Canlı kamera akışı (video) için optimize edilmiş mod
    );
    _poseDetector = PoseDetector(options: options);
  }


  // 3. Görüntüyü İşleme Fonksiyonu
  /// Kameradan gelen InputImage'i alır, içinde iskelet arar ve bulduğu iskeletleri döndürür.
  Future<List<Pose>> processImage(InputImage inputImage) async {
    try {
      // Model, resmi inceler ve bulduğu insan iskeletlerinin listesini döner.
      // (Genelde tek bir insan olduğu için listenin ilk elemanına odaklanacağız)
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      return poses;
    } catch (e) {
      // Hata Yönetimi (Error Handling): Model çökmesini engellemek için
      print("İskelet tespiti sırasında hata oluştu: $e");
      return [];
    }
  }

  // 4. Bellek Yönetimi (Çok Kritik!)
  /// İşimiz bittiğinde C++ motorunu bellekten sileriz.
  void dispose() {
    _poseDetector.close();
  }
}