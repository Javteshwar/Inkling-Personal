import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/UI/Login.dart';
import 'package:inkling_personal/UI/HomeController.dart';
import 'package:inkling_personal/UI/Register%20Screen/Register.dart';
import 'package:inkling_personal/UI/Theme.dart';
import 'package:inkling_personal/blocs/AuthenticationBloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  //print('Initialized: $app');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthenticationBloc _authBloc;
  @override
  void initState() {
    _authBloc = AuthenticationBloc();
    _authBloc.add(AppStarted());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: SafeArea(
        child: BlocProvider(
          create: (context) => _authBloc,
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            bloc: _authBloc,
            builder: (context, state) {
              if (state is AuthenticationLoading) {
                return Center(
                  child: SizedBox(
                    height: 500,
                    width: 500,
                    child: CircularProgressIndicator(
                      strokeWidth: 7,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[800]),
                    ),
                  ),
                );
              } else if (state is LoginPageState) {
                return LoginPage();
              } else if (state is RegisterPageState) {
                return RegisterPage();
              } else if (state is UserAuthenticatedState) {
                return HomeController();
              } else if (state is AuthenticationErrorState) {
                return Center(
                  child: Text(state.err, textScaleFactor: 4),
                );
              }
              return Center(
                child: Text(
                  "Oops, this Embarassing :( Somethin Happened",
                  textScaleFactor: 4,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
