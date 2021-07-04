import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/blocs/AuthenticationBloc.dart';

class ScaleTranslateAnimator extends StatefulWidget {
  final scaleTransitionController;
  final Widget child;
  final bool isLogin;
  const ScaleTranslateAnimator({
    this.child,
    this.scaleTransitionController,
    this.isLogin,
  });

  static void reverseAnimationControl() {}

  @override
  _ScaleTranslateAnimatorState createState() => _ScaleTranslateAnimatorState();
}

class _ScaleTranslateAnimatorState extends State<ScaleTranslateAnimator>
    with TickerProviderStateMixin {
  Animation _scaleTransition;
  AnimationController _scaleTransitionController;
  Animation _translateTransition;
  AnimationController _translateTransitionController;
  AuthenticationBloc _authBloc;
  @override
  void initState() {
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    initializeAnimators();
    _translateTransitionController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _translateTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: _scaleTransition,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleTransition.value,
          child: AnimatedBuilder(
            animation: _translateTransition,
            child: child,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  (widget.isLogin ? -1 : 1) *
                      4 *
                      width *
                      _translateTransition.value,
                  0,
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: widget.child,
    );
  }

  void initializeAnimators() {
    _scaleTransitionController = widget.scaleTransitionController;
    _scaleTransition =
        Tween<double>(begin: 0.25, end: 1).animate(_scaleTransitionController);
    _scaleTransition.addStatusListener(scaleanimationStatusListener);
    _translateTransitionController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _translateTransition =
        Tween<double>(begin: 1, end: 0).animate(_translateTransitionController);
    _translateTransition.addStatusListener(translateanimationStatusListener);
  }

  void scaleanimationStatusListener(AnimationStatus stts) {
    if (stts == AnimationStatus.dismissed) {
      _translateTransitionController.reverse();
    }
  }

  void translateanimationStatusListener(AnimationStatus stts) {
    if (stts == AnimationStatus.completed) {
      _scaleTransitionController.forward();
    }
    if (stts == AnimationStatus.dismissed) {
      final ev = widget.isLogin ? RegisterPageEvent() : LoginPageEvent();
      _authBloc.add(ev);
    }
  }
}
