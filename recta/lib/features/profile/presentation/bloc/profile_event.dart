import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileSettings extends ProfileEvent {}

class SaveProfileData extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String identityNumber;
  final int age;
  final double heightCm;
  final double weightKg;
  final String injuryHistory;

  const SaveProfileData({
    required this.firstName,
    required this.lastName,
    required this.identityNumber,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.injuryHistory,
  });

  @override
  List<Object> get props => [
        firstName,
        lastName,
        identityNumber,
        age,
        heightCm,
        weightKg,
        injuryHistory
      ];
}

class UpdateNotificationSettings extends ProfileEvent {
  final bool pushNotify;
  final bool aiFeedback;
  final bool weeklyReport;

  const UpdateNotificationSettings({
    required this.pushNotify,
    required this.aiFeedback,
    required this.weeklyReport,
  });

  @override
  List<Object> get props => [pushNotify, aiFeedback, weeklyReport];
}
