import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/UI/Common%20Widgets/LogoImage.dart';
import 'package:inkling_personal/UI/Common%20Widgets/PasswordFieldWidget.dart';
import 'package:inkling_personal/UI/Common%20Widgets/CommonWidgets.dart';
import 'package:inkling_personal/UI/Common%20Widgets/LoginRegisterAnimator.dart';
import 'package:inkling_personal/blocs/AuthenticationBloc.dart';
import 'package:inkling_personal/blocs/LoginBloc.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  var _emailFormKey = GlobalKey<FormState>();
  TextEditingController _emailController;
  var _passFormKey = GlobalKey<FormState>();
  TextEditingController _passController;
  AuthenticationBloc _authBloc;
  LoginBloc _logBloc;
  AnimationController _scaleTransitionController;
  @override
  void initState() {
    _emailController = TextEditingController();
    _passController = TextEditingController();
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    _logBloc = LoginBloc();
    _scaleTransitionController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    //print("Disposed Login");
    _scaleTransitionController.dispose();
    _logBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return BlocListener<LoginBloc, LoginState>(
      bloc: _logBloc,
      listener: getBlocListenerFunction,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.amber,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      getTextSpan(txt: 'I', clr: Colors.red),
                      getTextSpan(txt: 'N', clr: Colors.green[300]),
                      getTextSpan(txt: 'K', clr: Colors.blue[300]),
                      getTextSpan(txt: 'LING', clr: Colors.white),
                    ],
                  ),
                ),
                LogoImage(),
                ScaleTranslateAnimator(
                  isLogin: true,
                  scaleTransitionController: _scaleTransitionController,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(40, 24, 40, 8),
                        child: SizedBox(
                          width: width > 600 ? 400 : double.infinity,
                          child: getEmailTextField(
                            formKey: _emailFormKey,
                            controller: _emailController,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: SizedBox(
                          width: width > 600 ? 400 : double.infinity,
                          child: PasswordField(
                            controller: _passController,
                            formKey: _passFormKey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48, 24, 48, 24),
                        child: getLoginButton(),
                      ),
                      Text(
                        'Don\'t have an Account?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      getRegisterButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getBlocListenerFunction(context, state) {
    if (state is LoginLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => getLoadingDialog(title: 'Logging In'),
      );
    } else if (state is LoginFailure) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => getErrorDialog(
            context: context, title: 'Registration Error', msg: state.error),
      );
    } else {
      Navigator.pop(context);
      _authBloc.add(LoggedIn());
    }
  }

  TextSpan getTextSpan({String txt, Color clr}) {
    return TextSpan(
      text: txt,
      style: TextStyle(
        color: clr,
        fontSize: 40,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget getLoginButton() {
    return ElevatedButton(
      child: Text(
        'Login',
        textScaleFactor: 1.5,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        if (!_emailFormKey.currentState.validate() ||
            !_passFormKey.currentState.validate()) return;
        _logBloc.add(
          LoginEvent(
            email: _emailController.text.trim(),
            pass: _passController.text.trim(),
          ),
        );
      },
    );
  }

  Widget getRegisterButton() {
    return TextButton(
      child: Text(
        'REGISTER',
        style: TextStyle(
          color: Colors.blue[800],
          decoration: TextDecoration.underline,
          decorationThickness: 2,
          fontSize: 28,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        _scaleTransitionController.reverse();
      },
    );
  }
}
