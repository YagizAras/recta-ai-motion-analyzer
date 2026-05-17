import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart' as auth;
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _injuryController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _injuryController.dispose();
    super.dispose();
  }

  void _initializeControllers(ProfileState state) {
    if (!_initialized) {
      // Ad-Soyad: Önce Firestore profil verisini, yoksa Auth'tan gelen kaydı kullan
      final authState = context.read<AuthBloc>().state;
      String registeredName = '';
      if (authState is auth.AuthSuccess) {
        registeredName = authState.userName;
      }

      // Profil verisinde ad/soyad varsa onu kullan, yoksa kayıt adını böl
      if (state.firstName.isNotEmpty) {
        _firstNameController.text = state.firstName;
        _lastNameController.text = state.lastName;
      } else if (registeredName.isNotEmpty) {
        final parts = registeredName.split(' ');
        _firstNameController.text = parts.first;
        _lastNameController.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }

      _ageController.text = state.age > 0 ? state.age.toString() : '';
      _heightController.text = state.heightCm > 0 ? state.heightCm.toStringAsFixed(0) : '';
      _weightController.text = state.weightKg > 0 ? state.weightKg.toStringAsFixed(0) : '';
      _injuryController.text = state.injuryHistory;
      _initialized = true;
    }
  }

  void _saveProfile() {
    context.read<ProfileBloc>().add(SaveProfileData(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      identityNumber: '',
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      heightCm: double.tryParse(_heightController.text.trim()) ?? 0.0,
      weightKg: double.tryParse(_weightController.text.trim()) ?? 0.0,
      injuryHistory: _injuryController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const Color bgLight = Color(0xFFF8F9FB);
    const Color neonIndigo = Color(0xFF536DFE);

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.isSavedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bilgileriniz başarıyla kaydedildi!"),
              backgroundColor: Color(0xFF536DFE),
            ),
          );
          Navigator.pop(context);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        _initializeControllers(state);

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
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
                                decoration: const BoxDecoration(color: neonIndigo, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text("Fotoğrafı Değiştir",
                          style: TextStyle(color: neonIndigo, fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  _buildEditField(label: "AD", controller: _firstNameController, icon: Icons.person_outline_rounded),
                  _buildEditField(label: "SOYAD", controller: _lastNameController, icon: Icons.person_outline_rounded),
                  _buildEditField(label: "YAŞ", controller: _ageController, icon: Icons.cake_outlined, keyboardType: TextInputType.number),
                  _buildEditField(label: "BOY (CM)", controller: _heightController, icon: Icons.height_rounded, keyboardType: TextInputType.number),
                  _buildEditField(label: "KİLO (KG)", controller: _weightController, icon: Icons.monitor_weight_outlined, keyboardType: TextInputType.number),
                  _buildEditField(label: "SAKATLIK GEÇMİŞİ", controller: _injuryController, icon: Icons.history_edu_rounded, isLongText: true),

                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: state.isLoading ? null : _saveProfile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: state.isLoading
                              ? [const Color(0xFF1A1B2F).withOpacity(0.5), const Color(0xFF2D2E4A).withOpacity(0.5)]
                              : [const Color(0xFF1A1B2F), const Color(0xFF2D2E4A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF1A1B2F).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Center(
                        child: state.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text("DEĞİŞİKLİKLERİ KAYDET",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 15)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isLongText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: isLongText ? 3 : 1,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1B2F)),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14, fontWeight: FontWeight.w500),
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
                borderSide: const BorderSide(color: Color(0xFF536DFE), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}