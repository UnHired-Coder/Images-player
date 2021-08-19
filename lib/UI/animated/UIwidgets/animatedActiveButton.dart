import 'package:flutter/material.dart';

class AnimatedActiveButton extends StatefulWidget {
  final Function callback;
  final IconData activeIcon;
  final IconData inActiveIcon;
  final Widget child;

  AnimatedActiveButton(
      {this.callback, this.activeIcon, this.inActiveIcon, this.child});

  @override
  _AnimatedActiveButtonState createState() => _AnimatedActiveButtonState();
}

class _AnimatedActiveButtonState extends State<AnimatedActiveButton>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        upperBound: 1,
        lowerBound: 0.7,
        duration: Duration(milliseconds: 60),
        vsync: this)
      ..addListener(() {
        setState(() {});
      });
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return (widget.child != null)
        ? InkWell(
            onTap: onTap,
            child: widget.child,
          )
        : Transform.scale(
            scale: animationController.value,
            child: IconButton(
              onPressed: onTap,
              icon: IconTheme(
                data: theme.iconTheme,
                child: Icon(
                  widget.activeIcon,
                ),
              ),
            ),
          );
  }

  onTap() {
    if (animationController.isCompleted)
      animationController.reverse().then((value) {
        Future.delayed(Duration(milliseconds: 60), () {
          animationController.forward().then((value) => widget.callback.call());
        });
      });
    else
      animationController.forward().then((value) {
        Future.delayed(Duration(milliseconds: 60), () {
          animationController.reverse().then((value) => widget.callback.call());
        });
      });
  }
}
