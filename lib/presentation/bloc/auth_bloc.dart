import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.signIn(event.email, event.password);
      emit(result.fold(
        (failure) => AuthError(failure.message),
        (user) => Authenticated(user),
      ));
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.signUp(
        event.fullName,
        event.email,
        event.password,
        event.phoneNumber,
      );
      emit(result.fold(
        (failure) => AuthError(failure.message),
        (user) => Authenticated(user),
      ));
    });

    on<LogoutRequested>((event, emit) async {
      await authRepository.signOut();
      emit(AuthInitial());
    });
  }
}
