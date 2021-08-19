import 'dart:typed_data';
import 'package:flutter/services.dart';

class EditorChannel{

  static const MethodChannel _channel = const MethodChannel('com.hack.imagesplayer/ImageEditor');
  static MethodChannel get channel => _channel;

  static Future<Uint8List> memoryToMemory(String path, double size) async{
       final result = await _channel.invokeMethod('memoryToMemory', {
         'image':path,
         'size':size
       });
       return result;
  }
}