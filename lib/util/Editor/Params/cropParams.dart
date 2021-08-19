import 'dart:ui';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:pdfconverter/util/Editor/params.dart';

class CropParams implements Param {
  final num x;
  final num y;
  final num width;
  final num height;

  CropParams.none({this.x = 0, this.y = 0, this.width = 0, this.height = 0});
  CropParams({
    this.x = 0,
    this.y = 0,
    @required this.width,
    @required this.height,
  })  : assert(width > 0 && height > 0),
        assert(x >= 0, y >= 0);

  factory CropParams.fromRect(Rect rect) {
    return CropParams(
      x: fixNumber(rect.left),
      y: fixNumber(rect.top),
      width: fixNumber(rect.width),
      height: fixNumber(rect.height),
    );
  }

  factory CropParams.fromOffset(Offset start, Offset end) {
    return CropParams(
      x: fixNumber(start.dx),
      y: fixNumber(start.dy),
      width: fixNumber(end.dx - start.dx),
      height: fixNumber(end.dy - start.dy),
    );
  }

  static int fixNumber(num number) {
    return number.round();
  }

  @override
  String get key => "clip";

  @override
  Map<String, Object> get encodedValue => {
        "x": x.round(),
        "y": y.round(),
        "width": width.round(),
        "height": height.round(),
      };


  String  toString(){
    final Map<String, dynamic> param = new Map<String, dynamic>();
    param['x'] = this.x.round();
    param['y'] = this.y.round();
    param['width'] = this.width.round();
    param['height'] = this.height.round();
    return json.encode(param);
  }

  @override
  bool get canIgnore => width <= 0 || height <= 0;
}