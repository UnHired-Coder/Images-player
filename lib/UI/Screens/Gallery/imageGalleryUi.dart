import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdfconverter/UI/Screens/SelectedImages/selectedImages.dart';
import 'package:pdfconverter/UI/Screens/SelectedImages/selectedImagesModel.dart';
import 'package:pdfconverter/UI/animated/UIwidgets/AnimatedProgress.dart';
import 'package:pdfconverter/UI/animated/UIwidgets/animatedActiveButton.dart';
import 'package:pdfconverter/UI/animated/UIwidgets/animatedHeaderButton.dart';
import 'package:pdfconverter/util/PrefsManager.dart';
import 'package:pdfconverter/util/ThemesManager.dart';
import '../../animated/UIwidgets/customAnimetedList.dart';
import 'file:///F:/PDF_CONVERTER/pdf_converter/lib/UI/animated/UIwidgets/animatedSelectWidget.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:provider/provider.dart';

import 'albumViewModel.dart';
import 'dart:math' as math;

class ImageGalleryUi extends StatefulWidget {
  ImageGalleryUi({Key key}) : super(key: key);

  @override
  _ImageGalleryUiState createState() => _ImageGalleryUiState();
}

class _ImageGalleryUiState extends State<ImageGalleryUi> {
  List<Image> selectedImages = [];
  ScrollController selectedImagesController;
  CustomAnimatedList animatedList = new CustomAnimatedList();
  AlbumViewModel selectedAlbumsModelF;
  final AnimatedHeaderButtonController animatedHeaderButtonController =
      new AnimatedHeaderButtonController();
  ValueNotifier<bool> allSelectedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    selectedAlbumsModelF = Provider.of<AlbumViewModel>(context, listen: false);
    selectedImagesController = new ScrollController();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  addImage(image) {
    if (allSelectedNotifier.value) {
      allSelectedNotifier.value = false;
    }
    bool success = selectedAlbumsModelF.addImage(image);
    if (!success) debugPrint("Image does not exists!!");
  }

