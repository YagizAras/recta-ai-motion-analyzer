import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// AnalysisResult — Backend'den gelen analiz sonucunun modeli
// ─────────────────────────────────────────────────────────────────────────────

class AnalysisResult {
  final int skor;
  final String ozet;
  final String geribildirimler;
  final String tamMetin;
  final String exerciseType;
  final int totalFrames;
  final List<String> gucluYonler;
  final List<String> zayifYonler;
  final List<String> oneriler;

  const AnalysisResult({
    required this.skor,
    required this.ozet,
    required this.geribildirimler,
    required this.tamMetin,
    required this.exerciseType,
    required this.totalFrames,
    this.gucluYonler  = const [],
    this.zayifYonler  = const [],
    this.oneriler     = const [],
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final analysis = json['analysis'] as Map<String, dynamic>? ?? {};

    List<String> _toStrList(dynamic raw) =>
        (raw as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    return AnalysisResult(
      skor: (analysis['skor'] as num?)?.toInt() ?? 0,
      ozet: analysis['ozet'] as String? ?? '',
      geribildirimler: analysis['geribildirimler'] as String? ?? '',
      tamMetin: analysis['tam_metin'] as String? ?? '',
      exerciseType: json['exercise_type'] as String? ?? '',
      totalFrames: (json['total_frames'] as num?)?.toInt() ?? 0,
      gucluYonler: _toStrList(analysis['guclu_yonler']),
      zayifYonler: _toStrList(analysis['zayif_yonler']),
      oneriler:    _toStrList(analysis['oneriler']),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BackendApiService — Recta Flask sunucusu ile HTTP iletişimi
//
// Port Discovery:
//   Backend, başlangıçta hangi portu aldığını bilemeyiz (5001 dolu olabilir).
//   Bu sınıf ilk kullanımda _hostBase:5001–5020 arasını tarar ve
//   /api/health'e yanıt veren ilk portu önbelleğe alır.
//   Sonraki tüm istekler doğrudan o porta gider (0 overhead).
// ─────────────────────────────────────────────────────────────────────────────

class BackendApiService {
  // ── Yapılandırma ──────────────────────────────────────────────────────────

  /// Mac'in LAN IP'si.
  /// --dart-define=HOST_IP=192.168.x.x ile override edilebilir.
  static const String _hostIp = String.fromEnvironment(
    'HOST_IP',
    defaultValue: '10.89.108.226',
  );

  /// Taranacak port aralığı (başlangıç dahil, bitiş hariç).
  static const int _portStart = 5010;
  static const int _portEnd   = 5031; // 5010–5030 arası 21 port

  /// Tek bir port health check için timeout (çok kısa tutulmalı).
  static const Duration _discoveryTimeout = Duration(milliseconds: 800);

  /// Analiz isteği için timeout (Gemini API yavaş olabilir).
  static const Duration _analyzeTimeout = Duration(seconds: 60);

  // ── Önbellek ──────────────────────────────────────────────────────────────

  /// Keşfedilmiş base URL. Null ise henüz discovery yapılmamış.
  String? _cachedBaseUrl;

  // ── Port Discovery ────────────────────────────────────────────────────────

  /// Aktif backend URL'ini döner.
  /// İlk çağrıda 5001-5020 arasını tarar; bulduğunu önbelleğe alır.
  Future<String> _resolveBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    developer.log(
      '🔍 Port discovery başlıyor → $_hostIp:$_portStart–${_portEnd - 1}',
      name: 'BackendApiService',
    );

    for (int port = _portStart; port < _portEnd; port++) {
      final candidate = 'http://$_hostIp:$port';
      try {
        final response = await http
            .get(Uri.parse('$candidate/api/health'))
            .timeout(_discoveryTimeout);

        if (response.statusCode == 200) {
          _cachedBaseUrl = candidate;
          developer.log(
            '✅ Backend bulundu → $candidate',
            name: 'BackendApiService',
          );
          return _cachedBaseUrl!;
        }
      } catch (_) {
        // Bu port yanıt vermedi — bir sonrakine geç
      }
    }

    // Hiçbir port yanıt vermediyse — backend kapalı olabilir
    throw Exception(
      'Backend bulunamadı!\n'
      'Lütfen şunları kontrol et:\n'
      '  1. recta_backend/start.sh çalışıyor mu?\n'
      '  2. Mac ve telefon aynı WiFi\'de mi?\n'
      '  3. IP adresi doğru mu? (şu an: $_hostIp)',
    );
  }

  /// Önbelleği sıfırlar — backend yeniden başlatıldıktan sonra çağır.
  void resetDiscovery() {
    _cachedBaseUrl = null;
    developer.log('🔄 Port önbelleği sıfırlandı.', name: 'BackendApiService');
  }

  // ── Analyze ───────────────────────────────────────────────────────────────

  /// Poz verilerini backend'e gönderir, analiz sonucunu döner.
  Future<AnalysisResult> sendPoseData(String jsonPayload) async {
    final baseUrl      = await _resolveBaseUrl();
    final analyzeUrl   = '$baseUrl/api/analyze';

    developer.log(
      '📤 Backend\'e gönderiliyor → $analyzeUrl',
      name: 'BackendApiService',
    );

    try {
      final response = await http
          .post(
            Uri.parse(analyzeUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept':       'application/json',
            },
            body: jsonPayload,
          )
          .timeout(_analyzeTimeout);

      return _handleAnalyzeResponse(response);

    } on TimeoutException {
      developer.log(
        '⏱️ Analiz isteği zaman aşımına uğradı (${_analyzeTimeout.inSeconds}s)',
        level: 1000,
        name: 'BackendApiService',
      );
      throw Exception(
        'Sunucu ${_analyzeTimeout.inSeconds} saniyede yanıt vermedi.\n'
        'Gemini API meşgul olabilir — lütfen tekrar deneyin.',
      );

    } on http.ClientException catch (e) {
      developer.log('🔌 Ağ hatası: $e', level: 1000, name: 'BackendApiService');
      // Bağlantı kopmuş olabilir — önbelleği temizle ki sonraki istek yeniden arasın
      resetDiscovery();
      throw Exception('Sunucuya ulaşılamadı. Ağ bağlantınızı kontrol edin.');

    } catch (e) {
      developer.log('❌ Beklenmeyen hata: $e', level: 1000, name: 'BackendApiService');
      rethrow;
    }
  }

  AnalysisResult _handleAnalyzeResponse(http.Response response) {
    developer.log(
      '📥 Sunucu yanıtı: HTTP ${response.statusCode}',
      name: 'BackendApiService',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final result = AnalysisResult.fromJson(body);
      developer.log(
        '✅ Analiz tamamlandı — Skor: ${result.skor} | '
        'Egzersiz: ${result.exerciseType} | '
        'Frame: ${result.totalFrames}',
        name: 'BackendApiService',
      );
      return result;
    }

    // 4xx / 5xx hata durumları
    String errorMessage = 'Sunucu hatası (HTTP ${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      errorMessage = body['error'] as String? ?? errorMessage;
    } catch (_) {
      // JSON parse edilemezse orijinal mesajı koru
    }

    developer.log(
      '⚠️ Hata yanıtı: $errorMessage',
      level: 800,
      name: 'BackendApiService',
    );
    throw Exception(errorMessage);
  }

  // ── Health Check ──────────────────────────────────────────────────────────

  /// Sunucunun ayakta olup olmadığını kontrol eder.
  /// [true] → erişilebilir, [false] → erişilemiyor.
  Future<bool> checkHealth() async {
    try {
      final baseUrl = await _resolveBaseUrl();
      final response = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        '❌ Health check başarısız: $e',
        level: 1000,
        name: 'BackendApiService',
      );
      return false;
    }
  }
}