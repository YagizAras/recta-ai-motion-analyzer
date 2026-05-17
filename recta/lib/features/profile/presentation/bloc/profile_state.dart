import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final bool pushNotify;
  final bool aiFeedback;
  final bool weeklyReport;

  // UML Data
  final String firstName;
  final String lastName;
  final String identityNumber;
  final int age;
  final double heightCm;
  final double weightKg;
  
  // Custom Addition
  final String injuryHistory;

  final String? errorMessage;
  final bool isSavedSuccessfully;

  const ProfileState({
    this.isLoading = false,
    this.pushNotify = true,
    this.aiFeedback = true,
    this.weeklyReport = false,
    
    this.firstName = '',
    this.lastName = '',
    this.identityNumber = '',
    this.age = 0,
    this.heightCm = 0.0,
    this.weightKg = 0.0,
    this.injuryHistory = '',

    this.errorMessage,
    this.isSavedSuccessfully = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? pushNotify,
    bool? aiFeedback,
    bool? weeklyReport,
    
    String? firstName,
    String? lastName,
    String? identityNumber,
    int? age,
    double? heightCm,
    double? weightKg,
    String? injuryHistory,

    String? errorMessage,
    bool? isSavedSuccessfully,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      pushNotify: pushNotify ?? this.pushNotify,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      weeklyReport: weeklyReport ?? this.weeklyReport,
      
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      identityNumber: identityNumber ?? this.identityNumber,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      injuryHistory: injuryHistory ?? this.injuryHistory,

      errorMessage: errorMessage,
      isSavedSuccessfully: isSavedSuccessfully ?? false,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        pushNotify,
        aiFeedback,
        weeklyReport,
        firstName,
        lastName,
        identityNumber,
        age,
        heightCm,
        weightKg,
        injuryHistory,
        errorMessage,
        isSavedSuccessfully,
      ];
}
