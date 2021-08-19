import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdfconverter/assets/colors/Swatchers.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:pdfconverter/util/PrefsManager.dart';
import 'package:pdfconverter/util/ThemesManager.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreenUi extends StatefulWidget {
  @override
  _SettingsScreenUiState createState() => _SettingsScreenUiState();
}

class _SettingsScreenUiState extends State<SettingsScreenUi> {
  ValueNotifier<int> unitSelected;
  int darkColorAccentIndex;
  int colorAccentIndex;
  PrefsManager prefsManager;
  List<String> themes;
  List<String> fonts;
  ThemesManager themesManager;

  @override
  void initState() {
    super.initState();
    unitSelected = ValueNotifier(0);
    colorAccentIndex = 4;
    darkColorAccentIndex = 4;
    prefsManager = new PrefsManager();
    themes = List.generate(
        darkAccentColorsNames.length, (index) => darkAccentColorsNames[index]);
    fonts = [
      "Quicksand",
      "DancingScript",
      "Oswald",
      "DM_Mono",
      "Pacifico",
      "ShadowsIntoLight",
      "Fredoka_One",
      "Sacramento"
    ];
    themesManager = ThemesManager();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    icon: IconTheme(
                      data: Theme.of(context).appBarTheme.iconTheme,
                      child: Icon(
                        FontAwesomeIcons.arrowCircleLeft,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "Settings",
                  style: Theme.of(context).textTheme.headline3,
                )
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Card(
                color: Theme.of(context).scaffoldBackgroundColor,
                margin: EdgeInsets.all(0),
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.05),
                  width: screenWidth,
                  height: screenHeight * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Themes",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Container(
                        width: screenWidth * 0.50,
                        height: screenHeight * 0.25,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: FakeWhite,
                        ),
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
                              initialPage: 1,
                              aspectRatio: 1,
                              height: 200,
                              onPageChanged: (page, reason) {
                                setState(() {
                                  Future.delayed(Duration(milliseconds: 50),
                                      () {
                                    themesManager.themeColor =
                                        themeColors[page];
                                  });
                                });
                              }),
                          itemCount: themeColors.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: screenWidth * 0.30,
                                height: screenHeight * 0.20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: themeColors[index],
                                ),
                                child: Container(
                                  height: screenHeight * 0.04,
                                  width: screenWidth * 0.2,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: themesManager.darkAccentColor),
                                  child: Center(
                                    child: Text(
                                      themes[index],
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          .copyWith(
                                              fontSize: screenHeight * 0.015),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              margin: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.only(top: screenHeight * 0.02),
                width: screenWidth,
                height: screenHeight * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Dark Accent Color",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: screenHeight * 0.04,
                      width: screenHeight * 0.04,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: FakeWhite, width: 2),
                          color: darkAccentColors[darkColorAccentIndex]),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      alignment: Alignment.center,
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            aspectRatio: 1,
                            initialPage: 4,
                            height: screenHeight * 0.04,
                            viewportFraction: 0.2,
                            onScrolled: (details) {
                              setState(() {
                                darkColorAccentIndex = details.round();
                                Future.delayed(Duration(milliseconds: 200), () {
                                  themesManager.darkAccentColor =
                                      darkAccentColors[darkColorAccentIndex];
                                });
                              });
                            }),
                        itemCount: darkAccentColors.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: darkAccentColors[index]),
                            margin:
                                EdgeInsets.only(left: 10, right: 10, top: 2),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              margin: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.only(top: screenHeight * 0.02),
                width: screenWidth,
                height: screenHeight * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Accent Color",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: screenHeight * 0.04,
                      width: screenHeight * 0.04,
                      decoration: BoxDecoration(
                          border: Border.all(color: FakeWhite, width: 2),
                          borderRadius: BorderRadius.circular(100),
                          color: accentColors[colorAccentIndex]),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      alignment: Alignment.center,
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            aspectRatio: 1,
                            initialPage: 4,
                            height: screenHeight * 0.04,
                            viewportFraction: 0.2,
                            onScrolled: (details) {
                              setState(() {
                                colorAccentIndex = details.round();
                                Future.delayed(Duration(milliseconds: 200), () {
                                  themesManager.accentColor =
                                      accentColors[colorAccentIndex];
                                });
                              });
                            }),
                        itemCount: accentColors.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: accentColors[index]),
                            margin:
                                EdgeInsets.only(left: 10, right: 10, top: 2),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              margin: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.only(top: 10),
                width: screenWidth,
                height: screenHeight * 0.15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Text Font",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Container(
                      width: screenWidth * 0.5,
                      alignment: Alignment.center,
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            viewportFraction: 0.5,
                            initialPage: 1,
                            onPageChanged: (page, reason) {
                              // debugPrint(page.toString());
                              themesManager.font = fonts[page];
                            },
                            height: 50),
                        itemCount: fonts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(fonts[index],
                                  style: TextStyle(
                                      fontFamily: fonts[index],
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2
                                          .color)),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              margin: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.only(top: 10),
                width: screenWidth,
                height: screenHeight * 0.15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Images Grid Size",
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      width: screenWidth * 0.4,
                      alignment: Alignment.center,
                      child: ListView.builder(
                          itemCount: 3,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            List<int> _list = [3, 4, 5];
                            return ValueListenableBuilder(
                              valueListenable: unitSelected,
                              builder: (context, hasError, val) {
                                return InkWell(
                                    onTap: () {
                                      unitSelected.value = index;
                                      themesManager.prefsManager.setGridCount =
                                          _list[index];
                                    },
                                    child: Container(
                                        width: screenHeight * 0.06,
                                        height: screenHeight * 0.06,
                                        margin:
                                            EdgeInsets.only(left: 4, right: 4),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline3
                                                    .color,
                                                width: (unitSelected.value ==
                                                        index)
                                                    ? 1.4
                                                    : 0.4)),
                                        child: Text(_list[index].toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3)));
                              },
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              margin: EdgeInsets.all(0),
              child: ListTile(
                onTap: () async {
                  const uri =
                      'mailto:pratyushtiwarimj@gmail.com?subject=Bug%20Report@ImagesPlayer&body=Describe%20bug/feature%20request%20here..';
                  if (await canLaunch(uri)) {
                    await launch(uri);
                  } else {
                    throw 'Could not launch $uri';
                  }
                },
                contentPadding: EdgeInsets.all(3),
                title: textWidget(text: "Report Bug", icon: Icons.bug_report),
              ),
            ),
            Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              margin: EdgeInsets.all(0),
              child: ListTile(
                onTap: () {
                  String appPackageName = 'com.hack.imagesplayer';
                  try {
                    launch("market://details?id=" + appPackageName);
                  } on PlatformException catch (e) {
                    launch("https://play.google.com/store/apps/details?id=" +
                        appPackageName);
                  } finally {
                    launch("https://play.google.com/store/apps/details?id=" +
                        appPackageName);
                  }
                },
                contentPadding: EdgeInsets.all(3),
                title:
                    textWidget(text: "Check Update", icon: Icons.system_update),
              ),
            ),
            Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              margin: EdgeInsets.all(0),
              child: Container(height: 100),
            )
          ],
        ),
      ),
    );
  }

  textWidget({String text, IconData icon}) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: Theme.of(context).iconTheme,
            child: Icon(icon),
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.headline2,
          )
        ],
      ),
    );
  }
}
