import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [email, password, fullName, phoneNumber];
}

class LogoutRequested extends AuthEvent {}
