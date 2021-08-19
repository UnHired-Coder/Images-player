import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:pdfconverter/models/imageMeta.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerSimple extends StatefulWidget {
  final ImageMeta imageMeta;

  ImageViewerSimple({this.imageMeta});

  @override
  _ImageViewerSimpleState createState() => _ImageViewerSimpleState();
}

class _ImageViewerSimpleState extends State<ImageViewerSimple> {
  static const platform =
      const MethodChannel("com.hack.imagesplayer/ImageGallery");
  bool loading;
  String imageFullPath;

  @override
  void initState() {
    super.initState();
    loading = true;
    Future.delayed(Duration(milliseconds: 300)).then((value) => {getData()});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        shadowColor: PGrey,
        iconTheme: theme.iconTheme,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  widget.imageMeta.imageDirectory,
                  style: theme.textTheme.headline2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                  icon: Icon(
                    Icons.info,
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.all(10),
                          backgroundColor: theme.scaffoldBackgroundColor,
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            color: theme.scaffoldBackgroundColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Row(
                                    children: [
                                      headText("Name: "),
                                      valueText(widget.imageMeta.displayName)
                                    ],
                                  ),
                                ),

                                SizedBox(height: 10,),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Row(
                                    children: [
                                      headText("Path: "),
                                      Container(width: MediaQuery.of(context).size.width * 0.5,child: valueText(widget.imageMeta.imageDirectory),)
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Row(
                                    children: [
                                      headText("Date Added: "),
                                      Container(width: MediaQuery.of(context).size.width * 0.4,child: valueText(widget.imageMeta.dateAdded),)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  })
            ],
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: White),
        child: loading
            ? CircularProgressIndicator(
                backgroundColor: theme.accentColor,
                strokeWidth: 8,
              )
            : PhotoView(
                imageProvider: Image.file(new File(imageFullPath)).image,
                backgroundDecoration:
                    BoxDecoration(color: theme.scaffoldBackgroundColor),
                enableRotation: true,
              ),
      ),
    );
  }

  headText(val) {
    return Text(
      val,
      style: Theme.of(context).textTheme.headline3,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  valueText(val) {
    return Text(
      val,
      style: Theme.of(context).textTheme.headline4,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  getData() async {
    await platform.invokeMethod("GetGalleryImage", {
      "imageDirectory": widget.imageMeta.imageDirectory,
      "displayName": widget.imageMeta.displayName
    }).then((value) async {
      value.forEach((key, value) {
        setState(() {
          imageFullPath = value;
          loading = false;
        });
      });
    });
  }
}
