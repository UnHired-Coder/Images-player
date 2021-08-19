import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdfconverter/UI/Screens/SecondaryScreens/imageViewerSimple.dart';
import 'package:pdfconverter/UI/Screens/SelectedImages/selectedImagesModel.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:pdfconverter/models/imageMeta.dart';
import 'package:provider/provider.dart';

class AnimatedSelectWidget extends StatefulWidget {
  final double height;
  final double width;
  final Widget child;
  final Function function;
  final ImageMeta image;

  AnimatedSelectWidget(
      {this.height,
      this.width,
      @required this.child,
      this.function,
      this.image});

  @override
  _AnimatedSelectWidgetState createState() => _AnimatedSelectWidgetState();
}

class _AnimatedSelectWidgetState extends State<AnimatedSelectWidget>
    with SingleTickerProviderStateMixin {
  double height, width;
  AnimationController animationController;
  bool flag;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        duration: Duration(milliseconds: 200),
        lowerBound: 0.3,
        upperBound: 1,
        vsync: this)
      ..addListener(() {
        setState(() {});
      });
    animationController.reverse();
    height = widget.height == null ? 100 : widget.height;
    width = widget.width == null ? 100 : widget.width;
    flag = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<SelectedModels>(builder: (context, model, child) {
        if ((model.selectedImagesMap[widget.image.id] != null) &&
            model.selectedImagesMap[widget.image.id] == 0 &&
            flag == false) {
          animationController.reverse().then((value) => {});
          flag = true;
        }

        return InkWell(
          child: Stack(
            children: [
              Transform.scale(
                scale: 1 - (animationController.value * 0.1),
                child: Container(
                  width: width,
                  height: height,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      widget.child,
                      Container(
                        width: width * 0.25,
                        height: height * 0.25,
                        child: IconButton(
                            alignment: Alignment.topRight,
                            icon: Icon(
                              FontAwesomeIcons.expand,
                              color: White,
                              size: 10,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ImageViewerSimple(
                                  imageMeta: widget.image,
                                );
                              }));
                            }),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:
                        ((model.selectedImagesMap[widget.image.id] != null) &&
                                model.selectedImagesMap[widget.image.id] > 0
                            ? Theme.of(context).textTheme.headline2.color
                            : Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                child: (model.selectedImagesMap[widget.image.id] != null) &&
                        model.selectedImagesMap[widget.image.id] > 0
                    ? Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              (model.selectedImagesMap[widget.image.id])
                                  .toString(),
                              style: Theme.of(context).textTheme.headline4,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      )
                    : Container(),
                bottom: 5,
                right: 5,
              )
            ],
          ),
          onLongPress: () {
            debugPrint("pressed");
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ImageViewerSimple(
                imageMeta: widget.image,
              );
            }));
          },
          onTap: () async {
            if ((model.selectedImagesMap[widget.image.id] != null) &&
                model.selectedImagesMap[widget.image.id] == 0 &&
                flag == true) {
              animationController.forward().then((value) => {});
              flag = false;
            } else
            // ((model.selectedImagesMap[widget.image.id] != null) &&
            //   model.selectedImagesMap[widget.image.id] == 0 &&
            //   flag == false)
            {
              animationController.reverse().then((value) => {});
              flag = true;
            }
            widget.function.call(widget.image);
            setState(() {});
          },
        );
      }),
    );
  }
}
