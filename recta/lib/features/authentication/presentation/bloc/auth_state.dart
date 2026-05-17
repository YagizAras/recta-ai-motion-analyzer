import 'package:equatable/equatable.dart';

/// AuthBloc State sınıfları
///
/// AuthSuccess durumu `isGuest` bayrağı içerir:
///   - isGuest == false → Kayıtlı kullanıcı, tam erişim
///   - isGuest == true  → Misafir kullanıcı, HistoryPage erişimi yok
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Başlangıç durumu – oturum kontrol ediliyor
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Yükleniyor (giriş, kayıt veya çıkış işlemi devam ediyor)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Başarılı oturum açma
///
/// [userName] : Kullanıcının adı (UI'da gösterilmek üzere)
/// [uid]      : Firebase kullanıcı ID'si
/// [isGuest]  : Misafir mi yoksa kayıtlı kullanıcı mı?
class AuthSuccess extends AuthState {
  final String userName;
  final String uid;
  final bool isGuest;

  const AuthSuccess({
    required this.userName,
    required this.uid,
    this.isGuest = false,
  });

  @override
  List<Object?> get props => [userName, uid, isGuest];
}

/// Oturum kapatıldı / Kullanıcı giriş yapmamış
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Hata durumu
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Yeni Kayıt Başarılı (Doğrulama Bekleniyor)
class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Şifre sıfırlama e-postası başarıyla gönderildi
class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}

/// Şifre başarıyla değiştirildi
class PasswordChangeSuccess extends AuthState {
  const PasswordChangeSuccess();
}

/// Yeni: İşlem Başarılı
class AuthActionSuccess extends AuthState {
  final String message;

  const AuthActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Yeni: İşlem Başarısız
class AuthActionFailure extends AuthState {
  final String error;

  const AuthActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
