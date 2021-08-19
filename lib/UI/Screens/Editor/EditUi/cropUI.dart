import 'package:flutter/material.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:pdfconverter/declarations/enums.dart';
import 'package:pdfconverter/util/Editor/Params/cropParams.dart';
import 'package:pdfconverter/util/crop/CustomCrop.dart';

class CropUI extends StatefulWidget {
  final Image image;
  final PageLayoutMode pageLayoutMode;
  final Offset widgetSize;
  final Offset imageSize;

  CropUI(
      {@required this.image,
      this.pageLayoutMode = PageLayoutMode.portrait,
      @required this.imageSize,
      @required this.widgetSize});

  @override
  _CropUIState createState() => _CropUIState();
}

class _CropUIState extends State<CropUI> {
  final cropKey = GlobalKey<CropState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        CropParams cropParams = CropParams(
            x: cropKey.currentState.area.left,
            y: cropKey.currentState.area.top,
            width: cropKey.currentState.area.right,
            height: cropKey.currentState.area.bottom);
        Navigator.pop(context, cropParams.toString());
        return true;
      },
      child: Scaffold(
        body: Container(
          color: Grey,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
            height: widget.widgetSize.dy,
            width: widget.widgetSize.dx,
            child: Center(
              child: Container(
                height: widget.widgetSize.dy,
                width: widget.widgetSize.dx,
                child: Crop(
                  maximumScale: 1,
                  key: cropKey,
                  aspectRatio: widget.imageSize.dx / widget.imageSize.dy,
                  image: widget.image.image,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
