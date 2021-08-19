import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

abstract class PlatformUtil {
  static const platform = const MethodChannel("com.hack.imagesplayer/Util");

  static Future<Image> loadCompressedImage(
      String imagePath, double w, double h) async {
    Image result;
    await platform.invokeMethod('loadCompressedImage',
        {'imagePath': imagePath, 'width': w, 'height': h}).then((value) {
      result = Image.memory(value);
    });
    return result;
  }
}
