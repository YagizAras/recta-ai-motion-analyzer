import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Uygulama Renk Paleti
    const Color bgLight = Color(0xFFF8F9FB);
    const Color neonIndigo = Color(0xFF536DFE);
    const Color darkText = Color(0xFF1A1A1A);

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
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // 1. PROFİL FOTOĞRAFI DÜZENLEME
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: neonIndigo.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFE0E0E0),
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: neonIndigo,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Fotoğrafı Değiştir",
                      style: TextStyle(
                        color: neonIndigo,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 2. DÜZENLEME ALANLARI
              _buildEditField(
                  label: "AD SOYAD",
                  hint: "İlayda ...",
                  icon: Icons.person_outline_rounded),
              _buildEditField(
                  label: "YAŞ",
                  hint: "20",
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number),
              _buildEditField(
                  label: "BOY (CM)",
                  hint: "165",
                  icon: Icons.height_rounded,
                  keyboardType: TextInputType.number),
              _buildEditField(
                  label: "KİLO (KG)",
                  hint: "55",
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.number),
              _buildEditField(
                  label: "SAKATLIK GEÇMİŞİ",
                  hint: "Diz hassasiyeti, omuz fleksiyonu...",
                  icon: Icons.history_edu_rounded,
                  isLongText: true),

              const SizedBox(height: 30),

              // 3. KAYDET BUTONU
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1B2F), Color(0xFF2D2E4A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1B2F).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "DEĞİŞİKLİKLERİ KAYDET",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required String hint,
    required IconData icon,
    bool isLongText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black26,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            keyboardType: keyboardType,
            maxLines: isLongText ? 3 : 1,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Colors.black26, fontSize: 14, fontWeight: FontWeight.w500),
              prefixIcon: Icon(icon, color: const Color(0xFF536DFE), size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.black12, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    const BorderSide(color: Color(0xFF536DFE), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}