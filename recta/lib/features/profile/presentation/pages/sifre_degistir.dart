import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

/// ChangePasswordScreen — Giriş yapmış kullanıcı için şifre değiştirme
///
/// Mevcut şifreyi doğrulayarak yeni şifre belirleme akışı.
/// Firebase Auth reauthenticate + updatePassword kullanır.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  // Şifre kuralları
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;

  void _checkPassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber;

  void _handleChangePassword() {
    // Mevcut şifre kontrolü
    if (_currentPasswordController.text.trim().isEmpty) {
      _showSnackBar("Lütfen mevcut şifrenizi girin.", Colors.redAccent);
      return;
    }

    // Yeni şifre validation
    if (!_isPasswordValid) {
      _showSnackBar("Lütfen şifre kurallarına uyun.", Colors.redAccent);
      return;
    }

    // Şifre eşleşme kontrolü
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar("Yeni şifreler eşleşmiyor.", Colors.redAccent);
      return;
    }

    // Mevcut şifre ile aynı olma kontrolü
    if (_currentPasswordController.text == _newPasswordController.text) {
      _showSnackBar("Yeni şifre mevcut şifrenizle aynı olamaz.", Colors.redAccent);
      return;
    }

    context.read<AuthBloc>().add(
      PasswordChangeRequested(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      ),
    );
  }

  void _showSnackBar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color mainDark = Color(0xFF1A1B2F);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordChangeSuccess) {
          _showSnackBar("Şifreniz başarıyla güncellendi!", neonIndigo);
          Navigator.pop(context);
        } else if (state is AuthFailure) {
          _showSnackBar(state.message, Colors.redAccent);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "ŞİFRE DEĞİŞTİR",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Güvenliğin için mevcut şifreni doğrula ve yeni şifreni belirle.",
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),

              // ─── MEVCUT ŞİFRE ───
              const Text(
                "MEVCUT ŞİFRE",
                style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),
              _buildInputContainer(
                child: TextField(
                  controller: _currentPasswordController,
                  obscureText: !_isCurrentPasswordVisible,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Mevcut Şifre",
                    hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: neonIndigo),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black12,
                      ),
                      onPressed: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ─── YENİ ŞİFRE ───
              const Text(
                "YENİ ŞİFRE",
                style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),
              _buildInputContainer(
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  onChanged: _checkPassword,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Yeni Şifre",
                    hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_reset_rounded, color: neonIndigo),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black12,
                      ),
                      onPressed: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildInputContainer(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: "Yeni Şifreyi Onayla",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                    prefixIcon: Icon(Icons.check_circle_outline_rounded, color: neonIndigo),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ─── ŞİFRE KRİTERLERİ ───
              const Text(
                "ŞİFRE GEREKSİNİMLERİ",
                style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              _buildValidationRow("En az 8 karakter", _hasMinLength),
              _buildValidationRow("En az 1 büyük harf (A-Z)", _hasUppercase),
              _buildValidationRow("En az 1 küçük harf (a-z)", _hasLowercase),
              _buildValidationRow("En az 1 rakam (0-9)", _hasNumber),

              const SizedBox(height: 40),

              // ─── GÜNCELLE BUTONU ───
              SizedBox(
                width: double.infinity,
                height: 60,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainDark,
                        disabledBackgroundColor: mainDark.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "ŞİFREYİ GÜNCELLE",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                            ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Ortak Input Tasarımı
  // ─────────────────────────────────────────────
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: child,
    );
  }

  // ─────────────────────────────────────────────
  // Kriter Satırı Tasarımı
  // ─────────────────────────────────────────────
  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 10),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isValid ? Colors.greenAccent.shade700 : Colors.black45,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.black : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
