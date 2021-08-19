import 'dart:convert';
import 'package:pdfconverter/util/Editor/params.dart';

class RatioParams extends Param {
  double width;
  double height;
  double ratio;

  RatioParams(w, h) {
    this.width = w;
    this.height = h;
    this.ratio = this.width / this.height;
  }

  double get w => this.width;

  double get h => this.height;

  double get r => this.ratio;

  @override
  bool get canIgnore {
    return false;
  }

  @override
  Map<String, Object> get encodedValue =>
      {'h': this.h, 'w': this.w, 'r': this.r};

  String toString() {
    final Map<String, dynamic> param = new Map<String, dynamic>();
    param['h'] = this.h;
    param['w'] = this.w;
    param['r'] = this.r;
    return json.encode(param);
  }

  @override
  String get key => 'ratio';
}
