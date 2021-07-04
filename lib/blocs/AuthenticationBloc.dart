import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/APICalls/AuthCalls.dart';

abstract class AuthenticationEvent extends Equatable {
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoginPageEvent extends AuthenticationEvent {}

class RegisterPageEvent extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {}

class LogOut extends AuthenticationEvent {}

abstract class AuthenticationState extends Equatable {
  List<Object> get props => [];
}

class LoginPageState extends AuthenticationState {}

class RegisterPageState extends AuthenticationState {}

class UserAuthenticatedState extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationErrorState extends AuthenticationState {
  final String err;
  AuthenticationErrorState({this.err});
  List<Object> get props => [err];
}

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationLoading());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield AuthenticationLoading();
      var tkn = await AuthorizationCalls.retrieveUserToken();
      if (tkn != null)
        yield UserAuthenticatedState();
      else
        yield LoginPageState();
    } else if (event is LoggedIn) {
      yield UserAuthenticatedState();
    } else if (event is LogOut) {
      await AuthorizationCalls.deleteUserToken();
      yield LoginPageState();
    } else if (event is LoginPageEvent) {
      yield LoginPageState();
    } else if (event is RegisterPageEvent) {
      yield RegisterPageState();
    }
  }
}
