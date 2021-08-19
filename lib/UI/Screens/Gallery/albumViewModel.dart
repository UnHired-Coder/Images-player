import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdfconverter/UI/Screens/SelectedImages/selectedImagesModel.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../models/album.dart';
import '../../../models/imageMeta.dart';

class AlbumViewModel extends ChangeNotifier {
  static const platform =
      const MethodChannel("com.hack.imagesplayer/ImageGallery");

  SelectedModels selectedImagesModels;
  HashMap<String, AlbumListController> mp;
  List<Album> albums;
  bool loadingAlbums;
  bool loadingAlbumImages;
  String _selected;

  AlbumViewModel() {
    selectedImagesModels = SelectedModels();
    mp = new HashMap();
    albums = [];
    loadingAlbums = false;
    loadingAlbumImages = false;
    _selected = "";
    getAlbumModels();
  }

  String get selected => _selected;

  void setSelected(String albumId) async {
    _selected = albumId;
    notifyListeners();
  }

  getAlbumModels() async {
    if (await Permission.storage.request().isGranted) {
      try {
        loadingAlbums = true;
        await platform.invokeMethod("GetGalleryBuckets").then((buckets) async {
          buckets.forEach((encodedAlbumModel, byteArray) {
            Album album =
                new Album.fromJson(json.decode(encodedAlbumModel), byteArray);
            ScrollController scrollController = new ScrollController();
            albums.add(album);
            mp[album.albumName] =
                new AlbumListController(album, new List(), scrollController);
          });
        }).then((value) async{
          if (_selected == "" && albums != null && albums.length != 0) {
            setSelected(albums[0].albumName);
            await getData(albums[0].albumName);
          }
          loadingAlbums = false;
          notifyListeners();
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    loadingAlbums = false;
    notifyListeners();
    return;
  }

  Future<Uint8List> loadImageThumb(String imageThumbPath) async {
    Uint8List res;
    await platform.invokeMethod(
        "GetThumbImage", {"thumbUri": imageThumbPath}).then((value) {
      value.forEach((key, value) {
        // debugPrint(key.toString());
        res = value;
      });
    });
    return res;
  }

  getData(String selected) async {
    try {
      loadingAlbumImages = true;
      notifyListeners();
      if (mp[selected] == null)
        mp[selected] = new AlbumListController(
            new Album(), new List<ImageMeta>(), new ScrollController());
      await platform.invokeMethod("GetGallery", {
        "albumId": selected,
      }).then((value) async {
        value.forEach((encodedImageMeta) {
          mp[selected]
              .albumImages
              .add(new ImageMeta.fromJson(json.decode(encodedImageMeta)));
        });
      }).then((value) {
        loadingAlbumImages = false;
        notifyListeners();
      });
    } catch (e) {
      // debugPrint(e.toString());
    }
    return;
  }

  get allSelected => selectedImagesModels.allSelected;

  set allSelected(v) => selectedImagesModels.allSelected = v;

  addAllImagesImage() {
    removeAllImage();
    selectedImagesModels.addImages(mp[selected].albumImages);
  }

  removeAllImage() {
    selectedImagesModels.clearImages();
  }

  addImage(ImageMeta data) {
    bool res = selectedImagesModels.addImage(data);
    return res;
  }

  getCount(ImageMeta data) {
    return selectedImagesModels.getCount(data);
  }

  removeImage(ImageMeta data) {
    selectedImagesModels.removeImage(data);
  }

  reorderImage(oldIndex, newIndex) {
    selectedImagesModels.reorderImage(oldIndex, newIndex);
  }

  disposeSelectedModel() {}
}
