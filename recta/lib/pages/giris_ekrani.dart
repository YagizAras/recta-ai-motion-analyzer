import 'package:flutter/material.dart';
import 'istatistik.dart'; 
import 'kvkk_izin.dart'; 

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

  void _handleAuth() {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen alanları doldurun.")));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
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
              const SizedBox(height: 70), 
              Center(
                child: Container(
                  padding: const EdgeInsets.all(25), 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40), 
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Image.asset('assets/recta_logo.png', height: 90, fit: BoxFit.contain), 
                ),
              ),

              const SizedBox(height: 60), 
              
              Text(
                isLogin ? "Oturum Aç" : "Kayıt Ol",
                style: const TextStyle(color: mainDark, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                "Devam etmek için bilgilerinizi girin.",
                style: TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 50), 

              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    if (!isLogin) ...[
                      _buildSimpleInput("Ad Soyad", Icons.person_outline_rounded, _nameController, neonIndigo),
                      const Divider(height: 1, color: Colors.black12, indent: 45),
                    ],
                    _buildSimpleInput("E-posta", Icons.email_outlined, _emailController, neonIndigo),
                    const Divider(height: 1, color: Colors.black12, indent: 45),
                    _buildSimpleInput("Şifre", Icons.lock_outline_rounded, _passwordController, neonIndigo, isPassword: true),
                  ],
                ),
              ),

              if (isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Şifremi Unuttum", style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),

              const SizedBox(height: 35), 

              // *** KIRPILMIŞ VE BOYUTU AYARLANMIŞ BUTON ***
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65, // Ekranın %65'i kadar (sağdan soldan kırpıldı)
                  child: GestureDetector(
                    onTap: _handleAuth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18), // Dikeyde biraz daha zarif
                      decoration: BoxDecoration(
                        color: mainDark,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: mainDark.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Center(
                        child: Text(
                          isLogin ? "GİRİŞ YAP" : "KAYDOL",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 15),
                        ),
                      ),
                    ),
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