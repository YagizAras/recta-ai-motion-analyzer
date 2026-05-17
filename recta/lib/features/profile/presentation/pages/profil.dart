import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

import 'profil_duzenle.dart';
import 'bildirim_tercihleri.dart';
import 'güvenlikvesifre.dart';
import '../../../support/presentation/pages/yardim_merkezi.dart';
import '../../../support/presentation/pages/uyg_hakkinda.dart';
import '../../../support/presentation/pages/kvkk_izin.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    const Color bgLight = Color(0xFFF8F9FB);

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        backgroundColor: bgLight,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // ÜST GRADYAN ALAN VE KULLANICI BİLGİSİ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1B2F), Color(0xFF2D2E4A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String userName = "KULLANICI";
                    if (state is AuthSuccess) {
                      userName = state.userName.toUpperCase();
                    }
                    
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Text("PROFİL", 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white12,
                                child: Icon(Icons.person, size: 60, color: Colors.white),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: neonIndigo, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(userName, 
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, profileState) {
                            final subtitle = profileState.injuryHistory.isNotEmpty 
                                ? profileState.injuryHistory 
                                : "Profili düzenle";
                            return Text(subtitle, 
                              style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500));
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // AYARLAR LİSTESİ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildSectionTitle("HESAP AYARLARI"),
                    const SizedBox(height: 15),
                    _buildProfileMenuItem(
                      context,
                      Icons.person_outline_rounded, 
                      "Kişisel Bilgiler", 
                      neonIndigo,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                    ),
                    _buildProfileMenuItem(
                      context, 
                      Icons.notifications_none_rounded, 
                      "Bildirim Tercihleri", 
                      neonIndigo,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
                    ),
                    _buildProfileMenuItem(
                      context, 
                      Icons.security_rounded, 
                      "Güvenlik ve Şifre", 
                      neonIndigo,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen())),
                    ),

                    const SizedBox(height: 30),

                    _buildSectionTitle("DESTEK VE HUKUKİ"),
                    const SizedBox(height: 15),
                    _buildProfileMenuItem(
                      context, 
                      Icons.help_outline_rounded, 
                      "Yardım Merkezi", 
                      neonIndigo,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen())),
                    ),
                    _buildProfileMenuItem(
                      context, 
                      Icons.privacy_tip_outlined, 
                      "Gizlilik ve KVKK",
                      neonIndigo,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
                    ),
                    _buildProfileMenuItem(
                      context, 
                      Icons.info_outline_rounded, 
                      "Uygulama Hakkında", 
                      neonIndigo,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen())),
                    ),

                    const SizedBox(height: 30),
                    
                    // ÇIKIŞ BUTONU
                    _buildProfileMenuItem(
                      context, 
                      Icons.logout_rounded, 
                      "Çıkış Yap", 
                      Colors.redAccent, 
                      isLast: true,
                      onTap: () {
                        context.read<AuthBloc>().add(const LogoutRequested());
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, IconData icon, String title, Color color, {bool isLast = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, 
          style: TextStyle(
            color: isLast ? color : const Color(0xFF1A1A1A), 
            fontWeight: FontWeight.w800, 
            fontSize: 15
          )),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black12, size: 20),
      ),
    );
  }
}