import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/APICalls/AuthCalls.dart';

class RegisterEvent extends Equatable {
  final String email;
  final String pass;
  final bool isAdmin;
  final String adminPass;
  RegisterEvent({
    this.email,
    this.pass,
    this.isAdmin = false,
    this.adminPass = '',
  });
  List<Object> get props => [email, pass, isAdmin, adminPass];
}

abstract class RegisterState extends Equatable {
  List<Object> get props => [];
}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure({this.error});
  List<Object> get props => [error];
}

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  AuthorizationCalls _authCalls = AuthorizationCalls();
  RegisterBloc() : super(RegisterLoading());
  Stream<RegisterState> mapEventToState(event) async* {
    if (event is RegisterEvent) {
      yield RegisterLoading();
      await Future.delayed(Duration(seconds: 1));
      try {
        await _authCalls.registerUser(
          email: event.email,
          password: event.pass,
          isAdmin: event.isAdmin,
          adminPassword: event.adminPass,
        );
        yield RegisterSuccess();
      } catch (e) {
        //print(e.toString());
        //if (e.toString().contains('Socket')) //print("Socket Error");
        yield RegisterFailure(error: e.toString());
      }
    }
  }
}
