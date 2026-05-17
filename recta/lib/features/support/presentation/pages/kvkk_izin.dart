import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("GİZLİLİK VE İZİNLER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, color: neonIndigo, size: 50),
            const SizedBox(height: 20),
            const Text("Verileriniz Recta ile Güvende", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.black)),
            const SizedBox(height: 15),
            const Text(
              "Recta AI, hareketlerinizi analiz ederken gizliliğinizi en üst düzeyde tutar. KVKK kapsamında verilerinizin nasıl işlendiğini aşağıdan inceleyebilirsiniz.",
              style: TextStyle(color: Colors.black, height: 1.5),
            ),
            const SizedBox(height: 30),
            
            _buildInfoTile("Kamera Kullanımı", "Görüntüleriniz sunucularımıza kaydedilmez. Sadece anlık iskelet takibi için cihazınızda işlenir."),
            _buildInfoTile("Sağlık Verileri", "Analiz sonuçlarınız sadece gelişim takibi amacıyla şifreli olarak saklanır."),
            _buildInfoTile("KVKK Hakları", "Dilediğiniz zaman verilerinizin silinmesini talep edebilir, hesabınızı kapatabilirsiniz."),

            const SizedBox(height: 40),
            
            // İZİN DURUMU KARTI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kamera İzni", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                        Text("Analiz için gerekli", style: TextStyle(color: Colors.black, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(value: true, activeColor: neonIndigo, onChanged: (v) {}),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.black, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}