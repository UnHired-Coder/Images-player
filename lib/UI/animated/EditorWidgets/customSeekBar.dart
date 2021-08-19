import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomSeekBar extends StatefulWidget {
  final Function onDragUpdate;
  final Function onDragEnd;
  final Axis direction;
  final double min;
  final double max;
  final double initial;
  final bool labelEnabled;
  final int divisions;
  final value;

  CustomSeekBar(
      {@required this.onDragUpdate,
      @required this.onDragEnd,
      this.direction = Axis.vertical,
      this.min = 0.0,
      this.max = 10,
      this.labelEnabled,
      this.divisions,
      this.value=0.0,
      this.initial});

  @override
  _CustomSeekBarState createState() => _CustomSeekBarState();
}

class _CustomSeekBarState extends State<CustomSeekBar>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;
  double valueHolder;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.8,
      upperBound: 1.0,
    )..addListener(() {
        setState(() {});
      });
    valueHolder = (widget.initial != null)
        ? widget.initial
        : (widget.max + widget.max) / 2;
    _scale = 0;
    _controller.forward();
    valueHolder = widget.value * 1.0;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return Container(
      alignment: Alignment.centerLeft,
      height: 40,
      margin: EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onVerticalDragEnd: _onDragEnd,
        onHorizontalDragEnd: _onDragEnd,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                height: 10 + _scale * 30,
                width: 200,
              ),
            ),
            Container(
              height: 10 + _scale * 30,
              width: 200,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  thumbColor: Colors.black,
                  inactiveTickMarkColor: Colors.grey.withOpacity(0.6),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                ),
                child: Slider(
                    inactiveColor: Colors.transparent,
                    value: valueHolder,
                    min: widget.min,
                    max: widget.max,
                    label: widget.labelEnabled ? valueHolder.round().toString() : null,
                    divisions: widget.divisions,
                    onChangeStart: (v) {
                      _controller.reverse();
                    },
                    onChangeEnd: (v) {
                      _controller.forward();
                      widget.onDragEnd(v);
                    },
                    onChanged: (value) {
                      _onDragUpdate(value);
                      setState(() {
                        valueHolder = value;
                      });
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _onDragEnd(DragEndDetails d) {
    _controller.reverse();
    _controller.forward();
  }

  void _onDragUpdate(double d) {
    widget.onDragUpdate(d);
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => true;
}
