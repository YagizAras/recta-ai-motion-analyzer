import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF1A1B2F), Color(0xFF2D2E4A)]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
            ),
            child: Column(
              children: [
                const Text("RECTA", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const Text("Versiyon 1.0.0", style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 20),
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Recta, yapay zeka desteğiyle fizik tedavi süreçlerini dijitalleştiren bir mühendislik projesidir.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.6),
            ),
          ),
          const Spacer(),
          const Text("© 2026 Recta AI. Tüm hakları saklıdır.", style: TextStyle(color: Colors.black26, fontSize: 10)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}