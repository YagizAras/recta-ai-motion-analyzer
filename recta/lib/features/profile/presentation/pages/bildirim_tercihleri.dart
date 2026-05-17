import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

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
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildSwitchTile(
                  "Anlık Bildirimler", 
                  "Uygulama bildirimlerini yönet", 
                  state.pushNotify, 
                  (v) => context.read<ProfileBloc>().add(
                    UpdateNotificationSettings(
                      pushNotify: v, 
                      aiFeedback: state.aiFeedback, 
                      weeklyReport: state.weeklyReport
                    )
                  )
                ),
                _buildSwitchTile(
                  "AI Geri Bildirimleri", 
                  "Gemini analiz sonuçları hazır olduğunda haber ver", 
                  state.aiFeedback, 
                  (v) => context.read<ProfileBloc>().add(
                    UpdateNotificationSettings(
                      pushNotify: state.pushNotify, 
                      aiFeedback: v, 
                      weeklyReport: state.weeklyReport
                    )
                  )
                ),
                _buildSwitchTile(
                  "Haftalık Gelişim Raporu", 
                  "Pazartesi günleri performans özeti al", 
                  state.weeklyReport, 
                  (v) => context.read<ProfileBloc>().add(
                    UpdateNotificationSettings(
                      pushNotify: state.pushNotify, 
                      aiFeedback: state.aiFeedback, 
                      weeklyReport: v
                    )
                  )
                ),
              ],
            ),
          );
        },
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}