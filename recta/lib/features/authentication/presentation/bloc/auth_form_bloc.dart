import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class AuthFormEvent extends Equatable {
  const AuthFormEvent();
  @override
  List<Object> get props => [];
}

class ToggleAuthMode extends AuthFormEvent {}

class AuthFormState extends Equatable {
  final bool isLogin;

  const AuthFormState({this.isLogin = true});

  AuthFormState copyWith({bool? isLogin}) {
    return AuthFormState(
      isLogin: isLogin ?? this.isLogin,
    );
  }

  @override
  List<Object> get props => [isLogin];
}

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  AuthFormBloc() : super(const AuthFormState()) {
    on<ToggleAuthMode>((event, emit) {
      emit(state.copyWith(isLogin: !state.isLogin));
    });
  }
}
