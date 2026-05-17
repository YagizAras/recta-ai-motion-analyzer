import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository}) 
      : _repository = repository,
        super(const ProfileState()) {
    on<LoadProfileSettings>(_onLoadProfileSettings);
    on<SaveProfileData>(_onSaveProfileData);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
  }

  Future<void> _onLoadProfileSettings(
    LoadProfileSettings event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final profileData = await _repository.getProfile();
      
      if (profileData != null) {
        emit(state.copyWith(
          isLoading: false,
          firstName: profileData['FirstName'] ?? '',
          lastName: profileData['LastName'] ?? '',
          identityNumber: profileData['IdentityNumber'] ?? '',
          age: profileData['Age'] ?? 0,
          heightCm: (profileData['HeightCm'] ?? 0).toDouble(),
          weightKg: (profileData['WeightKg'] ?? 0).toDouble(),
          injuryHistory: profileData['InjuryHistory'] ?? '',
          // Real settings from Firestore
          pushNotify: profileData['PushNotify'] ?? true,
          aiFeedback: profileData['AiFeedback'] ?? true,
          weeklyReport: profileData['WeeklyReport'] ?? false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Profil yüklenirken bir hata oluştu: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSaveProfileData(
    SaveProfileData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _repository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        identityNumber: event.identityNumber,
        age: event.age,
        heightCm: event.heightCm,
        weightKg: event.weightKg,
        injuryHistory: event.injuryHistory,
      );

      emit(state.copyWith(
        isLoading: false,
        isSavedSuccessfully: true,
        firstName: event.firstName,
        lastName: event.lastName,
        identityNumber: event.identityNumber,
        age: event.age,
        heightCm: event.heightCm,
        weightKg: event.weightKg,
        injuryHistory: event.injuryHistory,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Profil kaydedilirken bir hata oluştu: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<ProfileState> emit,
  ) async {
    // Önce state'i anında güncelleyip UI'ın tepki vermesini sağla
    emit(state.copyWith(
      pushNotify: event.pushNotify,
      aiFeedback: event.aiFeedback,
      weeklyReport: event.weeklyReport,
    ));
    
    // Arka planda Firebase'e kaydet
    try {
      await _repository.updateNotificationSettings(
        pushNotify: event.pushNotify,
        aiFeedback: event.aiFeedback,
        weeklyReport: event.weeklyReport,
      );
    } catch (e) {
      // Hata olursa kullanıcıya bildir
      emit(state.copyWith(errorMessage: 'Bildirim ayarları kaydedilirken hata oluştu: ${e.toString()}'));
    }
  }
}
