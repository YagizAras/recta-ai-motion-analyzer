import 'package:equatable/equatable.dart';

/// AuthBloc Event sınıfları
///
/// UML'deki handler'lara karşılık gelen event'ler:
///   - LoginRequested      → _onLoginRequested(event, emit)
///   - RegisterRequested   → _onRegisterRequested(event, emit)
///   - LogoutRequested     → _onLogoutRequested(event, emit)
///   - GuestLoginRequested → [Ek] _onGuestLoginRequested(event, emit)
///   - AppStarted          → Uygulama açılışında mevcut oturumu kontrol eder
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Uygulama açılışında mevcut oturum kontrolü
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// E-posta ve şifre ile giriş isteği
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Yeni kullanıcı kayıt isteği
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Misafir (anonim) giriş isteği – UML'e ek özellik
class GuestLoginRequested extends AuthEvent {
  const GuestLoginRequested();
}

/// Oturumu kapatma isteği
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Şifre sıfırlama e-postası gönderme isteği (giriş yapmamış kullanıcı)
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Şifre değiştirme isteği (giriş yapmış kullanıcı)
class PasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const PasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Yeni: Şifre sıfırlama (Dialog üzerinden)
class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Yeni: E-posta doğrulama linki gönder
class SendEmailVerificationEvent extends AuthEvent {
  const SendEmailVerificationEvent();
}
