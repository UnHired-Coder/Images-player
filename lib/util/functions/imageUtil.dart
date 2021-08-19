import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'dart:ui' as ui;

class ImageUtil {
  static Offset getFitSize(iw, ih, arw, arh) {
    double widthRatio = (arw / iw);
    double heightRatio = (arh / ih);
    double rt = min(widthRatio, heightRatio);
    return Offset(rt * iw, rt * ih);
  }

  static Offset scaleDown(Offset offset, {double r = 0.8}){
    return Offset(offset.dx * r, offset.dy * r);
  }

  static Offset fitImage(Offset i, Offset w){
    if(i.dx > w.dx && i.dy > w.dy)
      return getFitSize(i.dx, i.dy, w.dx, w.dy);
    else
    return i;
  }

  static Future<ui.Image> getImage({ @required String path}) async{
    Completer<ImageInfo> completer = Completer();
    Image img =  Image.file(File(path));
    img.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _){
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }
}
