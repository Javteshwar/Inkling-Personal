import 'package:flutter/material.dart';
import 'package:inkling_personal/UI/Common%20Widgets/PasswordFieldWidget.dart';

class CrossFadePasswordBloc extends StatefulWidget {
  final TextEditingController adminPassController;
  final adminPassFormKey;
  const CrossFadePasswordBloc({
    this.adminPassController,
    this.adminPassFormKey,
  });

  @override
  _CrossFadePasswordBlocState createState() => _CrossFadePasswordBlocState();
}

class _CrossFadePasswordBlocState extends State<CrossFadePasswordBloc> {
  TextEditingController _adminPassController;
  var _adminPassFormKey;
  int _selValDropDown;
  @override
  void initState() {
    _adminPassController = widget.adminPassController;
    _adminPassFormKey = widget.adminPassFormKey;
    _selValDropDown = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedCrossFade(
          firstChild: SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
            child: SizedBox(
              width: width > 600 ? 400 : double.infinity,
              child: PasswordField(
                controller: _adminPassController,
                formKey: _adminPassFormKey,
                lbl: "Admin Password",
              ),
            ),
          ),
          alignment: Alignment.topCenter,
          secondCurve: Curves.easeIn,
          reverseDuration: Duration(microseconds: 200),
          duration: Duration(milliseconds: 400),
          crossFadeState: _selValDropDown == 0
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
        SizedBox(height: 8),
        DropdownButton(
          dropdownColor: Colors.white,
          value: _selValDropDown,
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
          underline: SizedBox.shrink(),
          iconSize: 32,
          items: [
            DropdownMenuItem(
              child: Text(
                'Standard Account',
              ),
              value: 0,
            ),
            DropdownMenuItem(
              child: Text(
                'Admin Account',
              ),
              value: 1,
            ),
          ],
          onChanged: (value) {
            setState(() {
              if (value == 1) {
                _adminPassController.clear();
              }
              _selValDropDown = value;
            });
          },
        ),
      ],
    );
  }
}
