import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';
import 'package:pdfconverter/assets/colors/filters.dart';
import 'package:pdfconverter/declarations/enums.dart';

class FilterImageUI extends StatefulWidget {
  final Image image;
  final PageLayoutMode pageLayoutMode;
  final Offset widgetSize;
  final Offset imageSize;

  FilterImageUI(
      {@required this.image,
      this.pageLayoutMode = PageLayoutMode.portrait,
      @required this.imageSize,
      @required this.widgetSize});

  @override
  _FilterImageUIState createState() => _FilterImageUIState();
}

class _FilterImageUIState extends State<FilterImageUI> {
  MatrixFiltersController matrixFiltersController =
      new MatrixFiltersController();

  MatrixFilter colorFilterMat;

  @override
  void initState() {
    super.initState();
    colorFilterMat = matrixFiltersController.filters[0];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:  () async {
        Navigator.pop(context, colorFilterMat.toString());
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Grey,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: widget.widgetSize.dy,
                      width: widget.widgetSize.dx,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: widget.widgetSize.dy,
                              width: widget.widgetSize.dx,
                              color: White,
                            ),
                            ColorFiltered(
                              colorFilter: ColorFilter.matrix(colorFilterMat.mat),
                              child: Container(
                                height: widget.widgetSize.dy,
                                width: widget.widgetSize.dx,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: widget.image.image)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  colorFilterMat =
                                      matrixFiltersController.filters[index];
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    matrixFiltersController.filters[index].name,
                                    style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        color: White,
                                        fontSize: 12),
                                  ),
                                  Container(
                                    height: 80,
                                    width: 80,
                                    color: CupertinoColors.white,
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.matrix(
                                          matrixFiltersController
                                              .filters[index].mat),
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        margin: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: widget.image.image)),
                                      ),
                                    ),
                                    margin: EdgeInsets.all(2),
                                  )
                                ],
                              ),
                            );
                          },
                          itemCount: matrixFiltersController.filters.length,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
