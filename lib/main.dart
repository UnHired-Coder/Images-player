import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdfconverter/UI/Screens/SecondaryScreens/timerStory.dart';
import 'package:pdfconverter/util/ThemesManager.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'UI/Screens/Gallery/albumViewModel.dart';
import 'UI/Screens/Gallery/imageGalleryUi.dart';
import 'UI/Screens/SelectedImages/selectedImagesModel.dart';

Future<void> main() async {
  await GetStorage.init("PrefsManager");
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false, home: MyRiveAnimation()));
}

class MyRiveAnimation extends StatefulWidget {
  @override
  _MyRiveAnimationState createState() => _MyRiveAnimationState();
}

class _MyRiveAnimationState extends State<MyRiveAnimation> {
  final riveFileName = 'lib/assets/rive/logo_flare.riv';
  Artboard artBoard;
  SimpleAnimation animation1 = SimpleAnimation('Animation 1');
  SimpleAnimation animation2 = SimpleAnimation('Animation 2');
  SimpleAnimation animation3 = SimpleAnimation('Animation 3');
  TimerStory timerStory;
  double progress;

  bool flag;

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
    timerStory = TimerStory(tickCallback: () {
      // artBoard.removeController(animation2);
      // artBoard.removeController(animation1);
      artBoard.removeController(animation3);
      // artBoard.addController(animation2);
      timerStory.stop();
      Future.delayed(Duration(seconds: 1), () {
        // artBoard.removeController(animation2);
        Navigator.of(context)
            .pushReplacement(new MaterialPageRoute(builder: (context) {
          return MyApp();
        }));
      });
    }, progressCallback: (v) {
      setState(() {
        progress = v;
      });
    });
    // Future.delayed(Duration(seconds: 1), () {
    timerStory.start(Duration(seconds: 2));
    // });
  }

  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = RiveFile();

    if (file.import(bytes)) {
      setState(() => artBoard = file.mainArtboard
        ..addController(animation1)
        ..addController(animation3));
    }
  }

  double width;
  double height;

  /// Show the rive file, when loaded
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return artBoard != null
        ? Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Container(
                child: Container(
                  width: width,
                  height: height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1,
                        child: Container(
                          width: width,
                          height: height,
                          child: Rive(
                            artboard: artBoard,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                      // SizedBox(
                      //   height: height * 0.1,
                      // ),
                      // Container(
                      //   child: Text(
                      //     "Images Player",
                      //     style: TextStyle(color: White, fontFamily: 'DM_Mono'),
                      //   ),
                      //   alignment: Alignment.center,
                      //   width: width,
                      // ),
                      // SizedBox(
                      //   height: height * 0.05,
                      // ),
                      // Container(
                      //   width: width * 0.3,
                      //   height: height * 0.005,
                      //   decoration: BoxDecoration(
                      //       color: Colors.red,
                      //       borderRadius: BorderRadius.circular(100)),
                      //   child: LinearProgressIndicator(
                      //     value: progress,
                      //     valueColor:
                      //         AlwaysStoppedAnimation<Color>(Colors.blue),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  //1
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  ThemesManager themesManager = ThemesManager();

  @override
  void initState() {
    super.initState();
    themesManager.addListener(() {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themesManager.lightTheme,
        themeMode:
            themesManager.lightTheme == null ? ThemeMode.light : ThemeMode.dark,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AlbumViewModel>(
              create: (context) => AlbumViewModel(),
            ),
            ChangeNotifierProvider<SelectedModels>(
              create: (context) => SelectedModels(),
            )
          ],
          child: ImageGalleryUi(),
        ));
  }
}
