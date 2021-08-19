import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

import 'package:pdfconverter/util/functions/platformUtil.dart';

class ImageMeta {
  String id;
  String displayName;
  String bucketDisplayName;
  String imageStoragePath;
  String imageDirectory;
  String imageThumbPath;
  String dateAdded;
  Image imageThumb;
  Image image;

  ImageMeta({
    this.id,
    this.displayName,
    this.bucketDisplayName,
    this.imageStoragePath,
    this.imageDirectory,
    this.imageThumbPath,
    this.dateAdded,
    this.imageThumb
  });

  ImageMeta getCopy(){
     return ImageMeta(
         id:this.id,
         displayName:this.displayName,
         bucketDisplayName:this.bucketDisplayName,
         imageStoragePath:this.imageStoragePath,
         imageDirectory:this.imageDirectory,
         imageThumbPath:this.imageThumbPath,
         dateAdded:this.dateAdded,
         imageThumb:this.imageThumb);
  }

  factory ImageMeta.fromJson(Map<String, dynamic> json) => ImageMeta(
        id: json["id"],
        displayName: json["displayName"],
        bucketDisplayName: json["bucketDisplayName"],
        imageStoragePath: getPath(json),
        imageDirectory: json["imageDirectory"],
        imageThumbPath: json["imageThumbPath"],
        dateAdded: json["dateAdded"],
        imageThumb: null
        // image: PlatformUtil.loadCompressedImage(json["imageStoragePath"])
        // image: Image.file(
        //   new File(json["imageStoragePath"]),
        //   width: 100,
        //   height: 100,
        //   fit: BoxFit.contain,
        // )
      );
  Future<Image> getFullImage(double width,double  height) async{
    if(this.image == null)
    await PlatformUtil.loadCompressedImage(this.imageStoragePath, width, height).then((value) => {
      this.image = value
    });
    return Future.delayed(Duration.zero,(){
      return this.image;
    });
  }

  static getPath(Map<String, dynamic> json) {
    // debugPrint(json.toString());
    return json["imageStoragePath"];
  }
}
