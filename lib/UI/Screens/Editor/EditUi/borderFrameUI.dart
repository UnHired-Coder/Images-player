import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pdfconverter/assets/colors/Swatchers.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:pdfconverter/declarations/enums.dart';
import 'package:pdfconverter/util/functions/imageUtil.dart';

class BorderFrameUI extends StatefulWidget {
  final Image image;
  final PageLayoutMode pageLayoutMode;
  final Offset widgetSize;
  final Offset imageSize;

  BorderFrameUI(
      {@required this.image,
      this.pageLayoutMode = PageLayoutMode.portrait,
      @required this.imageSize,
      @required this.widgetSize});

  @override
  _BorderFrameUIState createState() => _BorderFrameUIState();
}
const double MAX_IN_BORDER = 30.0;
const double MAX_OUT_BORDER = 0.40;

class _BorderFrameUIState extends State<BorderFrameUI> {
  double thickness;
  Color color;
  double width;
  BorderType borderType;
  Offset size;


  @override
  void initState() {
    super.initState();
    thickness = 1;
    color = White;
    width = 200;
    borderType = BorderType.none;
    size = ImageUtil.fitImage(widget.imageSize, widget.widgetSize);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, thickness.toString());
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Grey,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onHorizontalDragUpdate: (d) {
                        _dragRotateUpdate(d, width);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.transparent,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: size.dy,
                                width: size.dx,
                                color: color,
                              ),
                              Transform.scale(
                                scale: borderType == BorderType.BORDER_OUT
                                    ? 1 - thickness
                                    : 1,
                                child: Container(
                                  height: size.dy,
                                  width: size.dx,
                                  decoration: BoxDecoration(
                                      color: color,
                                      border: Border.all(
                                        color: color,
                                        width:
                                            borderType == BorderType.BORDER_IN
                                                ? thickness
                                                : 0,
                                      ),
                                      image: DecorationImage(
                                          image: widget.image.image)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 10,
                        left: 20,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Black, width: 2),
                                  borderRadius: BorderRadius.circular(500),
                                  color: color),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(bottom: 10),
                                height: 30,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: swatches.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                        onTap: () {
                                          setState(() {
                                            color = swatches[index];
                                          });
                                        },
                                        child: Container(
                                            height: 25,
                                            width: 25,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: swatches[index]),
                                            margin: EdgeInsets.only(
                                                left: 3, right: 3, top: 5),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  color = swatches[index];
                                                });
                                              },
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                              ),
                                            )));
                                  },
                                ))
                          ],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _dragRotateUpdate(DragUpdateDetails dragUpdateDetails, double width) {
    setState(() {
      if (dragUpdateDetails.localPosition.dx < width / 2) {
        double sample = MAX_OUT_BORDER / (width / 2);
        borderType = BorderType.BORDER_OUT;
        thickness =
            ((width / 2).round() - dragUpdateDetails.localPosition.dx.round()) *
                sample;
      } else {
        double sample = MAX_IN_BORDER / (width / 2);
        borderType = BorderType.BORDER_IN;
        thickness =
            (dragUpdateDetails.localPosition.dx.round() - (width / 2).round()) *
                sample;
      }
    });
  }
}
