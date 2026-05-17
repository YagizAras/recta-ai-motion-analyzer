import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import 'sifre_degistir.dart';

/// SecurityScreen — Güvenlik ve Şifre Sayfası
///
/// Giriş yapmış kullanıcının güvenlik ayarlarını yönettiği sayfa.
/// - Şifre Değiştir: Yeni şifre belirleme ekranına yönlendirir
/// - Aktif Cihazlar: Mevcut oturum bilgisini gösterir
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "GÜVENLİK VE ŞİFRE",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "HESAP GÜVENLİĞİ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 15),

            // ─── ŞİFRE DEĞİŞTİR (FONKSİYONEL) ───
            _buildActionCard(
              icon: Icons.lock_outline_rounded,
              title: "Şifre Değiştir",
              subtitle: "Düzenli aralıklarla şifreni güncelle",
              color: neonIndigo,
              onTap: () {
                // Misafir kullanıcı kontrolü
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess && authState.isGuest) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Misafir kullanıcılar şifre değiştiremez. Lütfen kayıt olun."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),

            // ─── AKTİF CİHAZLAR ───
            _buildActionCard(
              icon: Icons.devices_rounded,
              title: "Aktif Oturum",
              subtitle: "Mevcut oturum bilgilerin",
              color: neonIndigo,
              onTap: () => _showActiveSessionDialog(context, neonIndigo, mainDark),
            ),

            const SizedBox(height: 30),

            // ─── GÜVENLİK İPUÇLARI ───
            const Text(
              "GÜVENLİK İPUÇLARI",
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            _buildInfoCard(
              icon: Icons.shield_outlined,
              text: "Güçlü bir şifre en az 8 karakter, büyük-küçük harf ve rakam içermelidir.",
              color: neonIndigo,
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.update_rounded,
              text: "Şifreni düzenli aralıklarla değiştirmek hesap güvenliğini artırır.",
              color: neonIndigo,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Fonksiyonel Aksiyon Kartı
  // ─────────────────────────────────────────────
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black45),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Bilgi Kartı
  // ─────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Aktif Oturum Dialog
  // ─────────────────────────────────────────────
  void _showActiveSessionDialog(BuildContext context, Color neonIndigo, Color mainDark) {
    final authState = context.read<AuthBloc>().state;
    String sessionInfo = "Oturum bilgisi alınamadı.";
    String userType = "Bilinmiyor";

    if (authState is AuthSuccess) {
      userType = authState.isGuest ? "Misafir Kullanıcı" : "Kayıtlı Kullanıcı";
      sessionInfo = authState.userName;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.devices_rounded, color: neonIndigo, size: 24),
            const SizedBox(width: 12),
            const Text(
              "Aktif Oturum",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow("Kullanıcı", sessionInfo),
            const SizedBox(height: 12),
            _buildDialogRow("Hesap Türü", userType),
            const SizedBox(height: 12),
            _buildDialogRow("Cihaz", "Bu Cihaz (Aktif)"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "KAPAT",
              style: TextStyle(color: mainDark, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}