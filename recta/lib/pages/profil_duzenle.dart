import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail; 

  const EditProfileScreen({
    super.key, 
    this.userName = "", 
    this.userEmail = "" 
  });

  @override
  Widget build(BuildContext context) {
    const Color bgLight = Color(0xFFF8F9FB);
    const Color neonIndigo = Color(0xFF536DFE);

    // İsim bölme işlemi
    List<String> nameParts = userName.split(" ");
    String firstName = nameParts.isNotEmpty ? nameParts[0] : "";
    String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            "BİLGİLERİ DÜZENLE",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
          ),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            children: [
              // PROFİL FOTOĞRAFI ALANI
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: neonIndigo.withOpacity(0.2), width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 45, color: Colors.black12),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: neonIndigo, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text("Fotoğrafı Değiştir", style: TextStyle(color: neonIndigo, fontWeight: FontWeight.w800, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ALANLAR: Ad, Soyad ve E-posta dolu geleceği için Controller kullanıyoruz
              _buildEditField("AD", "", Icons.person_outline_rounded, initialValue: firstName),
              _buildEditField("SOYAD", "", Icons.person_outline_rounded, initialValue: lastName),
              _buildEditField("E-POSTA", "", Icons.email_outlined, initialValue: userEmail), 

              // Bu alanlar boş (hint) ve soluk renkli başlayacak
              _buildEditField("YAŞ", "Yaşınızı girin", Icons.cake_outlined, keyboardType: TextInputType.number),
              _buildEditField("BOY (CM)", "Boyunuzu girin", Icons.height_rounded, keyboardType: TextInputType.number),
              _buildEditField("KİLO (KG)", "Kilonuzu girin", Icons.monitor_weight_outlined, keyboardType: TextInputType.number),
              _buildEditField("SAKATLIK GEÇMİŞİ", "Detayları girin...", Icons.history_edu_rounded, isLongText: true),

              const SizedBox(height: 10),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1B2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text("DEĞİŞİKLİKLERİ KAYDET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, String hint, IconData icon, {bool isLongText = false, TextInputType keyboardType = TextInputType.text, String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            maxLines: isLongText ? 2 : 1,
            // YAZDIĞINDA GÖRÜNECEK RENK: SİYAH
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black), 
            decoration: InputDecoration(
              hintText: hint,
              // GİRİLMEYEN BİLGİ RENGİ: SOLUK (black26)
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 13, fontWeight: FontWeight.w500),
              prefixIcon: Icon(icon, color: const Color(0xFF536DFE), size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black12, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF536DFE), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}