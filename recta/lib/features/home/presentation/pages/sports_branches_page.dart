import 'package:flutter/material.dart';

class SportsBranchesPage extends StatelessWidget {
  const SportsBranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFEFAF2); // Off-white cream color
    const Color darkGreen = Color(0xFF183B36);
    const Color lightGreen = Color(0xFFC2DC8E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SPOR BRANŞLARI',
          style: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black87, width: 0.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: darkGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Ara",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Branş Seçimi',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              
              // Options
              _buildBranchOption('Seçili Branş', darkGreen, Colors.white),
              const SizedBox(height: 16),
              _buildBranchOption('Seçenek1', lightGreen, darkGreen),
              const SizedBox(height: 16),
              _buildBranchOption('Seçenek2', lightGreen, darkGreen),
              const SizedBox(height: 16),
              _buildBranchOption('Fonksiyonel Antrenman (Lunge / Squat / Plank)', lightGreen, darkGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchOption(String text, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
