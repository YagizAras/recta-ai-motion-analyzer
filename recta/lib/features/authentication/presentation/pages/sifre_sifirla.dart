import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// PasswordResetScreen — "Şifremi Unuttum" akışı
///
/// Giriş yapmamış kullanıcıların e-posta adresi girerek
/// Firebase üzerinden şifre sıfırlama linki almasını sağlar.
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailSent = false;

  void _handleSendResetEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar("Lütfen geçerli bir e-posta adresi girin.", Colors.redAccent);
      return;
    }

    context.read<AuthBloc>().add(ResetPasswordEvent(email));
  }

  void _showSnackBar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color mainDark = Color(0xFF1A1B2F);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthActionSuccess) {
          setState(() => _emailSent = true);
        } else if (state is AuthActionFailure) {
          _showSnackBar(state.error, Colors.redAccent);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: mainDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _emailSent ? _buildSuccessView(neonIndigo, mainDark) : _buildEmailInputView(neonIndigo, mainDark),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ADIM 1: E-posta giriş ekranı
  // ─────────────────────────────────────────────
  Widget _buildEmailInputView(Color neonIndigo, Color mainDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "ŞİFREMİ\nUNUTTUM",
          style: TextStyle(
            color: Color(0xFF1A1B2F),
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "E-posta adresini gir, sana şifre sıfırlama linki gönderelim.",
          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 40),

        // E-posta giriş alanı
        _buildInputContainer(
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
            decoration: const InputDecoration(
              hintText: "E-posta Adresin",
              hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
              prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF536DFE)),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Gönder butonu
        SizedBox(
          width: double.infinity,
          height: 60,
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _handleSendResetEmail,
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
                        "SIFIRLAMA LİNKİ GÖNDER",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // ADIM 2: Başarılı gönderim ekranı
  // ─────────────────────────────────────────────
  Widget _buildSuccessView(Color neonIndigo, Color mainDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: neonIndigo.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_rounded, color: neonIndigo, size: 64),
        ),
        const SizedBox(height: 30),
        const Text(
          "E-POSTA\nGÖNDERİLDİ",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A1B2F),
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "\"${_emailController.text.trim()}\" adresine şifre sıfırlama linki gönderildi.\n\nE-postanı kontrol et ve linke tıklayarak yeni şifreni belirle.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600, height: 1.5),
        ),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "E-posta gelmediyse spam/gereksiz klasörünü kontrol et.",
                  style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Giriş ekranına dön butonu
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text(
              "GİRİŞ EKRANINA DÖN",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Tekrar gönder butonu
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: Text(
            "Tekrar Gönder",
            style: TextStyle(color: neonIndigo, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ],
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
}