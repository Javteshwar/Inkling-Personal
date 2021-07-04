import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/UI/Common%20Widgets/LogoImage.dart';
import 'package:inkling_personal/UI/Common%20Widgets/PasswordFieldWidget.dart';
import 'package:inkling_personal/UI/Common%20Widgets/CommonWidgets.dart';
import 'package:inkling_personal/UI/Common%20Widgets/LoginRegisterAnimator.dart';
import 'package:inkling_personal/UI/Register%20Screen/PassCrossFadeBloc.dart';
import 'package:inkling_personal/blocs/AuthenticationBloc.dart';
import 'package:inkling_personal/blocs/RegisterBloc.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  var _emailFormKey = GlobalKey<FormState>();
  TextEditingController _emailController;
  var _userPassFormKey = GlobalKey<FormState>();
  TextEditingController _userPassController;
  var _adminPassFormKey = GlobalKey<FormState>();
  TextEditingController _adminPassController;
  int _selValDropDown;
  AuthenticationBloc _authBloc;
  RegisterBloc _regBloc;
  AnimationController _scaleTransitionController;
  @override
  void initState() {
    _selValDropDown = 0;
    _emailController = TextEditingController();
    _userPassController = TextEditingController();
    _adminPassController = TextEditingController();
    _selValDropDown = 0;
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    _regBloc = RegisterBloc();
    _scaleTransitionController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    //print("Disposed Register");
    _scaleTransitionController.dispose();
    _regBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return BlocListener<RegisterBloc, RegisterState>(
      bloc: _regBloc,
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
                  isLogin: false,
                  scaleTransitionController: _scaleTransitionController,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(40, 24, 40, 8),
                        child: SizedBox(
                          width: width > 500 ? 400 : double.infinity,
                          child: getEmailTextField(
                            formKey: _emailFormKey,
                            controller: _emailController,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: SizedBox(
                          width: width > 500 ? 400 : double.infinity,
                          child: PasswordField(
                            controller: _userPassController,
                            formKey: _userPassFormKey,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      CrossFadePasswordBloc(
                        adminPassController: _adminPassController,
                        adminPassFormKey: _adminPassFormKey,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48, 8, 48, 24),
                        child: getRegisterButton(),
                      ),
                      Text(
                        'Already have an Account?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      getLoginButton(),
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
    if (state is RegisterLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => getLoadingDialog(title: 'Signing Up'),
      );
    } else if (state is RegisterFailure) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => getErrorDialog(
            context: context, title: 'Registration Error', msg: state.error),
      );
    } else if (state is RegisterSuccess) {
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

  Widget getRegisterButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[800],
        minimumSize: Size(150, 50),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Register',
        textScaleFactor: 1.5,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        if (!_emailFormKey.currentState.validate() ||
            !_userPassFormKey.currentState.validate()) return;
        _regBloc.add(RegisterEvent(
          email: _emailController.text.trim(),
          pass: _userPassController.text.trim(),
          isAdmin: _selValDropDown == 1,
          adminPass: _adminPassController.text.trim(),
        ));
      },
    );
  }

  Widget getLoginButton() {
    return TextButton(
      child: Text(
        'LOGIN',
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
