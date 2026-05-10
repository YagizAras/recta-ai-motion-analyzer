import 'package:flutter/material.dart';
import 'istatistik.dart'; 
import 'kvkk_izin.dart'; 
import 'sifre_sifirla.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; 
  bool kvkkApproved = false; 

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleAuth() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen geçerli bir e-posta adresi girin.")),
      );
      return;
    }

    if (!isLogin && password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Şifreniz en az 8 karakterden oluşmalıdır."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    
    if (!isLogin && !kvkkApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen KVKK metnini onaylayın.")),
      );
      return;
    }

    // YENİ AKIŞ: Kayıt sonrası Giriş ekranına yönlendirme
    if (isLogin) {
      // Giriş yapılıyorsa direkt ana sayfaya git
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => StatisticsScreen(
            userName: name.isEmpty ? "DEĞERLİ KULLANICIMIZ" : name,
            userEmail: email,
          ),
        ),
      );
    } else {
      // Kayıt olunuyorsa giriş moduna at ve bilgilendir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kaydınız başarıyla oluşturuldu! Lütfen şimdi giriş yapın."),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        isLogin = true; // Kaydol'dan Giriş Yap moduna geçiş
      });
      _passwordController.clear(); // Güvenlik için şifreyi temizle
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color mainDark = Color(0xFF1A1B2F);
    const Color bgWhite = Color(0xFFF8F9FB); 

    return Scaffold(
      backgroundColor: bgWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 100), // Logonun aşağı kaydırma payı
              
              Center(
                child: Container(
                  width: 160, // Logonun büyük boyutu
                  height: 160, 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: neonIndigo.withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/recta_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 50), 
              Text(
                isLogin ? "HOŞ GELDİN" : "HESABINI OLUŞTUR",
                style: const TextStyle(
                  color: mainDark, 
                  fontSize: 24, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.5
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    if (!isLogin) ...[
                      _buildSimpleInput("Ad Soyad", Icons.person_outline, _nameController, neonIndigo),
                      const Divider(height: 1, color: Colors.black12),
                    ],
                    _buildSimpleInput("E-posta Adresi", Icons.email_outlined, _emailController, neonIndigo),
                    const Divider(height: 1, color: Colors.black12),
                    _buildSimpleInput("Şifre", Icons.lock_outline_rounded, _passwordController, neonIndigo, isPassword: true),
                  ],
                ),
              ),

              if (isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PasswordResetScreen()),
                      );
                    },
                    child: const Text(
                      "Şifremi Unuttum",
                      style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              if (!isLogin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Checkbox(
                        value: kvkkApproved,
                        activeColor: neonIndigo,
                        onChanged: (val) => setState(() => kvkkApproved = val!),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                          },
                          child: const Text(
                            "KVKK Metnini ve kullanım koşullarını kabul ediyorum.",
                            style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(
                    isLogin ? "GİRİŞ YAP" : "KAYDOL",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 45),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? "Henüz üye değil misin? " : "Zaten üye misiniz? ", 
                    style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w700)
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? "Kaydol" : "Giriş Yap",
                      style: const TextStyle(color: neonIndigo, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleInput(String hint, IconData icon, TextEditingController controller, Color accent, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.text : (hint.contains("E-posta") ? TextInputType.emailAddress : TextInputType.text),
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1B2F)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 14, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: accent, size: 22),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 22), 
      ),
    );
  }
}