import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdfconverter/UI/Screens/Editor/EditUi/cropUI.dart';
import 'package:pdfconverter/UI/Screens/Editor/EditUi/filterImageUI.dart';
import 'package:pdfconverter/UI/Screens/Editor/EditUi/rotateScaleUI.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:pdfconverter/declarations/enums.dart';
import 'package:pdfconverter/models/imageMeta.dart';
import 'package:pdfconverter/platform/EditorChannel.dart';
import 'package:pdfconverter/util/Editor/Params/ImageRatio.dart';
import 'package:pdfconverter/util/Editor/Params/cropParams.dart';
import 'package:pdfconverter/util/Editor/Params/filterParams.dart';
import 'package:pdfconverter/util/Editor/Params/rotateParams.dart';
import 'package:pdfconverter/util/Editor/imageEditor.dart';
import 'package:pdfconverter/util/functions/imageUtil.dart';
import 'package:provider/provider.dart';

import 'EditUi/borderFrameUI.dart';
import 'dart:ui' as ui;

class EditorUI extends StatefulWidget {
  final ImageMeta imageMeta;

  EditorUI(this.imageMeta);

  @override
  _EditorUIState createState() => _EditorUIState();
}

class _EditorUIState extends State<EditorUI> {
  PageLayoutMode pageLayoutMode;
  double imageWidth, imageHeight, areaWidth, areaHeight, height, width;
  Offset fixSize;

  ImageMeta img;
  Editor editorProvider;

  @override
  void initState() {
    pageLayoutMode = PageLayoutMode.portrait;
    img = widget.imageMeta;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    areaWidth = width;
    areaHeight = height * 0.8;
    editorProvider = Provider.of<Editor>(context, listen: false);

    Completer<ui.Image> completer = new Completer<ui.Image>();
    // get from meta
    img.image.image
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));

    return WillPopScope(
        child: Scaffold(
            backgroundColor: FakeWhite,
            body: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  SizedBox(
                    height: height * 0.1,
                  ),
                  FutureBuilder(
                      future: completer.future,
                      builder:
                          (BuildContext context, AsyncSnapshot<ui.Image> data) {
                        if (!data.hasData)
                          return Center(
                            child: Text("Loading..,"),
                          );
                        debugPrint( imageWidth.toString()+' '+imageHeight.toString());
                        imageWidth = data.data.width * 1.0;
                        imageHeight = data.data.height * 1.0;
                        fixSize = ImageUtil.getFitSize(
                            imageWidth, imageHeight, areaWidth, areaHeight);

                        editorProvider.init(ImageEditor.named(
                            source: widget.imageMeta,
                            crop: CropParams.none(),
                            rotate: RotateParams.none(),
                            filter: FilterParams(),
                            ratio: RatioParams(imageHeight, imageHeight)));
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Consumer<Editor>(builder: (context, editor, child) {
                              return Container(
                                height: areaHeight,
                                width: areaWidth,
                                margin: EdgeInsets.all(2),
                                child: Column(
                                  children: <Widget>[
                                    for (var i = 0;
                                        i < editor.undoStack.length;
                                        i++)
                                      Text(
                                        editor.undoStack
                                            .elementAt(i)
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )
                                  ],
                                ),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: widget.imageMeta.image
                                            .image // get from meta
                                        )),
                              );
                            }),
                            _card(widget.imageMeta)
                          ],
                        );
                      }),
                ]))),
        onWillPop: onWillPop);
  }

  _card(ImageMeta imageMeta) {
    var w = width * 0.6;
    var h = height * 0.08;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: width * 0.6,
        height: height * 0.08,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.black),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _cardElement(Icons.border_style, imageMeta, w / 4, h, 'border'),
            _cardElement(
                Icons.photo_filter_outlined, imageMeta, w / 4, h, 'filter'),
            _cardElement(Icons.rotate_left, imageMeta, w / 4, h, 'rotate'),
            _cardElement(Icons.crop, imageMeta, w / 4, h, 'crop'),
          ],
        ),
      ),
    );
  }

  _cardElement(icon, ImageMeta imageMeta, w, h, key) {
    return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.black),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(
            padding: EdgeInsets.all(3),
            alignment: Alignment.center,
            child: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  icon,
                  color: White,
                  size: 25,
                ),
                onPressed: () async {
                  var result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return ListenableProvider<Editor>.value(
                          value: editorProvider,
                          child: Builder(builder: (context) {
                            if (key == 'crop')
                              return CropUI(
                                image: imageMeta.image,
                                pageLayoutMode: pageLayoutMode,
                                imageSize: Offset(imageWidth, imageHeight),
                                widgetSize:
                                    ImageUtil.scaleDown(fixSize, r: 0.5),
                              );
                            else if (key == 'rotate')
                              return RotateScaleUI(
                                image: imageMeta.image,
                                pageLayoutMode: pageLayoutMode,
                                imageSize: Offset(imageWidth, imageHeight),
                                widgetSize:
                                    ImageUtil.scaleDown(fixSize, r: 0.5),
                                rotateParams:
                                    editorProvider?.editor?.rotate ?? null,
                              );
                            else if (key == 'filter')
                              return FilterImageUI(
                                image: imageMeta.image,
                                pageLayoutMode: pageLayoutMode,
                                imageSize: Offset(imageWidth, imageHeight),
                                widgetSize:
                                    ImageUtil.scaleDown(fixSize, r: 0.5),
                              );
                            else if (key == 'border')
                              return BorderFrameUI(
                                image: imageMeta.image,
                                pageLayoutMode: pageLayoutMode,
                                imageSize: Offset(imageWidth, imageHeight),
                                widgetSize:
                                    ImageUtil.scaleDown(fixSize, r: 0.5),
                              );
                            return Container();
                          }));
                    }),
                  );
                  if (result == null) return;
                  result = await json.decode(result);
                  EditorChannel.memoryToMemory(img.imageStoragePath, result)
                      .then((value) => {
                            setState(() {
                              img.image = Image.memory(value);
                            })
                          });
                }),
          )
        ]));
  }

  Future<bool> onWillPop() async {
    Navigator.pop(context, 'true');
    return true;
  }
}
