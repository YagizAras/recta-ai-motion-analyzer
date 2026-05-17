import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool pushNotify = true;
  bool aiFeedback = true;
  bool weeklyReport = false;

  @override
  Widget build(BuildContext context) {
    const Color neonIndigo = Color(0xFF536DFE);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("BİLDİRİM TERCİHLERİ", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSwitchTile("Anlık Bildirimler", "Uygulama bildirimlerini yönet", pushNotify, (v) => setState(() => pushNotify = v)),
            _buildSwitchTile("AI Geri Bildirimleri", "Gemini analiz sonuçları hazır olduğunda haber ver", aiFeedback, (v) => setState(() => aiFeedback = v)),
            _buildSwitchTile("Haftalık Gelişim Raporu", "Pazartesi günleri performans özeti al", weeklyReport, (v) => setState(() => weeklyReport = v)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: SwitchListTile(
        activeColor: const Color(0xFF536DFE),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black38)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}