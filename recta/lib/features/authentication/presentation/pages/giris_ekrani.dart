import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_form_bloc.dart';
import '../../../support/presentation/pages/kvkk_izin.dart';
import 'sifre_sifirla.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  void _handleAuth(bool isLogin) {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty || (!isLogin && (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen alanları doldurun.")));
      return;
    }
    
    if (isLogin) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(), 
          password: _passwordController.text.trim()
        )
      );
    } else {
      context.read<AuthBloc>().add(
        RegisterRequested(
          name: "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}", 
          email: _emailController.text.trim(), 
          password: _passwordController.text.trim()
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color mainDark = Color(0xFF1A1B2F);
    const Color bgWhite = Color(0xFFF8F9FB); 

    return BlocProvider(
      create: (context) => AuthFormBloc(),
      child: Builder(
        builder: (context) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else if (state is AuthActionFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else if (state is AuthActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is AuthRegistrationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // Switch to Login Mode
                final formBloc = context.read<AuthFormBloc>();
                if (!formBloc.state.isLogin) {
                  formBloc.add(ToggleAuthMode());
                }
              }
            },
            child: BlocBuilder<AuthFormBloc, AuthFormState>(
              builder: (context, formState) {
                final isLogin = formState.isLogin;
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
                        _buildSimpleInput("Ad", Icons.person_outline_rounded, _firstNameController, neonIndigo, inputType: TextInputType.name),
                        const Divider(height: 1, color: Colors.black12, indent: 45),
                        _buildSimpleInput("Soyad", Icons.person_outline_rounded, _lastNameController, neonIndigo, inputType: TextInputType.name),
                        const Divider(height: 1, color: Colors.black12, indent: 45),
                      ],
                      _buildSimpleInput("E-posta", Icons.email_outlined, _emailController, neonIndigo, inputType: TextInputType.emailAddress),
                      const Divider(height: 1, color: Colors.black12, indent: 45),
                      _buildSimpleInput("Şifre", Icons.lock_outline_rounded, _passwordController, neonIndigo, isPassword: true),
                    ],
                  ),
                ),

                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordResetScreen()));
                      },
                      child: const Text("Şifremi Unuttum", style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),

                if (!isLogin)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
                      child: const Text(
                        "Kayıt olarak KVKK ve Kullanım Koşullarını kabul etmiş sayılırsınız.",
                        style: TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                const SizedBox(height: 35), 

                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        
                        return GestureDetector(
                          onTap: isLoading ? null : () => _handleAuth(isLogin),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: isLoading ? mainDark.withOpacity(0.7) : mainDark,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [BoxShadow(color: mainDark.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      height: 18, width: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text(
                                      isLogin ? "GİRİŞ YAP" : "KAYDOL",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 15),
                                    ),
                            ),
                          ),
                        );
                      },
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
                      onTap: () => context.read<AuthFormBloc>().add(ToggleAuthMode()),
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
    },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleInput(String hint, IconData icon, TextEditingController controller, Color accent, {bool isPassword = false, TextInputType? inputType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
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