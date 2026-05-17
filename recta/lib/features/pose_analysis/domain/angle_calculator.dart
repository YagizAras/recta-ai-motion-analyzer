import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleCalculator {
  // 1. 3D İç Açı (Dot Product Formülü ile - x, y, z Eksenleri)
  static double get3DAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    // Vektör u (mid -> first)
    double ux = first.x - mid.x;
    double uy = first.y - mid.y;
    double uz = first.z - mid.z;
    
    // Vektör v (mid -> last)
    double vx = last.x - mid.x;
    double vy = last.y - mid.y;
    double vz = last.z - mid.z;
    
    // Nokta Çarpımı (Dot Product)
    double dotProduct = (ux * vx) + (uy * vy) + (uz * vz);
    
    // Vektör Büyüklükleri (Magnitudes)
    double magU = math.sqrt(math.pow(ux, 2) + math.pow(uy, 2) + math.pow(uz, 2));
    double magV = math.sqrt(math.pow(vx, 2) + math.pow(vy, 2) + math.pow(vz, 2));
    
    // Sıfıra bölme hatasını önle
    if (magU * magV == 0) return 0.0;
    
    // Kosinüs değeri [-1, 1] aralığında sınırlandırılmalı (hassasiyet hataları için)
    double cosTheta = dotProduct / (magU * magV);
    cosTheta = cosTheta.clamp(-1.0, 1.0);
    
    // Açıyı radyan cinsinden hesapla ve dereceye çevir
    double angle = math.acos(cosTheta) * (180.0 / math.pi);
    
    return angle;
  }

  // 2. 2D İç Açı (Eski ML Kit objeleri ile çalışır - Opsiyonel olarak bırakıldı)
  static double getAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    double result = math.atan2(last.y - mid.y, last.x - mid.x) -
                    math.atan2(first.y - mid.y, first.x - mid.x);
    result = (result * 180.0 / math.pi).abs();
    if (result > 180.0) result = 360.0 - result;
    return result;
  }

  // 2. Dikey Açı (Artık ML Kit objesi değil, doğrudan x ve y koordinatlarını istiyoruz)
  // Bu sayede hem 'nose' objesini hem de 'shoulderMidX' sayısını buraya verebileceğiz.
  static double getAngleFromVertical(double x1, double y1, double x2, double y2) {
    double angle = math.atan2(x2 - x1, y2 - y1);
    return (angle * 180.0 / math.pi).abs();
  }
}