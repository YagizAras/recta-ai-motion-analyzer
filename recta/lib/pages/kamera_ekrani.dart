import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  final String exerciseName;
  const CameraScreen({super.key, this.exerciseName = "Analiz"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Kamera Önizleme (Temsili Siyah Ekran)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF1A1B2F),
            child: const Center(
              child: Icon(Icons.videocam_off, color: Colors.white24, size: 50),
            ),
          ),

          // 2. Neon İskelet Çizgileri (Temsili Görsel Efekt)
          Center(
            child: Opacity(
              opacity: 0.6,
              child: CustomPaint(
                size: const Size(200, 400),
                painter: SkeletonPainter(),
              ),
            ),
          ),

          // 3. Üst Bilgi Barı
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                  child: Text(exerciseName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
                const Icon(Icons.flash_on, color: Colors.white),
              ],
            ),
          ),

          // 4. Gemini Canlı Geri Bildirim
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF536DFE).withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology, color: Colors.white, size: 30),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Gemini: 'Dizlerini biraz daha dışa doğru açarsan formun mükemmel olacak!'",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Temsili İskelet Çizimi
class SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF536DFE)..strokeWidth = 3..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    
    // Temsili bir "Squat" iskeleti
    var path = Path();
    path.moveTo(size.width / 2, 50); // Baş
    path.lineTo(size.width / 2, 150); // Gövde
    path.lineTo(50, 250); // Sol Bacak
    path.moveTo(size.width / 2, 150);
    path.lineTo(150, 250); // Sağ Bacak
    
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.width / 2, 50), 8, dotPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}