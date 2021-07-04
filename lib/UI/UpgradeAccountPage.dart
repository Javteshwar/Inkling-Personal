import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/APICalls/AuthCalls.dart';
import 'package:inkling_personal/UI/Common%20Widgets/PasswordFieldWidget.dart';
import 'package:inkling_personal/UI/Common%20Widgets/CommonWidgets.dart';
import 'package:inkling_personal/blocs/AuthenticationBloc.dart';

class UpgradeAccountPage extends StatefulWidget {
  @override
  _UpgradeAccountPageState createState() => _UpgradeAccountPageState();
}

class _UpgradeAccountPageState extends State<UpgradeAccountPage> {
  var _adminPassFormKey = GlobalKey<FormState>();
  var _adminPassController;
  AuthenticationBloc _authBloc;
  AuthorizationCalls _authCall;
  @override
  void initState() {
    _authCall = AuthorizationCalls();
    _adminPassController = TextEditingController();
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Text(
              'Enter the Admin Password to Upgrade your Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: PasswordField(
              controller: _adminPassController,
              formKey: _adminPassFormKey,
              lbl: "Admin Password",
            ),
          ),
          ElevatedButton(
            child: Text(
              'Upgrade',
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              try {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => getLoadingDialog(title: 'Upgrading'),
                );
                await _authCall.upgradeUser(
                  adminPassword: _adminPassController.text.trim(),
                );
                await _authCall.logOutUser();
                await Future.delayed(Duration(seconds: 1));
                Navigator.pop(context);
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Upgrade Success'),
                      content: Text(
                        'Your account has been successfully upgraded. Login to use Admin features',
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _authBloc.add(LogOut());
                          },
                        ),
                      ],
                    );
                  },
                );
              } catch (err) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => getErrorDialog(
                    context: context,
                    title: 'Account Upgrade Error',
                    msg: err.toString(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
