import 'dart:math';

import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final String lbl;
  const PasswordField({
    this.controller,
    this.lbl = "Password",
    this.formKey,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField>
    with TickerProviderStateMixin {
  GlobalKey<FormState> _formKey;
  TextEditingController _controller;
  bool _obscText;
  String _lbl;
  AnimationController _animationController;
  Animation _iconRotateAnimation;
  int i = 0;
  @override
  void initState() {
    _formKey = widget.formKey;
    _controller = widget.controller;
    _lbl = widget.lbl;
    _obscText = true;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
    _iconRotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
    _iconRotateAnimation.addStatusListener(statusListener);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Material(
        elevation: 12,
        color: Colors.transparent,
        shadowColor: Colors.black54,
        child: TextFormField(
          controller: _controller,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          obscureText: _obscText,
          decoration: InputDecoration(
            hintText: 'Enter Password',
            labelText: _lbl,
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.blue[800],
            ),
            suffixIcon: IconButton(
                icon: AnimatedBuilder(
                  animation: _iconRotateAnimation,
                  builder: (context, _) {
                    IconData iconD =
                        _obscText ? Icons.visibility_off : Icons.visibility;
                    if (_iconRotateAnimation.isDismissed ||
                        _iconRotateAnimation.isCompleted)
                      return Icon(
                        iconD,
                        color: Colors.blue[800],
                      );
                    return Transform.rotate(
                      angle: pi * _iconRotateAnimation.value,
                      child: Icon(
                        iconD,
                        color: Colors.blue[800],
                      ),
                    );
                  },
                ),
                onPressed: () {
                  if (_obscText)
                    _animationController.forward();
                  else
                    _animationController.reverse();
                }),
          ),
          validator: (value) {
            if (value.isEmpty) return "Password must be entered";
            return null;
          },
        ),
      ),
    );
  }

  void statusListener(AnimationStatus stts) {
    if (stts == AnimationStatus.completed ||
        stts == AnimationStatus.dismissed) {
      setState(() {
        _obscText = !_obscText;
      });
    }
  }
}
