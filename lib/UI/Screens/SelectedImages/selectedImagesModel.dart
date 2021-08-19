import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdfconverter/models/imageMeta.dart';

class SelectedModels extends ChangeNotifier {
  static SelectedModels _selectedModels = SelectedModels.init();
  static const platform =
      const MethodChannel("com.hack.imagesplayer/ImageGallery");

  List<ImageMeta> selectedImages;
  Map<String, int> selectedImagesMap;
  int selectedCount;
  bool _allSelected;

  SelectedModels.init() {
    selectedImages = new List();
    selectedImagesMap = new HashMap();
    selectedCount = 0;
    _allSelected = false;
  }

  @override
  void dispose() {
    super.dispose();
    SelectedModels.deInit();
  }

  SelectedModels.deInit() {
    // debugPrint("deInit");
    _selectedModels = null;
  }

  factory SelectedModels() {
    if (_selectedModels == null) _selectedModels = SelectedModels.init();
    return _selectedModels;
  }

  addImage(ImageMeta data) {

    if (allSelected) {
      clearImages();
      allSelected = false;
      notifyListeners();
    }

    data = data.getCopy();
    File file = new File(data.imageStoragePath);
    if (!file.existsSync()) {
      return false;
    }

    loadImageThumb(data);
    if (!selectedImagesMap.containsKey(data.id)) selectedImagesMap[data.id] = 0;
    selectedImagesMap[data.id] = selectedImagesMap[data.id] + 1;
    selectedCount++;
    notifyListeners();
    return true;
  }

  bool get allSelected => _allSelected;

  set allSelected(v) {
    _allSelected = v;
    notifyListeners();
  }

  addImages(List<ImageMeta> albumImages) {
    for (ImageMeta data in albumImages) {
      data = data.getCopy();
      File file = new File(data.imageStoragePath);
      if (!file.existsSync()) {
        continue;
      }
      // loadImageThumb(data);
      selectedImages.add(data);
      if (!selectedImagesMap.containsKey(data.id))
        selectedImagesMap[data.id] = 0;
      selectedImagesMap[data.id] = selectedImagesMap[data.id]+ 1;
      selectedCount++;
    }
    _allSelected = true;
    notifyListeners();
  }

  clearImages() {
    debugPrint("clearing ");
    selectedImagesMap.clear();
    selectedImages.clear();
    selectedCount = 0;
    _allSelected = false;
    notifyListeners();
    return true;
  }

  loadImageThumb(ImageMeta imageMeta) async {
    await platform.invokeMethod(
        "GetThumbImage", {"thumbUri": imageMeta.imageThumbPath}).then((value) {
      value.forEach((key, value) {
        imageMeta.imageThumb = Image.memory(value);
        selectedImages.add(imageMeta);
        notifyListeners();
      });
    });
  }

  getCount(ImageMeta data) {
    if (selectedImagesMap.containsKey(data.id))
      return selectedImagesMap[data.id];
    return 0;
  }

  removeImage(ImageMeta data) {
    if (selectedImages.contains(data)) {
      selectedImages.remove(data);
      if (selectedImagesMap.containsKey(data.id)) selectedImagesMap[data.id]--;
      selectedCount--;
      notifyListeners();
    }
  }

  reorderImage(oldIndex, newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = selectedImages.removeAt(oldIndex);
    selectedImages.insert(newIndex, item);
    notifyListeners();
  }
}
