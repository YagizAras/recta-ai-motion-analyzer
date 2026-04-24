import 'dart:async'; // TimeoutException için gerekli
import 'dart:developer' as developer; // print yerine profesyonel loglama için
import 'package:http/http.dart' as http;

class BackendApiService {
  // Not: İleride bunu doğrudan ApiConstants.analyzeEndpoint üzerinden çekeceksin.
  // Şimdilik test edebilmen için burada bırakıyorum. (Emülatör için 10.0.2.2)
  final String _apiUrl = "http://10.0.2.2:5000/api/analyze";

  Future<String> sendPoseData(String jsonPayload) async {
    try {
      developer.log("İnternete çıkılıyor, JSON Backend'e gönderiliyor...", name: 'BackendApiService');
      
      // GERÇEK HTTP İSTEĞİ
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonPayload,
      ).timeout(const Duration(seconds: 10)); // 10 saniye kalkanı eklendi

      if (response.statusCode == 200) {
        developer.log("İşlem Başarılı. Sunucu Yanıtı alındı.", name: 'BackendApiService');
        return response.body; 
      } else {
        developer.log("Sunucu Hatası: HTTP ${response.statusCode}", level: 800, name: 'BackendApiService');
        throw Exception("Sunucu Hatası: Geçersiz yanıt kodu (${response.statusCode})");
      }
      
    } on TimeoutException {
      // 10 saniye içinde sunucudan/Gemini'den cevap gelmezse buraya düşer
      developer.log("İstek zaman aşımına uğradı (10 sn).", level: 1000, name: 'NetworkError');
      throw Exception("Bağlantı zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.");
      
    } catch (e) {
      // İnternet kopukluğu, sunucunun kapalı olması gibi diğer ağ hataları
      developer.log("Ağ istisnası yakalandı: $e", level: 1000, name: 'NetworkError');
      throw Exception("Sunucuya ulaşılamadı. Bağlantınızı kontrol edin.");
    }
  }
}