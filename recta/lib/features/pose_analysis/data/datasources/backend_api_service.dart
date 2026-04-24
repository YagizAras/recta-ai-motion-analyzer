import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendApiService {
  // Senin kendi sunucunun adresi (Gerçek adresi buraya yazacaksın)
  // Eğer Android emülatörden kendi bilgisayarına (localhost) istek atacaksın adres: http://10.0.2.2:3000/api/analyze 
  final String _apiUrl = "https://senin-backend-url.com/api/analyze-pose";

  Future<String> sendPoseData(String jsonPayload) async {
    try {
      print("İnternete çıkılıyor, JSON Backend'e gönderiliyor...");
      
      // TODO: Backend'in hazır olduğunda aşağıdaki mock kodunu silip gerçek isteği aç.
      
      /* GERÇEK HTTP İSTEĞİ (Sunucu hazır olunca bu yorumu kaldır)
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        // Sunucundan dönen cevabı (Gemini'nin yorumunu) döndür
        return response.body; 
      } else {
        throw Exception("Sunucu Hatası: ${response.statusCode}");
      }
      */

      // SAHTE (MOCK) YANIT - Geliştirme aşaması için
      await Future.delayed(const Duration(seconds: 2)); 
      return "Gemini Analizi: Hareket formu başarılı, dirsek açısı stabil."; 

    } catch (e) {
      throw Exception("Sunucuya veri gönderilirken hata oluştu: $e");
    }
  }
}