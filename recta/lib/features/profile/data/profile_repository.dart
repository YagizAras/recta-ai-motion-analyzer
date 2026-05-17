import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String identityNumber,
    required int age,
    required double heightCm,
    required double weightKg,
    required String injuryHistory,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");

    await _firestore.collection('UserProfiles').doc(user.uid).set({
      'UserId': user.uid,
      'FirstName': firstName,
      'LastName': lastName,
      'IdentityNumber': identityNumber,
      'Age': age,
      'HeightCm': heightCm,
      'WeightKg': weightKg,
      'InjuryHistory': injuryHistory, 
    }, SetOptions(merge: true));
  }

  Future<void> updateNotificationSettings({
    required bool pushNotify,
    required bool aiFeedback,
    required bool weeklyReport,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");

    await _firestore.collection('UserProfiles').doc(user.uid).set({
      'PushNotify': pushNotify,
      'AiFeedback': aiFeedback,
      'WeeklyReport': weeklyReport,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('UserProfiles').doc(user.uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}
