import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  // Kontrol değişkenleri
  bool isMailSent = false; 
  bool isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Şifre kuralları kontrolü
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;

  void _checkPassword(String value) {
    setState(() {
      hasMinLength = value.length >= 8;
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasLowercase = value.contains(RegExp(r'[a-z]'));
    });
  }

  void _handleAction() {
    if (!isMailSent) {
      // E-posta doğrulama simülasyonu
      if (_emailController.text.contains('@')) {
        setState(() => isMailSent = true);
      } else {
        _showSnackBar("Lütfen geçerli bir e-posta girin.", Colors.redAccent);
      }
    } else {
      // Şifre kayıt simülasyonu
      if (hasMinLength && hasUppercase && hasLowercase) {
        if (_newPasswordController.text == _confirmPasswordController.text) {
          _showSnackBar("Şifreniz başarıyla güncellendi!", const Color(0xFF536DFE));
          Navigator.pop(context);
        } else {
          _showSnackBar("Şifreler eşleşmiyor.", Colors.redAccent);
        }
      } else {
        _showSnackBar("Lütfen şifre kurallarına uyun.", Colors.redAccent);
      }
    }
  }

  void _showSnackBar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg));
  }

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color mainDark = Color(0xFF1A1B2F);

    return Scaffold(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              isMailSent ? "YENİ ŞİFRE\nBELİRLE" : "ŞİFREMİ\nUNUTTUM",
              style: const TextStyle(color: mainDark, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: 1.2),
            ),
            const SizedBox(height: 15),
            Text(
              isMailSent 
                ? "Güçlü bir şifre seçerek hesabını güvenceye al." 
                : "E-posta adresini gir, sana özel şifre yenileme adımına geçelim.",
              style: const TextStyle(color: Colors.black38, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            
            // E-POSTA ALANI (Sadece ilk adımda görünür)
            if (!isMailSent)
              _buildInputContainer(
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: "E-posta Adresin",
                    hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                    prefixIcon: Icon(Icons.email_outlined, color: neonIndigo),
                    border: InputBorder.none,
                  ),
                ),
              ),

            // ŞİFRE BELİRLEME ALANLARI (E-posta sonrası görünür)
            if (isMailSent) ...[
              _buildInputContainer(
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: !isPasswordVisible,
                  onChanged: _checkPassword,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: "Yeni Şifre",
                    hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: neonIndigo),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black12),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildInputContainer(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: !isPasswordVisible,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: "Şifreyi Onayla",
                    hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                    prefixIcon: Icon(Icons.check_circle_outline_rounded, color: neonIndigo),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // ŞİFRE KRİTERLERİ UI
              _buildValidationRow("En az 8 karakter", hasMinLength),
              _buildValidationRow("En az 1 büyük harf", hasUppercase),
              _buildValidationRow("En az 1 küçük harf", hasLowercase),
            ],
            
            const SizedBox(height: 40),
            
            // ANA BUTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _handleAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  isMailSent ? "ŞİFREYİ GÜNCELLE" : "DEVAM ET",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ortak Input Tasarımı
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

  // Kriter Satırı Tasarımı
  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 10),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, 
               color: isValid ? Colors.greenAccent.shade700 : Colors.black12, size: 16),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: isValid ? Colors.black87 : Colors.black26, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}