  removeImage(image) {
    selectedAlbumsModelF.removeImage(image);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var selectedImagesProviderPass = Provider.of<AlbumViewModel>(context);
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        textTheme: theme.appBarTheme.textTheme,
        leading: null,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        iconTheme: theme.appBarTheme.iconTheme,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AnimatedActiveButton(
                  activeIcon: Icons.menu_rounded,
                  inActiveIcon: Icons.menu_rounded,
                  callback: () {
                    selectedAlbumsModelF.disposeSelectedModel();
                    showModalBottomSheet(
                        context: context,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        builder: (BuildContext bc) {
                          return Container(
                              height: screenHeight * 0.6,
                              child: CustomAnimatedList());
                        });
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "Pick photos",
                  style: theme.appBarTheme.textTheme.headline2,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<SelectedModels>(
                    builder: (context, selectedImagesModel, child) {
                  return InkWell(
                    child: (selectedImagesModel.selectedCount == 0)
                        ? Container()
                        : Container(
                            height: 40,
                            width: 50,
                            alignment: Alignment.center,
                            // color: Colors.red,
                            child: Row(
                              children: [
                                Text(
                                  "Play",
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.appBarTheme.textTheme.headline2,
                                ),
                                SizedBox(width: 5,),
                                IconTheme(data: theme.iconTheme, child: Icon(FontAwesomeIcons.play))
                              ],
                            ),
                          ),
                    onTap: () async {
                      (selectedImagesModel.selectedCount != 0)
                          ? Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                              return ListenableProvider<AlbumViewModel>.value(
                                value: selectedImagesProviderPass,
                                child: SelectedImages(
                                  totalCount: selectedImagesProviderPass
                                      .selectedImagesModels
                                      .selectedImages
                                      .length,
                                ),
                              );
                            }))
                          : debugPrint("Nothing selected");
                    },
                  );
                }),
                SizedBox(
                  width: 15,
                )
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * 0.75,
              child: Consumer<AlbumViewModel>(
                  builder: (context, albumsViewModel, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: screenHeight,
                        width: screenWidth * 0.28,
                        color: theme.scaffoldBackgroundColor,
                        padding: EdgeInsets.only(top: 5),
                        child: Builder(builder: (context) {
                          if (albumsViewModel.albums == null ||
                              albumsViewModel.albums.length == 0)
                            return Container();
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              return Opacity(
                                opacity: albumsViewModel.selected ==
                                        albumsViewModel.albums[index].albumName
                                    ? 1
                                    : 0.3,
                                child: InkWell(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                width: math.min(
                                                    100, screenWidth * 0.23),
                                                height: math.min(
                                                    100, screenWidth * 0.23),
                                                margin: EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  image: DecorationImage(
                                                      image: Image.memory(
                                                              albumsViewModel
                                                                  .albums[index]
                                                                  .albumArtBytes)
                                                          .image,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              Container(
                                                width: math.min(
                                                    100, screenWidth * 0.23),
                                                child: Text(
                                                    albumsViewModel
                                                        .albums[index]
                                                        .albumName,
                                                    style: theme.appBarTheme
                                                        .textTheme.headline2,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                          IconTheme(
                                            data: albumsViewModel.selected ==
                                                    albumsViewModel
                                                        .albums[index].albumName
                                                ? theme.iconTheme
                                                : IconThemeData(
                                                    size: 0,
                                                    color: theme
                                                        .scaffoldBackgroundColor),
                                            child: Icon(
                                                FontAwesomeIcons.caretLeft),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    if (albumsViewModel.selected ==
                                        albumsViewModel.albums[index].albumName)
                                      return;
                                    albumsViewModel.setSelected(albumsViewModel
                                        .albums[index].albumName);
                                    albumsViewModel.getData(albumsViewModel
                                        .albums[index].albumName);
                                  },
                                ),
                              );
                            },
                            itemCount: albumsViewModel.albums.length,
                          );
                        })),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: screenHeight * 0.05,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 10, top: 0),
                                  width: screenWidth * 0.45,
                                  child: Text(
                                    albumsViewModel.selected,
                                    style:
                                        theme.appBarTheme.textTheme.headline2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 10, top: 0),
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: allSelectedNotifier,
                                      builder: (context, value, child) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "All",
                                              style: theme.appBarTheme.textTheme
                                                  .headline2,
                                            ),
                                            CheckboxTheme(
                                              data: theme.checkboxTheme,
                                              child: Checkbox(
                                                  value: albumsViewModel
                                                      .allSelected,
                                                  onChanged: (change) {
                                                    if (change) {
                                                      albumsViewModel
                                                          .addAllImagesImage();
                                                    } else {
                                                      albumsViewModel
                                                          .removeAllImage();
                                                      animatedHeaderButtonController
                                                          .setCount(0);
                                                    }
                                                    animatedHeaderButtonController
                                                        ?.setCount(0);

                                                    allSelectedNotifier.value =
                                                        albumsViewModel
                                                            .allSelected;
                                                  }),
                                            )
                                          ],
                                        );
                                      },
                                    ))
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: theme.scaffoldBackgroundColor,
                              margin: EdgeInsets.all(5),
                              child: Builder(builder: (context) {
                                // if (albumsViewModel == null)
                                //   return Center(
                                //     child: Text(
                                //       "Loading.",
                                //       // "model = null",
                                //       style: theme.textTheme.headline4,
                                //     ),
                                //   );
                                // if (albumsViewModel.mp == null)
                                //   return Center(
                                //     child: Text(
                                //       "Loading..",
                                //       // "model.mp = null",
                                //       style: theme.textTheme.headline4,
                                //     ),
                                //   );
                                // if (albumsViewModel.mp.length == 0)
                                //   return Center(
                                //     child: Text(
                                //       "Loading...",
                                //       // "model.mp = empty",
                                //       style: theme.textTheme.headline4,
                                //     ),
                                //   );
                                // if (albumsViewModel
                                //         .mp[albumsViewModel.selected] ==
                                //     null)
                                //   return Center(
                                //     child: Text(
                                //       "Loading....",
                                //       // "model.mp[selected] = null",
                                //       style: theme.textTheme.headline4,
                                //     ),
                                //   );
                                // if (albumsViewModel.mp[albumsViewModel.selected]
                                //         .albumImages.length ==
                                //     0)
                                //   return Center(
                                //     child: Text(
                                //       "Loading.....",
                                //       // "model.mp[selected].images = empty",
                                //       style: theme.textTheme.headline4,
                                //     ),
                                //   );

                                if (albumsViewModel == null ||
                                    albumsViewModel.mp == null ||
                                    albumsViewModel.mp.length == 0 ||
                                    albumsViewModel.albums.length == 0 ||
                                    albumsViewModel
                                            .mp[albumsViewModel.selected] ==
                                        null ||
                                    albumsViewModel.mp[albumsViewModel.selected]
                                            .albumImages.length ==
                                        0)
                                  return Center(
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      child: AnimatedProgressIndicator(),
                                      decoration: BoxDecoration(),
                                    ),
                                  );
                                return GridView.builder(
                                  key: PageStorageKey<String>(
                                      albumsViewModel.selected),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              PrefsManager().getGridCount),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: FutureBuilder(
                                          builder: (context, data) {
                                            if (!data.hasData) {
                                              return Container();
                                            }
                                            return AnimatedSelectWidget(
                                              function: (v) {
                                                animatedHeaderButtonController
                                                    ?.setCount
                                                    ?.call(albumsViewModel
                                                            .selectedImagesModels
                                                            .selectedImages
                                                            .length +
                                                        1);
                                                addImageCb(v);
                                              },
                                              image: (albumsViewModel
                                                  .mp[albumsViewModel.selected]
                                                  .albumImages[index]),
                                              child: Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  margin: EdgeInsets.all(3),
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: PGrey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          image: DecorationImage(
                                                              image: Image.memory(
                                                                      data.data)
                                                                  .image,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            );
                                          },
                                          future: albumsViewModel
                                              .loadImageThumb(albumsViewModel
                                                  .mp[albumsViewModel.selected]
                                                  .albumImages[index]
                                                  .imageThumbPath)),
                                    );
                                  },
                                  itemCount: albumsViewModel
                                              .mp[albumsViewModel.selected]
                                              .album
                                              .count !=
                                          null
                                      ? albumsViewModel
                                          .mp[albumsViewModel.selected]
                                          .album
                                          .count
                                      : 0,
                                  controller: (albumsViewModel.albums == null ||
                                          albumsViewModel.albums.length == 0)
                                      ? null
                                      : albumsViewModel
                                          .mp[albumsViewModel.selected]
                                          .scrollController,
                                );
                              }),
                            ),
                          ),
                          ((albumsViewModel.loadingAlbumImages)
                              ? Container(
                                  // height:
                                  //     MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Center(
                                    child: LinearProgressIndicator(
                                      backgroundColor: Colors.grey,
                                    ),
                                  ),
                                )
                              : Container())
                        ],
                      ),
                    )
                  ],
                );
              }),
            ),
            Container(
                height: screenHeight * 0.15,
                width: screenWidth,
                color: theme.scaffoldBackgroundColor,
                padding: EdgeInsets.only(bottom: 3, top: 3),
                child: Consumer<SelectedModels>(
                    builder: (context, imagesModel, child) {
                  return Container(
                    color: theme.scaffoldBackgroundColor,
                    child: ValueListenableBuilder(
                        valueListenable: allSelectedNotifier,
                        builder: (context, value, child) {
                          return ReorderableListView(
                            scrollController: selectedImagesController,
                            padding:
                                EdgeInsets.only(left: 5, right: 5, bottom: 5),
                            scrollDirection: Axis.horizontal,
                            onReorder: (oldIdx, newIdx) {
                              imagesModel.reorderImage(oldIdx, newIdx);
                            },
                            header: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(0),
                              child: InkWell(
                                onTap: () {
                                  (imagesModel.selectedCount != 0)
                                      ? Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                          return ListenableProvider<
                                              AlbumViewModel>.value(
                                            value: selectedImagesProviderPass,
                                            child: SelectedImages(
                                              totalCount:
                                                  selectedImagesProviderPass
                                                      .selectedImagesModels
                                                      .selectedImages
                                                      .length,
                                            ),
                                          );
                                        }))
                                      : debugPrint("Nothing selected");
                                },
                                child: AnimatedHeaderButton(
                                  callback: () {
                                    if (selectedImages.isNotEmpty)
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return ListenableProvider<
                                            AlbumViewModel>.value(
                                          value: selectedImagesProviderPass,
                                          child: SelectedImages(
                                            totalCount:
                                                selectedImagesProviderPass
                                                    .selectedImagesModels
                                                    .selectedImages
                                                    .length,
                                          ),
                                        );
                                      }));
                                  },
                                  controller: animatedHeaderButtonController,
                                ),
                              ),
                            ),
                            children: allSelectedNotifier.value
                                ? <Widget>[]
                                : <Widget>[
                                    for (final imageMeta
                                        in imagesModel.selectedImages)
                                      Container(
                                        key: new UniqueKey(),
                                        color: theme.scaffoldBackgroundColor,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 16,
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                  child: IconTheme(
                                                    data: theme.iconTheme,
                                                    child: Icon(
                                                      Icons.cancel_outlined,
                                                      color: Colors.red,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    removeImage(imageMeta);
                                                    animatedHeaderButtonController
                                                        ?.setCount
                                                        ?.call(imagesModel
                                                            .selectedImages
                                                            .length);
                                                  }),
                                            ),
                                            Container(
                                              height: math.min(
                                                  80, screenHeight * 0.10),
                                              width: math.min(
                                                  80, screenWidth * 0.20),
                                              margin: EdgeInsets.all(1),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  image: DecorationImage(
                                                      image: imageMeta
                                                          .imageThumb.image,
                                                      fit: BoxFit.cover),
                                                  border: Border.all(
                                                      width: 3,
                                                      color:
                                                          theme.accentColor)),
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                          );
                        }),
                  );
                }))
          ],
        ),
      ),
    );
  }

  addImageCb(v) {
    addImage(v);
  }
}
