import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pose_bloc.dart';
import '../bloc/pose_state.dart';
import '../../../reports/presentation/pages/analiz_raporu.dart';

/// AnalysisLoadingScreen
/// ─────────────────────────────────────────────────────────────────
/// PoseProcessingData state'inde gösterilir.
/// PoseAnalysisSuccess geldiğinde otomatik olarak AnalysisReportScreen'e geçer.
/// PoseError geldiğinde hata gösterip geri döner.
class AnalysisLoadingScreen extends StatefulWidget {
  final String exerciseName;

  const AnalysisLoadingScreen({super.key, required this.exerciseName});

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen>
    with TickerProviderStateMixin {
  // ── Renkler ────────────────────────────────────────────────────
  static const Color _neonIndigo = Color(0xFF536DFE);
  static const Color _mainDark   = Color(0xFF1A1B2F);
  static const Color _bgLight    = Color(0xFFF8F9FB);

  // ── Büyük dönen halka ──────────────────────────────────────────
  late final AnimationController _ringCtrl;

  // ── Darbe (pulse) efekti ───────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  // ── Yazı geçiş animasyonu ──────────────────────────────────────
  late final AnimationController _textCtrl;
  late final Animation<double>   _textFade;

  // ── Parçacık animasyonu ────────────────────────────────────────
  late final AnimationController _particleCtrl;

  // ── Kayan durum metni (ipuçları) ──────────────────────────────
  final List<String> _hints = [
    "Eklem açıları hesaplanıyor...",
    "Hareket simetrisi analiz ediliyor...",
    "Vücut hizası kontrol ediliyor...",
    "Gemini AI değerlendiriyor...",
    "Performans skoru belirleniyor...",
  ];
  int _hintIndex = 0;
  late final AnimationController _hintCtrl;
  late final Animation<double>   _hintFade;

  @override
  void initState() {
    super.initState();

    // Dönen halka
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Başlık fade-in
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);

    // Parçacık
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // İpucu yaz
    _hintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..value = 1.0;
    _hintFade = CurvedAnimation(parent: _hintCtrl, curve: Curves.easeInOut);

    // Her 2.2 saniyede ipucu değiştir
    _startHintCycle();
  }

  void _startHintCycle() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) break;
      // Fade-out
      await _hintCtrl.animateTo(0.0, duration: const Duration(milliseconds: 300));
      if (!mounted) break;
      setState(() => _hintIndex = (_hintIndex + 1) % _hints.length);
      // Fade-in
      await _hintCtrl.animateTo(1.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    _textCtrl.dispose();
    _particleCtrl.dispose();
    _hintCtrl.dispose();
    super.dispose();
  }

  String get _displayName {
    switch (widget.exerciseName.toUpperCase()) {
      case 'SQUAT':             return 'SQUAT';
      case 'PUSH_UP':           return 'ŞINAV';
      case 'SHOT_FORM':         return 'BASKETBOL ŞUT FORMU';
      case 'SHOULDER_MOBILITY': return 'OMUZ MOBİLİTESİ';
      case 'LUNGE':             return 'LUNGE';
      case 'PLANK':             return 'PLANK';
      default:                  return widget.exerciseName.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _bgLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── 1. ANİMASYONLU LOGO ALANI ────────────────────
                _buildLogoSection(),

                const SizedBox(height: 56),

                // ── 2. BAŞLIK ─────────────────────────────────────
                FadeTransition(
                  opacity: _textFade,
                  child: Text(
                    "$_displayName ANALİZ EDİLİYOR",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _mainDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── 3. KAYAN İPUCU ────────────────────────────────
                FadeTransition(
                  opacity: _hintFade,
                  child: Text(
                    _hints[_hintIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF536DFE),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Yapay zeka hareket formunu,\neklem açılarını ve stabilizesini kontrol ediyor.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 56),

                // ── 4. ALT BİLGİ KARTI ────────────────────────────
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      );
  }

  // ── Logo + Halka + Parçacıklar ──────────────────────────────────
  Widget _buildLogoSection() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Parçacıklar (arka planda dönen noktalar)
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              size: const Size(200, 200),
              painter: _ParticlePainter(_particleCtrl.value, _neonIndigo),
            ),
          ),

          // Dış açık halka (sabit)
          Container(
            width: 175,
            height: 175,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _neonIndigo.withOpacity(0.08),
                width: 14,
              ),
            ),
          ),

          // Dönen neon halka
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, __) {
              return Transform.rotate(
                angle: _ringCtrl.value * 2 * pi,
                child: CustomPaint(
                  size: const Size(175, 175),
                  painter: _ArcPainter(_neonIndigo),
                ),
              );
            },
          ),

          // Logo dairesi — pulse efektiyle
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 114,
              height: 114,
              decoration: BoxDecoration(
                color: _mainDark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _neonIndigo.withOpacity(0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "RECTA",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 3.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Alt bilgi kartı ─────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.orangeAccent, size: 22),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              "Daha isabetli sonuçlar için her sette formunu korumaya özen göster.",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dönen ark boyacısı ──────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final Color color;
  _ArcPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;

    // Glow efekti
    final glowPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 1.2,
      false,
      glowPaint,
    );

    // Ana ark
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 1.2,
      false,
      paint,
    );

    // Küçük bir kuyruk (soluk)
    final tailPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + pi * 1.2,
      pi * 0.4,
      false,
      tailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Parçacık boyacısı ───────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticlePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    final rng = Random(42); // Sabit seed → aynı pozisyonlar
    for (int i = 0; i < 8; i++) {
      final angle = (rng.nextDouble() * 2 * pi) + (progress * 2 * pi * 0.4);
      final dist  = 85 + rng.nextDouble() * 15;
      final phase = rng.nextDouble();

      // Her parçacık farklı hızda blink yapar
      final opacity = ((sin((progress + phase) * 2 * pi) + 1) / 2) * 0.5;
      final radius  = 2.5 + rng.nextDouble() * 2;

      paint.color = color.withOpacity(opacity.clamp(0.05, 0.5));
      canvas.drawCircle(
        Offset(
          center.dx + cos(angle) * dist,
          center.dy + sin(angle) * dist,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.progress != progress;
}
