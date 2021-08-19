import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:pdfconverter/models/imageMeta.dart';
import 'package:pdfconverter/util/Editor/Params/ImageRatio.dart';
import 'package:pdfconverter/util/Editor/Params/cropParams.dart';
import 'package:pdfconverter/util/Editor/Params/filterParams.dart';
import 'package:pdfconverter/util/Editor/Params/rotateParams.dart';

class Editor extends ChangeNotifier {
  Queue<ImageEditor> undoStack;
  Queue<ImageEditor> redoStack;
  ImageEditor editor;

  Editor(ImageEditor editor) {
    undoStack = Queue<ImageEditor>();
    redoStack = Queue<ImageEditor>();
    this.editor = editor;
  }

  init(ImageEditor editor) {
    undoStack = Queue<ImageEditor>();
    redoStack = Queue<ImageEditor>();
    this.editor = editor;
  }

  void rotate(RotateParams params) {
    if (params.canIgnore) return;
    undoStack.addLast(editor.createSnapShot());
    editor.rotate = RotateParams(params.degree, params.rotation, params.flipped);
    notifyListeners();
  }

  crop(rect) {
    undoStack.addLast(editor.createSnapShot());
    editor.crop = CropParams.fromRect(rect);
    notifyListeners();
  }

  undo() {
    if (!canUndo) return;

    editor = undoStack.last;
    undoStack.removeLast();
    redoStack.addLast(editor);
    notifyListeners();
  }

  redo() {
    if (!canRedo) return;
    editor = redoStack.last;
    redoStack.removeLast();
    undoStack.addLast(editor);
    // debugPrint('revert');
    notifyListeners();
  }

  get canUndo => undoStack.length != 0;

  get canRedo => redoStack.length != 0;
}

class ImageEditor {
  ImageMeta source;
  CropParams crop;
  RotateParams rotate;
  FilterParams filter;
  RatioParams ratio;

  ImageEditor.empty();

  ImageEditor.named({this.source, this.crop, this.rotate, this.filter, this.ratio});
  ImageEditor(this.source, this.crop, this.rotate, this.filter, this.ratio);

  ImageEditor createSnapShot() {
    return new ImageEditor(
        this.source, this.crop, this.rotate, this.filter, this.ratio);
  }

  void restoreSnapShot(ImageEditor previous) {
    this.source = previous.source;
    this.crop = previous.crop;
    this.rotate = previous.rotate;
    this.filter = previous.filter;
    this.ratio = previous.ratio;
  }
}
