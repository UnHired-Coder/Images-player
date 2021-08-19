import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:pdfconverter/models/imageMeta.dart';

class Album {
  String albumId;
  String albumName;
  Uint8List albumArtBytes;
  int count;

  Album({this.albumId, this.albumName, this.albumArtBytes, this.count});

  factory Album.fromJson(Map<String, dynamic> json, bytes) => Album(
      albumId: json["albumId"],
      albumName: json["albumName"],
      albumArtBytes: bytes,
      count: int.parse(json["count"]));
}

class AlbumListController {
  Album album;
  List<ImageMeta> albumImages;
  ScrollController scrollController;

  AlbumListController(this.album, this.albumImages, this.scrollController);
}
