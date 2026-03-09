import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleCalculator {
  
  static double getAngle(PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
    // 1. Ters Trigonometri (atan2) kullanarak radyan cinsinden açıyı hesaplıyoruz
    double result = math.atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
                    math.atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x);

    // 2. Radyanı Dereceye çeviriyoruz (pi = 180 derece)
    result = result * (180.0 / math.pi);

    // 3. Açıyı mutlak değere (pozitif) çeviriyoruz
    result = result.abs();

    // 4. İnsan vücudundaki bir eklem açısı 180 dereceden büyük olamaz. 
    // Eğer iç açı yerine dış açıyı bulduysak, onu 360'tan çıkararak iç açıyı elde ediyoruz.
    if (result > 180.0) {
      result = 360.0 - result;
    }

    return result;
  }
}