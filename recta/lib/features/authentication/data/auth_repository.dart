import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// AuthRepository (Firebase Data)
///
/// Firebase Authentication ve Firestore servisleri ile iletişim kurarak
/// veri kaydetme ve doğrulama işlemlerinin teknik altyapısını yürüten sınıftır.
///
/// UML Methods:
///   - login(email, password) : User
///   - register(name, email, password) : User
///   - logout() : void
///   - loginAsGuest() : User  [Ek özellik – Anonim giriş]
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // Mevcut oturumu döndürür (uygulama açılışında kontrol)
  // ─────────────────────────────────────────────
  User? get currentUser => _firebaseAuth.currentUser;

  /// Oturum durumu değişikliklerini dinler
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ─────────────────────────────────────────────
  // LOGIN – E-posta ve şifre ile giriş
  // ─────────────────────────────────────────────
  /// UML: login(email, password) : PlanlanmisUser
  ///
  /// Firebase Authentication ile e-posta/şifre doğrulaması yapar.
  /// Başarılı ise [User] döndürür, hata durumunda exception fırlatır.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Kullanıcı bulunamadı.',
        );
      }

      final user = credential.user!;
      await user.reload(); // En güncel onay durumunu çek

      if (!user.emailVerified) {
        await _firebaseAuth.signOut(); // Hemen geri at
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Lütfen giriş yapmadan önce e-posta adresinizi doğrulayın.',
        );
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'login-failed',
        message: 'Giriş başarısız: ${e.toString()}',
      );
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER – Yeni kullanıcı kaydı + Firestore profil
  // ─────────────────────────────────────────────
  /// UML: register(name, email, password) : PlanlanmisUser
  ///
  /// Firebase Authentication ile yeni hesap oluşturur.
  /// Ardından kullanıcının temel profil bilgilerini Firestore'daki
  /// `users` koleksiyonuna kaydeder.
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Kullanıcı oluşturulamadı.',
        );
      }

      // Firebase Auth profiline displayName ekle
      await user.updateDisplayName(name.trim());
      
      // E-posta doğrulama linki gönder
      _firebaseAuth.setLanguageCode('tr');
      await user.sendEmailVerification();

      // Firestore'a kullanıcı profili kaydet
      await _saveUserProfile(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
      );

      // reload sonrası güncel user'ı al (Bunu yapabiliriz, ama zaten çıkış yapacağız)
      await user.reload();
      final finalUser = _firebaseAuth.currentUser!;

      // Otomatik çıkış yap (onaylamadan girmesini engellemek için)
      await _firebaseAuth.signOut();

      return finalUser;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'register-failed',
        message: 'Kayıt başarısız: ${e.toString()}',
      );
    }
  }

  // ─────────────────────────────────────────────
  // LOGIN AS GUEST – Anonim giriş (Ek özellik)
  // ─────────────────────────────────────────────
  /// Anonim (misafir) oturum açar.
  /// Misafir kullanıcılar HistoryPage'e erişemez.
  Future<User> loginAsGuest() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Misafir girişi başarısız.',
        );
      }

      return credential.user!;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'guest-login-failed',
        message: 'Misafir girişi başarısız: ${e.toString()}',
      );
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT – Oturumu kapat
  // ─────────────────────────────────────────────
  /// UML: logout() : void
  ///
  /// Mevcut oturumu (kayıtlı veya anonim) kapatır.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // ─────────────────────────────────────────────
  // SEND PASSWORD RESET EMAIL – Şifre sıfırlama e-postası gönder
  // ─────────────────────────────────────────────
  /// Kullanıcının e-posta adresine Firebase üzerinden
  /// şifre sıfırlama linki gönderir.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _firebaseAuth.setLanguageCode('tr');
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'password-reset-failed',
        message: 'Şifre sıfırlama e-postası gönderilemedi: ${e.toString()}',
      );
    }
  }

  // ─────────────────────────────────────────────
  // SEND EMAIL VERIFICATION – E-posta doğrulama gönder
  // ─────────────────────────────────────────────
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'email-verification-failed',
        message: 'E-posta doğrulama linki gönderilemedi: ${e.toString()}',
      );
    }
  }

  // ─────────────────────────────────────────────
  // IS EMAIL VERIFIED – E-posta doğrulanmış mı?
  // ─────────────────────────────────────────────
  Future<bool> isEmailVerified() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  // ─────────────────────────────────────────────
  // CHANGE PASSWORD – Giriş yapmış kullanıcı şifre değiştirme
  // ─────────────────────────────────────────────
  /// Önce mevcut şifre ile yeniden doğrulama (reauthenticate) yapar,
  /// ardından yeni şifreyi Firebase Auth'a kaydeder.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'Oturum açmış kullanıcı bulunamadı.',
        );
      }

      // Önce mevcut şifre ile yeniden doğrulama
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Yeni şifreyi kaydet
      await user.updatePassword(newPassword);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'change-password-failed',
        message: 'Şifre değiştirme başarısız: ${e.toString()}',
      );
    }
  }

  // ─────────────────────────────────────────────
  // Firestore'dan kullanıcı adını getir
  // ─────────────────────────────────────────────
  /// Firestore `users` koleksiyonundan kullanıcı adını çeker.
  /// displayName boşsa Firestore'dan okur; o da yoksa 'Kullanıcı' döndürür.
  Future<String> fetchUserName(String uid) async {
    try {
      // Önce Firebase Auth displayName kontrolü
      final user = _firebaseAuth.currentUser;
      if (user != null &&
          user.displayName != null &&
          user.displayName!.isNotEmpty) {
        return user.displayName!;
      }

      // Firestore'dan oku
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['name'] as String? ?? 'Kullanıcı';
      }

      return 'Kullanıcı';
    } catch (_) {
      return 'Kullanıcı';
    }
  }

  // ─────────────────────────────────────────────
  // PRIVATE – Firestore'a profil kaydet
  // ─────────────────────────────────────────────
  Future<void> _saveUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'isGuest': false,
    }, SetOptions(merge: true));
  }
}
