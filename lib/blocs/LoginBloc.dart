import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/APICalls/AuthCalls.dart';

class LoginEvent extends Equatable {
  final String email;
  final String pass;
  LoginEvent({
    this.email,
    this.pass,
  });
  List<Object> get props => [email, pass];
}

abstract class LoginState extends Equatable {
  List<Object> get props => [];
}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String error;
  LoginFailure({this.error});
  List<Object> get props => [error];
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthorizationCalls _authCalls = AuthorizationCalls();
  LoginBloc() : super(LoginLoading());
  Stream<LoginState> mapEventToState(event) async* {
    if (event is LoginEvent) {
      yield LoginLoading();
      await Future.delayed(Duration(seconds: 1));
      try {
        await _authCalls.loginUser(
          email: event.email,
          password: event.pass,
        );
        yield LoginSuccess();
      } catch (e) {
        //print("Login Error: " + e.toString());
        if (e.toString().contains('Socket')) //print("Socket Error");
          yield LoginFailure(error: e.toString());
      }
    }
  }
}
