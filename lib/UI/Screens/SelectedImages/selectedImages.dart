import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdfconverter/UI/Screens/Gallery/albumViewModel.dart';
import 'package:pdfconverter/UI/Screens/SecondaryScreens/timerStory.dart';
import 'package:pdfconverter/UI/Screens/SelectedImages/selectedImagesModel.dart';
import 'package:pdfconverter/UI/animated/UIwidgets/animatedActiveButton.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class SelectedImages extends StatefulWidget {
  final int totalCount;

  SelectedImages({Key key, this.totalCount}) : super(key: key);

  @override
  _SelectedImagesState createState() => _SelectedImagesState();
}

class _SelectedImagesState extends State<SelectedImages>
    with TickerProviderStateMixin {
  PageController pageController;
  ScrollController scrollController = new ScrollController();
  int pageIndex;
  int previousIndex;
  AnimationController _animationController;
  AnimationController _timerController;
  AnimationController _minimizeController;

  var paintBoundaryKey = new GlobalKey();
  double imageWidth, imageHeight, areaWidth, areaHeight;
  double widthRatio, heightRatio, bestRatio, widgetWidth, widgetHeight;

  var editorProvider;
  bool active;
  int idx = 0;

  TimerStory timerStory;
  ValueNotifier<double> progressNotifier;
  double progress;

  @override
  void initState() {
    super.initState();
    pageIndex = 0;
    previousIndex = 0;
    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 1,
      lowerBound: 0,
    );
    _timerController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        upperBound: 1,
        lowerBound: 0);
    _minimizeController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        upperBound: 1,
        lowerBound: 0);
    active = false;
    pageController =
        new PageController(initialPage: 0, keepPage: true, viewportFraction: 1);
    progress = 0.0;
    progressNotifier = new ValueNotifier<double>(progress);

    timerStory = new TimerStory(tickCallback: () {
      _changePage();
    }, progressCallback: (progress) {
      progressNotifier.value = progress;
    });
    timerStory.start(Duration(seconds: 5));
  }

  _animateSlider() {
    Future.delayed(Duration(seconds: 1)).then((value) => {
          pageController.addListener(() {
            setState(() {
              if (pageController.page * 50 <
                  scrollController.position.maxScrollExtent)
                scrollController.jumpTo(pageController.page * 50);

              if (pageController.page.round() > previousIndex)
                pageIndex++;
              else if (pageController.page.round() < previousIndex) pageIndex--;
              previousIndex = pageController.page.round();
            });
          })
        });
  }

  _changePage() {
    _animateSlider();
    if (idx < widget.totalCount - 1) {
      idx++;
      pageController?.animateToPage(
        idx,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    } else {
      idx = 0;
      pageController?.animateToPage(
        idx,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    pageController.dispose();
    timerStory.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var selectedImagesProvider =
        Provider.of<AlbumViewModel>(context, listen: false);

    areaWidth = MediaQuery.of(context).size.width;
    areaHeight = MediaQuery.of(context).size.height;
    imageWidth = 16;
    imageHeight = 9;

    ThemeData theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (_animationController.isCompleted) {
          _animationController.reverse();
          return false;
        } else
          return true;
      },
      child: AnimatedBuilder(
        animation: _minimizeController,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity(),
            child: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Stack(
                      children: [
                        AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  color: theme.scaffoldBackgroundColor,
                                  child: Container(
                                    height: areaHeight,
                                    width: areaWidth,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Card(
                                                margin: EdgeInsets.all(0.0),
                                                color: theme
                                                    .scaffoldBackgroundColor
                                                    .withOpacity(1 -
                                                        _animationController
                                                            .value),
                                                child: Container(
                                                  height: areaHeight,
                                                  width: areaWidth,
                                                )),
                                            Transform.scale(
                                              scale: math.max(
                                                  _animationController.value,
                                                  0.8),
                                              child: Container(
                                                height: areaHeight,
                                                width: areaWidth,
                                                child: PageView.builder(
                                                  controller: pageController,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  onPageChanged: (index) {
                                                    setState(() {
                                                      idx = index;
                                                    });
                                                  },
                                                  itemBuilder:
                                                      (context, index) {
                                                    // return FutureBuilder(
                                                    //   builder: (context, data) {
                                                    //     if (!data.hasData)
                                                    //       return Center(
                                                    //         child:
                                                    //             CircularProgressIndicator(),
                                                    //       );
                                                        return GestureDetector(
                                                          onLongPressStart:
                                                              (details) {
                                                            timerStory.pause();
                                                          },
                                                          onLongPressEnd:
                                                              (details) {
                                                            timerStory.resume();
                                                          },
                                                          onTap: () {
                                                            setState(() {
                                                              if (!_animationController
                                                                  .isCompleted) {
                                                                _animationController
                                                                    .forward();
                                                                SystemChrome
                                                                    .setPreferredOrientations([
                                                                  DeviceOrientation
                                                                      .landscapeLeft,
                                                                  DeviceOrientation
                                                                      .landscapeRight,
                                                                  DeviceOrientation
                                                                      .portraitUp,
                                                                  DeviceOrientation
                                                                      .portraitDown
                                                                ]);
                                                                // SystemChrome
                                                                //     .setEnabledSystemUIOverlays(
                                                                //         []);
                                                                if (_timerController
                                                                    .isCompleted)
                                                                  _timerController
                                                                      .reverse();
                                                              } else {
                                                                _animationController
                                                                    .reverse();
                                                                SystemChrome
                                                                    .setPreferredOrientations([
                                                                  DeviceOrientation
                                                                      .portraitUp
                                                                ]);
                                                                // SystemChrome
                                                                //     .setEnabledSystemUIOverlays(
                                                                //         SystemUiOverlay
                                                                //             .values);

                                                                // if (!_timerController
                                                                //     .isCompleted)
                                                                //   _timerController
                                                                //       .forward();
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                              height:
                                                                  areaHeight,
                                                              width: areaWidth,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: theme
                                                                    .scaffoldBackgroundColor,
                                                                image: DecorationImage(
                                                                    // image: data.data.image,
                                                                    image: Image.file(File(selectedImagesProvider
                                                                            .selectedImagesModels
                                                                            .selectedImages[
                                                                                index]
                                                                            .imageStoragePath))
                                                                        .image,
                                                                    fit: BoxFit.contain),
                                                              )),
                                                        );
                                                      // },
                                                      // future: selectedImagesProvider
                                                      //     .selectedImagesModels
                                                      //     .selectedImages[index]
                                                      //     .getFullImage(
                                                      //         MediaQuery.of(
                                                      //                 context)
                                                      //             .size
                                                      //             .width,
                                                      //         MediaQuery.of(
                                                      //                 context)
                                                      //             .size
                                                      //             .height),
                                                    // );
                                                  },
                                                  itemCount:
                                                      selectedImagesProvider
                                                          .selectedImagesModels
                                                          .selectedImages
                                                          .length,
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ));
                            }),
                        Positioned(
                          right: 20,
                          bottom: 0,
                          child: AnimatedBuilder(
                              animation: _timerController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                      0,
                                      ((1 - _timerController.value) * 500) -
                                          20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 30.0, sigmaY: 30.0),
                                      child: Container(
                                        width: 70,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                                child: timeWidget(3),
                                                onTap: () {
                                                  if (_timerController
                                                      .isCompleted)
                                                    _timerController.reverse();
                                                  timerStory.start(
                                                      Duration(seconds: 3));
                                                }),
                                            InkWell(
                                                child: timeWidget(5),
                                                onTap: () {
                                                  if (_timerController
                                                      .isCompleted)
                                                    _timerController.reverse();
                                                  timerStory.start(
                                                      Duration(seconds: 5));
                                                }),
                                            InkWell(
                                                child: timeWidget(10),
                                                onTap: () {
                                                  if (_timerController
                                                      .isCompleted)
                                                    _timerController.reverse();
                                                  timerStory.start(
                                                      Duration(seconds: 10));
                                                }),
                                            SizedBox(
                                              height: 20,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    0, -_animationController.value * 100),
                                child: AppBar(
                                    backgroundColor:
                                        theme.scaffoldBackgroundColor,
                                    automaticallyImplyLeading: false,
                                    title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(this);
                                                  // if (!_minimizeController
                                                  //     .isCompleted)
                                                  //   _minimizeController
                                                  //       .forward();
                                                  // else
                                                  //   _minimizeController
                                                  //       .reverse();
                                                  // if (_animationController.isCompleted) {
                                                  //   _animationController.reverse();
                                                  return false;
                                                  // } else
                                                  //   return true;
                                                },
                                                icon: IconTheme(
                                                  data: theme
                                                      .appBarTheme.iconTheme,
                                                  child: Icon(
                                                    FontAwesomeIcons
                                                        .arrowCircleLeft,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                "Slide Show",
                                                style:
                                                    theme.textTheme.headline2,
                                              )
                                            ],
                                          ),
                                          AnimatedActiveButton(
                                            activeIcon: Icons.play_circle_fill,
                                            inActiveIcon:
                                                Icons.play_circle_fill,
                                            callback: () {
                                              // debugPrint("Finished Adjust");
                                              _animationController.forward();
                                            },
                                          ),
                                        ])),
                              );
                            }),
                        Positioned(
                          top: 0,
                          child: Container(
                              height: 10,
                              width: MediaQuery.of(context).size.width,
                              child: ValueListenableBuilder(
                                valueListenable: progressNotifier,
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    backgroundColor: theme.accentColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.primaryColorDark),
                                    value: (progressNotifier.value),
                                  );
                                },
                              )),
                        ),
                        Positioned(
                          bottom: 10,
                          child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Stack(
                                  children: [
                                    Transform.translate(
                                        offset: Offset(0,
                                            _animationController.value * 100),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: theme.scaffoldBackgroundColor,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  controller: scrollController,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        pageController
                                                            .jumpToPage(index);
                                                        setState(() {
                                                          pageIndex = index;
                                                        });
                                                      },
                                                      child: Card(
                                                        elevation: 1.2,
                                                        margin:
                                                            EdgeInsets.all(1),
                                                        child: FutureBuilder(
                                                            future: loadThumb(
                                                                selectedImagesProvider,
                                                                index),
                                                            builder: (context,
                                                                data) {
                                                              if (!data.hasData)
                                                                return Container();
                                                              return Container(
                                                                width: 50,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.2,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        border: Border
                                                                            .all(
                                                                          width:
                                                                              2,
                                                                          color: (pageController
                                                                                      // ignore: invalid_use_of_protected_member
                                                                                      .positions
                                                                                      .isEmpty ||
                                                                                  pageController.page.round() == index)
                                                                              ? theme.primaryColorDark
                                                                              : theme.accentColor,
                                                                        ),
                                                                        image:
                                                                            DecorationImage(
                                                                          image: data
                                                                              .data
                                                                              .image,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )),
                                                              );
                                                            }),
                                                      ),
                                                    );
                                                  },
                                                  itemCount:
                                                      selectedImagesProvider
                                                          .selectedImagesModels
                                                          .selectedImages
                                                          .length,
                                                ),
                                              ),
                                              AnimatedActiveButton(
                                                callback: () {
                                                  // setState(() {
                                                  // debugPrint("timer");
                                                  if (_timerController
                                                      .isCompleted)
                                                    _timerController.reverse();
                                                  else
                                                    _timerController.forward();
                                                  // });
                                                },
                                                activeIcon: Icons.timer_rounded,
                                                inActiveIcon:
                                                    Icons.timer_rounded,
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                );
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  loadThumb(AlbumViewModel provider, idx) async {
    if (provider.selectedImagesModels.selectedImages[idx].imageThumb == null) {
      return provider.selectedImagesModels
          .loadImageThumb(provider.selectedImagesModels.selectedImages[idx]);
    }
    return Future.delayed(Duration.zero, () {
      return provider.selectedImagesModels.selectedImages[idx].imageThumb;
    });
  }

  timeWidget(int time) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(50)),
      child: Text(
        time.toString() + "s",
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}
