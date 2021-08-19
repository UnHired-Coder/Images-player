import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdfconverter/UI/animated/UIwidgets/animatedActiveButton.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';

class AnimatedHeaderButtonController {
  void Function(dynamic v) setCount;
}

class AnimatedHeaderButton extends StatefulWidget {
  final AnimatedHeaderButtonController controller;
  final Function callback;

  AnimatedHeaderButton({this.controller, this.callback});

  @override
  _AnimatedNotificationButtonState createState() =>
      _AnimatedNotificationButtonState(controller);
}

class _AnimatedNotificationButtonState extends State<AnimatedHeaderButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  int _count;

  _AnimatedNotificationButtonState(AnimatedHeaderButtonController _controller) {
    _controller.setCount = setCount;
  }

  setCount(count) {
    _animationController.forward().then((value) => _animationController
        .reverse()
        .then((value) => (setState(() {
              _count = count;
            })))
        .then((value) => _animationController.forward()));
  }

  removeItem() {
    _animationController
        .reverse()
        .then((value) => (setState(() {
              _count--;
            })))
        .then((value) => _animationController.forward());
  }

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        duration: Duration(milliseconds: 200),
        lowerBound: 0.1,
        upperBound: 1,
        reverseDuration: Duration(milliseconds: 200),
        vsync: this)
      ..addListener(() {
        setState(() {});
      });
    _count = 0;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedActiveButton(
      callback: () {
        widget.callback();
      },
      child: Container(
        width: 70,
        height: 70,
        child: _count == 0
            ? Container()
            : Stack(
                alignment: Alignment.center,
                children: [
                  IconTheme(
                    data: Theme.of(context).iconTheme,
                    child: Icon(
                      FontAwesomeIcons.playCircle,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Transform.scale(
                      scale: _animationController.value,
                      child: Container(
                        width: 40,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          _count.toString(),
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
