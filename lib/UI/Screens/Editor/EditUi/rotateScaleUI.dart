import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:pdfconverter/declarations/enums.dart';
import 'package:pdfconverter/util/Editor/Params/rotateParams.dart';
import 'package:pdfconverter/util/Editor/imageEditor.dart';
import 'package:provider/provider.dart';

class RotateScaleUI extends StatefulWidget {
  final Image image;
  final PageLayoutMode pageLayoutMode;
  final Offset widgetSize;
  final Offset imageSize;
  final RotateParams rotateParams;

  RotateScaleUI(
      {@required this.image,
      this.pageLayoutMode = PageLayoutMode.portrait,
      @required this.imageSize,
      @required this.widgetSize,
      this.rotateParams});

  @override
  _RotateScaleUIState createState() => _RotateScaleUIState();
}

class _RotateScaleUIState extends State<RotateScaleUI>
    with TickerProviderStateMixin {
  double angle, scale;
  double rotations;
  bool flipped;
  AnimationController _controller;
  RotateType rotateType;
  Editor editor;
  RotateParams rotateParams;

  AnimationController r090ctrl;
  Animation<double> r090anm;
  ValueNotifier valueNotifier;
  Offset offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: pi,
    )..addListener(() {
        setState(() {});
      });
    rotateType = RotateType.FREEHAND;
    angle = 0.0;
    rotations = 0;
    flipped = false;
    offset = Offset(widget.widgetSize.dx, widget.widgetSize.dy);
    valueNotifier = ValueNotifier<Offset>(offset);
    rotateParams = widget.rotateParams != null
        ? RotateParams(widget.rotateParams.degree, widget.rotateParams.rotation,
            widget.rotateParams.flipped)
        : RotateParams(angle.round(), rotations, flipped);

    var h = widget.widgetSize.dy;
    var w = widget.widgetSize.dx;
    if (w > h) {
      var t = w;
      w = h;
      h = t;
    }
    var a = atan(h / w);
    var l1 = (w / 2) /
        cos(a -
            (widget.rotateParams != null
                    ? widget.rotateParams.degree.abs()
                    : angle) *
                pi /
                180);
    var l2 = sqrt(pow(w / 2, 2) + pow(h / 2, 2));
    scale = l2 / l1;
    // debugPrint(widget.rotateParams.toString());

    r090ctrl =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    r090anm = Tween<double>(begin: 0, end: pi / 2).animate(r090ctrl);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    r090ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    editor = Provider.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double dx = widget.widgetSize.dx;
    double dy = widget.widgetSize.dy;

    double box_dx = dx;
    double box_dy = dy;

    return WillPopScope(
      onWillPop: () async {
        debugPrint(
            rotateParams.toString() + widget?.rotateParams?.degree.toString());
        if (widget?.rotateParams?.degree == rotateParams.degree &&
            widget?.rotateParams?.rotation == rotateParams.rotation &&
            widget?.rotateParams?.flipped == rotateParams.flipped) {
          Navigator.pop(context);
          return true;
        }
        Navigator.pop(context, rotateParams.toString());
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: r090anm,
                      builder: (context, child) {
                        width = MediaQuery.of(context).size.width;
                        height = MediaQuery.of(context).size.height;
                        return ValueListenableBuilder(
                          valueListenable: valueNotifier,
                          builder: (context, value, child) {
                            dx = value.dx;
                            dy = value.dy;

                            return GestureDetector(
                              onHorizontalDragUpdate: (details){
                                _dragRotateUpdate(details, width);
                              },
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      child: AnimatedBuilder(
                                          animation: _controller,
                                          builder: (context, wid) {
                                            return Transform.rotate(
                                              angle: rotateParams.rotation +
                                                  r090anm.value,
                                              child: Transform(
                                                alignment:
                                                    FractionalOffset.center,
                                                transform: Matrix4.rotationY(
                                                    -_controller.value),
                                                child: Container(
                                                  height: box_dy,
                                                  width: box_dx,
                                                  child: Center(
                                                    child: Transform.scale(
                                                      scale: scale,
                                                      child: Transform.rotate(
                                                        angle:
                                                            rotateParams.degree *
                                                                pi /
                                                                180,
                                                        child: Container(
                                                          alignment:
                                                              FractionalOffset
                                                                  .center,
                                                          height: box_dy,
                                                          width: box_dx,
                                                          decoration: BoxDecoration(
                                                              color: Colors.red,
                                                              image:
                                                                  DecorationImage(
                                                                      image: widget
                                                                          .image
                                                                          .image)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    child: ClipRect(
                                      child: Container(
                                        height: height,
                                        width: (width - dx) / 2,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      right: 0,
                                      child: ClipRect(
                                        child: Container(
                                          height: height,
                                          width: (width - dx) / 2,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      )),
                                  Positioned(
                                      right: (width - dx) / 2,
                                      child: ClipRect(
                                        child: Container(
                                          height: (height - dy) / 2,
                                          width: dx,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      )),
                                  Positioned(
                                      right: (width - dx) / 2,
                                      bottom: 0,
                                      child: ClipRect(
                                        child: Container(
                                          height: (height - dy) / 2,
                                          width: dx,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      )),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Positioned(
                        bottom: 0,
                        child: Card(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () async {
                                      await r090ctrl.forward().then((value) {
                                        setState(() {
                                          rotateParams.rotation =
                                              (rotateParams.rotation + pi / 2) %
                                                  (2 * pi);
                                          r090ctrl.reset();
                                          var xx = offset.dx;
                                          var yy = offset.dy;
                                          offset = Offset(yy, xx);
                                          valueNotifier.value = offset;
                                        });
                                      });
                                    },
                                    child: Icon(
                                      Icons.rotate_90_degrees_ccw,
                                      color: Black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 40,
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () {
                                      if (_controller.isCompleted)
                                        _controller.reverse().then((value) => {
                                              widget.rotateParams.flipped =
                                                  !widget.rotateParams.flipped
                                            });
                                      else
                                        _controller.forward().then((value) => {
                                              widget.rotateParams.flipped =
                                                  !widget.rotateParams.flipped
                                            });
                                    },
                                    child: Icon(
                                      Icons.flip,
                                      color: Black,
                                      size: 24,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _dragRotateUpdate(DragUpdateDetails details, width) {
    double sample = (90/width);
    angle = details.localPosition.dx * sample - 45;
    var h = widget.widgetSize.dy;
    var w = widget.widgetSize.dx;
    if (w > h) {
      var t = w;
      w = h;
      h = t;
    }
    var a = atan(h / w);
    var l1 = (w / 2) / cos(a - angle.abs() * pi / 180);
    var l2 = sqrt(pow(w / 2, 2) + pow(h / 2, 2));

    setState(() {
      rotateParams.degree = angle.round();
      scale = l2 / l1;
    });
  }
}
