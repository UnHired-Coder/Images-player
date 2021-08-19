import 'dart:convert';

import 'package:pdfconverter/util/Editor/Params/ImageRatio.dart';
import 'package:pdfconverter/util/Editor/params.dart';
import 'dart:math' as math;

class RotateParams implements Param {
  int degree;
  double rotation;
  bool flipped;

  RotateParams.none({this.degree = 0, this.rotation = 0, this.flipped = false});

  RotateParams(this.degree, this.rotation, this.flipped);

  RotateParams.fromJson(Map<String, dynamic> json) {
    this.degree = json['degree'];
    this.rotation = json['rotation'];
    this.flipped = json['flipped'];
  }

  RotateParams.radian(double radian) {
    degree = (radian / math.pi * 180).toInt();
    rotation = 0;
    flipped = false;
  }

  @override
  String get key => "rotate";

  @override
  Map<String, Object> get encodedValue => {
        "degree": degree,
        "rotation": rotation,
        "flipped": flipped,
      };

  String toString() {
    final Map<String, dynamic> param = new Map<String, dynamic>();
    param['degree'] = this.degree;
    param['rotation'] = this.rotation;
    param['flipped'] = this.flipped;
    return json.encode(param);
  }

  @override
  bool get canIgnore =>
      (degree % 360 == 0 && rotation == 0 && flipped == false);
}
