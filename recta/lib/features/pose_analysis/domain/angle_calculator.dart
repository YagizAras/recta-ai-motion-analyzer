import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleCalculator {
  // 1. İç Açı (ML Kit objeleri ile çalışır)
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