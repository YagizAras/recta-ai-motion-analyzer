import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFEFAF2);
    const Color darkGreen = Color(0xFF183B36);
    const Color lightGreen = Color(0xFFC2DC8E);
    const Color textColor = Color(0xFF385E3B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(
            color: darkGreen,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture Placeholder
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE5F3FD), // Sky blue
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Cloud
                    const Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Icon(Icons.cloud, color: Colors.white, size: 50),
                    ),
                    // Back Hill
                    Positioned(
                      bottom: -15,
                      left: -20,
                      right: -10,
                      child: Container(
                        height: 45,
                        decoration: const BoxDecoration(
                          color: Color(0xFF91C31E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Front Hill
                    Positioned(
                      bottom: -25,
                      left: 10,
                      right: -30,
                      child: Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7CAE13),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fotoğraf Ekle/Değiştir',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ad soyad',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Form Fields
              _buildTextField('Ad Soyad', lightGreen, textColor),
              const SizedBox(height: 16),
              _buildTextField('Yaş', lightGreen, textColor),
              const SizedBox(height: 16),
              _buildTextField('Cinsiyet', lightGreen, textColor),
              const SizedBox(height: 16),
              _buildTextField('Boy', lightGreen, textColor),
              const SizedBox(height: 16),
              _buildTextField('Kilo', lightGreen, textColor),
              const SizedBox(height: 16),
              _buildTextField('Sakatlık Geçmişi', lightGreen, textColor),
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, Color fillColor, Color textColor) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(
          color: textColor,
          fontSize: 15,
        ),
      ),
    );
  }
}
