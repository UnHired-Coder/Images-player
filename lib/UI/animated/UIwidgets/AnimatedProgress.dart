import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class AnimatedProgressIndicator extends StatefulWidget {
  @override
  _AnimatedProgressIndicatorState createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator> {
  final riveFileName = 'lib/assets/rive/progress_indicator.riv';
  Artboard artBoard;
  SimpleAnimation animation1 = SimpleAnimation('Animation 1');
  bool flag = false;

  @override
  void initState() {
    _loadRiveFile();

    super.initState();
  }

  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = RiveFile();

    if (file.import(bytes)) {
      flag = true;
      setState(() => artBoard = file.mainArtboard..addController(animation1));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return (flag)?Container(
      width: width,
      height: height,
      child: Rive(
        artboard: artBoard,
        fit: BoxFit.contain,
      ),
    ):Container();
  }
}
