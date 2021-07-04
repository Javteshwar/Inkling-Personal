import 'package:flutter/material.dart';
import 'package:inkling_personal/blocs/FileViewBloc.dart';

Widget getEmailTextField({
  GlobalKey<FormState> formKey,
  TextEditingController controller,
}) {
  return Form(
    key: formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Material(
      elevation: 12,
      color: Colors.transparent,
      shadowColor: Colors.black54,
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: 'rahul@predator.com',
          labelText: 'Email',
          prefixIcon: Icon(
            Icons.account_circle,
            color: Colors.blue[800],
          ),
        ),
        validator: (value) {
          if (value.isEmpty) return "Email must be entered";
          RegExp emailCheckRegex = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
          );
          if (!emailCheckRegex.hasMatch(value)) return "Invalid Email Address";
          return null;
        },
      ),
    ),
  );
}

Widget getErrorDialog({
  String title,
  String msg,
  BuildContext context,
}) {
  return AlertDialog(
    backgroundColor: Colors.blue[800],
    title: Center(
      child: Text(
        title,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    content: Text(msg),
    actions: <Widget>[
      TextButton(
        child: Text(
          "OK",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

Widget getLoadingDialog({String title = 'Loading,'}) {
  return AlertDialog(
    backgroundColor: Colors.blue[800],
    title: Center(
      child: Text(
        title,
      ),
    ),
    content: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(
          strokeWidth: 7,
          color: Colors.amber,
        ),
      ],
    ),
  );
}

Widget getReloadFilesWidget({
  String txt,
  FileViewBloc blc,
  bool isStore,
}) {
  FileViewEvent ev = isStore ? LoadStoreFilesEvent() : LoadUserFilesEvent();
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          txt,
          textScaleFactor: 1.5,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Reload',
              textScaleFactor: 1.25,
            ),
          ),
          onPressed: () => blc.add(ev),
        ),
      ],
    ),
  );
}

Widget getErrorSnackBar({
  String msg,
}) {
  return SnackBar(
    content: Text(
      msg,
      style: TextStyle(color: Colors.white),
      textScaleFactor: 1.2,
    ),
    backgroundColor: Colors.red,
  );
}
