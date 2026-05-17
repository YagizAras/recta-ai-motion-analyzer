import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc (Planlanan BLoC)
///
/// Arayüzden gelen oturum açma veya kayıt olma gibi istekleri (event)
/// dinleyerek uygulamanın durumunu (state) güncelleyen iş mantığı katmanıdır.
///
/// UML Handler'ları:
///   - _onLoginRequested(event, emit)
///   - _onRegisterRequested(event, emit)
///   - _onLogoutRequested(event, emit)
///   - _onGuestLoginRequested(event, emit)  [Ek]
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;

  AuthBloc({required AuthRepository authRepo})
      : _authRepo = authRepo,
        super(const AuthInitial()) {
    // UML'deki event handler eşleştirmeleri
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GuestLoginRequested>(_onGuestLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordChangeRequested>(_onPasswordChangeRequested);
    on<ResetPasswordEvent>(_onResetPasswordEvent);
    on<SendEmailVerificationEvent>(_onSendEmailVerificationEvent);
  }

  // ─────────────────────────────────────────────
  // APP STARTED – Mevcut oturum kontrolü
  // ─────────────────────────────────────────────
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    developer.log('AppStarted: Mevcut oturum kontrol ediliyor...', name: 'AuthBloc');

    final user = _authRepo.currentUser;

    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    // Anonim kullanıcı kontrolü
    final isGuest = user.isAnonymous;

    if (isGuest) {
      emit(AuthSuccess(
        userName: 'Misafir',
        uid: user.uid,
        isGuest: true,
      ));
    } else {
      // Firestore'dan kullanıcı adını getir
      final userName = await _authRepo.fetchUserName(user.uid);
      emit(AuthSuccess(
        userName: userName,
        uid: user.uid,
        isGuest: false,
      ));
    }

    developer.log(
      'AppStarted: Oturum bulundu → ${isGuest ? "Misafir" : user.email}',
      name: 'AuthBloc',
    );
  }

  // ─────────────────────────────────────────────
  // LOGIN – E-posta ile giriş
  // ─────────────────────────────────────────────
  /// UML: _onLoginRequested(event, emit)
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    developer.log('LoginRequested: ${event.email}', name: 'AuthBloc');

    try {
      final user = await _authRepo.login(
        email: event.email,
        password: event.password,
      );

      final userName = await _authRepo.fetchUserName(user.uid);

      emit(AuthSuccess(
        userName: userName,
        uid: user.uid,
        isGuest: false,
      ));

      developer.log('LoginRequested: Başarılı → $userName', name: 'AuthBloc');
    } catch (e) {
      developer.log('LoginRequested: Hata → $e', name: 'AuthBloc', level: 900);
      emit(AuthFailure(_mapFirebaseError(e)));
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER – Yeni kullanıcı kaydı
  // ─────────────────────────────────────────────
  /// UML: _onRegisterRequested(event, emit)
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    developer.log('RegisterRequested: ${event.email}', name: 'AuthBloc');

    try {
      final user = await _authRepo.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      emit(const AuthRegistrationSuccess(
        'Kayıt başarılı! Giriş yapabilmek için lütfen e-posta adresinize gönderilen bağlantıya tıklayarak hesabınızı doğrulayın.',
      ));

      developer.log('RegisterRequested: Başarılı → ${event.name}', name: 'AuthBloc');
    } catch (e) {
      developer.log('RegisterRequested: Hata → $e', name: 'AuthBloc', level: 900);
      emit(AuthFailure(_mapFirebaseError(e)));
    }
  }

  // ─────────────────────────────────────────────
  // GUEST LOGIN – Anonim giriş
  // ─────────────────────────────────────────────
  Future<void> _onGuestLoginRequested(
    GuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    developer.log('GuestLoginRequested', name: 'AuthBloc');

    try {
      final user = await _authRepo.loginAsGuest();

      emit(AuthSuccess(
        userName: 'Misafir',
        uid: user.uid,
        isGuest: true,
      ));

      developer.log('GuestLoginRequested: Başarılı → ${user.uid}', name: 'AuthBloc');
    } catch (e) {
      developer.log('GuestLoginRequested: Hata → $e', name: 'AuthBloc', level: 900);
      emit(AuthFailure(_mapFirebaseError(e)));
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT – Oturumu kapat
  // ─────────────────────────────────────────────
  /// UML: _onLogoutRequested(event, emit)
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    developer.log('LogoutRequested', name: 'AuthBloc');

    try {
      await _authRepo.logout();
      emit(const AuthUnauthenticated());
      developer.log('LogoutRequested: Başarılı', name: 'AuthBloc');
    } catch (e) {
      developer.log('LogoutRequested: Hata → $e', name: 'AuthBloc', level: 900);
      emit(AuthFailure(_mapFirebaseError(e)));
    }
  }

  // ─────────────────────────────────────────────
  // PASSWORD RESET – Şifre sıfırlama e-postası gönder
  // ─────────────────────────────────────────────
  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    developer.log('PasswordResetRequested: ${event.email}', name: 'AuthBloc');

    try {
      await _authRepo.sendPasswordResetEmail(event.email);
      emit(const PasswordResetEmailSent());
      developer.log('PasswordResetRequested: E-posta gönderildi', name: 'AuthBloc');
    } catch (e) {
      developer.log('PasswordResetRequested: Hata → $e', name: 'AuthBloc', level: 900);
      emit(AuthFailure(_mapFirebaseError(e)));
    }
  }

  // ─────────────────────────────────────────────
  // RESET PASSWORD EVENT – Yeni Şifre sıfırlama (Dialog)
  // ─────────────────────────────────────────────
  Future<void> _onResetPasswordEvent(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    developer.log('ResetPasswordEvent: ${event.email}', name: 'AuthBloc');

    try {
      await _authRepo.sendPasswordResetEmail(event.email);
      emit(const AuthActionSuccess('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'));
      developer.log('ResetPasswordEvent: Başarılı', name: 'AuthBloc');
    } catch (e) {
      developer.log('ResetPasswordEvent: Hata → $e', name: 'AuthBloc', level: 900);
      emit(AuthActionFailure(_mapFirebaseError(e)));
    }
  }

  // ─────────────────────────────────────────────
  // SEND EMAIL VERIFICATION – E-posta doğrulama linki
  // ─────────────────────────────────────────────
  Future<void> _onSendEmailVerificationEvent(
    SendEmailVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    developer.log('SendEmailVerificationEvent', name: 'AuthBloc');

    try {
      await _authRepo.sendEmailVerification();
      emit(const AuthActionSuccess('Doğrulama bağlantısı e-posta adresinize gönderildi.'));
      developer.log('SendEmailVerificationEvent: Başarılı', name: 'AuthBloc');
    } catch (e) {
      developer.log('SendEmailVerificationEvent: Hata → $e', name: 'AuthBloc', level: 900);
      emit(AuthActionFailure(_mapFirebaseError(e)));
    }
  }

  // ─────────────────────────────────────────────
  // PASSWORD CHANGE – Giriş yapmış kullanıcı şifre değiştirme
  // ─────────────────────────────────────────────
  Future<void> _onPasswordChangeRequested(
    PasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    developer.log('PasswordChangeRequested', name: 'AuthBloc');

    try {
      await _authRepo.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(const PasswordChangeSuccess());
      developer.log('PasswordChangeRequested: Başarılı', name: 'AuthBloc');
    } catch (e) {
      developer.log('PasswordChangeRequested: Hata → $e', name: 'AuthBloc', level: 900);
      emit(AuthFailure(_mapFirebaseError(e)));
    }
  }

  // ─────────────────────────────────────────────
  // Firebase hata mesajlarını Türkçe'ye çevir
  // ─────────────────────────────────────────────
  String _mapFirebaseError(dynamic error) {
    if (error is! Exception) {
      return 'Bilinmeyen bir hata oluştu.';
    }

    final message = error.toString().toLowerCase();

    if (message.contains('user-not-found')) {
      return 'Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı.';
    } else if (message.contains('email-not-verified')) {
      return 'Lütfen giriş yapmadan önce e-posta adresinizi doğrulayın.';
    } else if (message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'E-posta veya şifre hatalı.';
    } else if (message.contains('email-already-in-use')) {
      return 'Bu e-posta adresi zaten kullanımda.';
    } else if (message.contains('weak-password')) {
      return 'Şifre çok zayıf. En az 6 karakter kullanın.';
    } else if (message.contains('invalid-email')) {
      return 'Geçersiz e-posta adresi.';
    } else if (message.contains('too-many-requests')) {
      return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
    } else if (message.contains('operation-not-allowed')) {
      return 'Bu giriş yöntemi devre dışı. Lütfen yöneticiyle iletişime geçin.';
    } else if (message.contains('configuration-not-found')) {
      return 'Firebase Email/Şifre girişi kapalı! Lütfen Firebase Console -> Authentication kısmından açın.';
    } else if (message.contains('requires-recent-login')) {
      return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
    }

    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
