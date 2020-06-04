import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
//import 'package:flutter_svg/flutter_svg.dart';

import 'package:ludo_planner/widgets/appbar.dart';
import 'package:ludo_planner/widgets/bottomLeft.dart';
import 'package:ludo_planner/widgets/topLeft.dart';
import 'package:ludo_planner/widgets/topRight.dart';
import 'package:ludo_planner/widgets/bottomRight.dart';
import 'package:ludo_planner/widgets/blinkingWidget.dart';
import 'package:ludo_planner/widgets/dialogHeader.dart';

import 'package:ludo_planner/screens/splash.dart';

import 'package:ludo_planner/utils/positions.dart';
import 'package:ludo_planner/utils/isLegalPosition.dart';
import 'package:ludo_planner/utils/getBottomLeftSpacing.dart';
import 'package:ludo_planner/utils/get1Dfrom2D.dart';
import 'package:ludo_planner/utils/get2Dfrom1D.dart';

import 'package:ludo_planner/service/service.dart';

extension StateExtension<T extends StatefulWidget> on State<T> {
  Stream waitForStateLoading() async* {
    while (!mounted) {
      yield false;
    }
    yield true;
  }

  Future<void> postInit(VoidCallback action) async {
    await for (var isLoaded in waitForStateLoading()) {}
    action();
  }
}

class HomeScreen extends StatefulWidget {
  Image image;

  HomeScreen(this.image);
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> availableColors = [
    {"name": "red", "value": Colors.red},
    {"name": "yellow", "value": Colors.yellow},
    {"name": "blue", "value": Colors.blue},
    {"name": "green", "value": Colors.green},
  ];
  String selectedColor = "red";
  String currentPlayerName;
  List<Map<String, dynamic>> selectedColorList = [null, null, null, null];
  List<Widget> gridItems = List.generate(15, (index) => Container());
  bool isLoading = true;
  bool move = false;
  int moveItem;
  int diceNo;
  Image image = Image.asset("assets/board_wireframe.png");
  Image image1 = Image.asset("assets/ludo_background.png");

  bool showSplash = true;

  static const double BASEBOTTOM2 = 2.0;
  static const double BASEBOTTOM13 = 13.0;

  static const double BASELEFT2 = 2.0;
  static const double BASELEFT13 = 13.0;
  static const SPLASH_DURATION = 5000;

  Map<int, dynamic> defaultOffsets;

  // Board map UI format
  Map<int, dynamic> offsets;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/ludo_background.png"),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar(showSplash),
          body: showSplash
              ? SplashScreen()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          playerAddButton(1),
                          playerAddButton(2)
                        ],
                      ),
                      Center(
                        child: Container(
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Stack(
                              children: layout(),
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          playerAddButton(0),
                          playerAddButton(3)
                        ],
                      ),
                      screenBottomRow()
                    ]),
        ),
      ),
    ]);
  }

  void reset() {
    print('------------->in reset()');
    setState(() {
      availableColors = [
        {"name": "red", "value": Colors.red},
        {"name": "yellow", "value": Colors.yellow},
        {"name": "blue", "value": Colors.blue},
        {"name": "green", "value": Colors.green},
      ];
      selectedColor = "red";
      currentPlayerName = "";
      selectedColorList = [null, null, null, null];
      gridItems = List.generate(15, (index) => Container());
      move = false;
      moveItem = null;
      offsets = {
        00: {
          "initBottom":
              getBottom(context, 2) * 0.5 + getBottom(context, 1) * 0.5,
          "initLeft": getLeft(context, 2) * 0.4 + getLeft(context, 1) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        10: {
          "initBottom":
              getBottom(context, 3) * 0.5 + getBottom(context, 4) * 0.5,
          "initLeft": getLeft(context, 2) * 0.4 + getLeft(context, 1) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        20: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 3) * 0.6 + getLeft(context, 4) * 0.4,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        30: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 3) * 0.6 + getLeft(context, 4) * 0.4,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        01: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": (getLeft(context, 2) + getLeft(context, 1)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        11: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": (getLeft(context, 2) + getLeft(context, 1)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        21: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": (getLeft(context, 3) + getLeft(context, 4)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        31: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": (getLeft(context, 3) + getLeft(context, 4)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        02: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        12: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        22: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": getLeft(context, 12) * 0.4 + getLeft(context, 13) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        32: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": getLeft(context, 12) * 0.4 + getLeft(context, 13) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        03: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        13: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        23: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 12) * 0.3 + getLeft(context, 13) * 0.7,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        33: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 12) * 0.3 + getLeft(context, 13) * 0.7,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
      };
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(image.image, context);
  }

  void initState() {
    super.initState();

    postInit(() {
      Completer<Size> completer = Completer();
      image.image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
            var myImage = image.image;
            Size size =
                Size(myImage.width.toDouble(), myImage.height.toDouble());
            completer.complete(size);
          },
        ),
      );
      completer.future.then((value) => setState(() {
            showSplash = false;
          }));
      offsets = {
        00: {
          "initBottom":
              getBottom(context, 2) * 0.5 + getBottom(context, 1) * 0.5,
          "initLeft": getLeft(context, 2) * 0.4 + getLeft(context, 1) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        10: {
          "initBottom":
              getBottom(context, 3) * 0.5 + getBottom(context, 4) * 0.5,
          "initLeft": getLeft(context, 2) * 0.4 + getLeft(context, 1) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        20: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 3) * 0.6 + getLeft(context, 4) * 0.4,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        30: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 3) * 0.6 + getLeft(context, 4) * 0.4,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        01: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": (getLeft(context, 2) + getLeft(context, 1)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        11: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": (getLeft(context, 2) + getLeft(context, 1)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        21: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": (getLeft(context, 3) + getLeft(context, 4)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        31: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": (getLeft(context, 3) + getLeft(context, 4)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        02: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        12: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        22: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": getLeft(context, 12) * 0.4 + getLeft(context, 13) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        32: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": getLeft(context, 12) * 0.4 + getLeft(context, 13) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        03: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        13: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        23: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 12) * 0.3 + getLeft(context, 13) * 0.7,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        33: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 12) * 0.3 + getLeft(context, 13) * 0.7,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
      };
      defaultOffsets = {
        00: {
          "initBottom":
              getBottom(context, 2) * 0.5 + getBottom(context, 1) * 0.5,
          "initLeft": getLeft(context, 2) * 0.4 + getLeft(context, 1) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        10: {
          "initBottom":
              getBottom(context, 3) * 0.5 + getBottom(context, 4) * 0.5,
          "initLeft": getLeft(context, 2) * 0.4 + getLeft(context, 1) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        20: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 3) * 0.6 + getLeft(context, 4) * 0.4,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        30: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 3) * 0.6 + getLeft(context, 4) * 0.4,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 0,
          "onMultiple": false
        },
        01: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": (getLeft(context, 2) + getLeft(context, 1)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        11: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": (getLeft(context, 2) + getLeft(context, 1)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        21: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": (getLeft(context, 3) + getLeft(context, 4)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        31: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": (getLeft(context, 3) + getLeft(context, 4)) / 2,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 1,
          "onMultiple": false
        },
        02: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        12: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        22: {
          "initBottom":
              getBottom(context, 14) * 0.2 + getBottom(context, 13) * 0.8,
          "initLeft": getLeft(context, 12) * 0.4 + getLeft(context, 13) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        32: {
          "initBottom":
              getBottom(context, 11) * 0.8 + getBottom(context, 12) * 0.2,
          "initLeft": getLeft(context, 12) * 0.4 + getLeft(context, 13) * 0.6,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 2,
          "onMultiple": false
        },
        03: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        13: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 11) * 0.7 + getLeft(context, 10) * 0.3,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        23: {
          "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
          "initLeft": getLeft(context, 12) * 0.3 + getLeft(context, 13) * 0.7,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
        33: {
          "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
          "initLeft": getLeft(context, 12) * 0.3 + getLeft(context, 13) * 0.7,
          "bottom": null,
          "left": null,
          "sameBottom": null,
          "sameLeft": null,
          "moved": false,
          "position": -1,
          "highlighted": false,
          "predicted": false,
          "xPosition": -1,
          "sizeMultiplier": 1,
          "playerIndex": 3,
          "onMultiple": false
        },
      };
    });
  }

  Widget renderGoti(int count, int position) {
    print('------------->in renderGoti()');
    if (selectedColorList[position] != null) {
      double init = MediaQuery.of(context).size.width * 0.054;
      double size = MediaQuery.of(context).size.width *
          0.064 *
          offsets[int.parse("$count$position")]["sizeMultiplier"];
//      double initBottom =
//          init * offsets[int.parse("$count$position")]["initBottom"];
//      double initLeft =
//          init * offsets[int.parse("$count$position")]["initLeft"];
      double initBottom = offsets[int.parse("$count$position")]["initBottom"];
      double initLeft = offsets[int.parse("$count$position")]["initLeft"];

      double bottom = offsets[int.parse("$count$position")]["moved"]
          ? offsets[int.parse("$count$position")]["bottom"]
          : initBottom;
      double left = offsets[int.parse("$count$position")]["moved"]
          ? offsets[int.parse("$count$position")]["left"]
          : initLeft;
      return Stack(children: [
        Positioned(
            bottom: initBottom,
            left: initLeft,
            child: GestureDetector(
                onTap: () {
                  print('onTap #1 move: ' + move.toString());
                  if (move) {
                    Map<int, dynamic> currentOffsets = offsets;
                    currentOffsets[moveItem]["moved"] = false;
                    currentOffsets[moveItem]["highlighted"] = false;
                    currentOffsets[moveItem]["predicted"] = false;
                    currentOffsets[moveItem]["position"] = -1;

                    currentOffsets = unhighlightAll(currentOffsets);

                    setState(() {
                      move = false;
                      offsets = currentOffsets;
                    });
                  }
                },
                child: Container(
                    color: Colors.transparent, width: size, height: size))),
        Positioned(
            key: Key("$position.$count"),
            bottom: bottom,
            left: left,
            child: GestureDetector(
                onTap: () {
                  print('onTap #2 move: ' + move.toString());
                  if (move) {
                    print("SET MOVE FALSE");

                    Map<int, dynamic> currentOffsets = offsets;

                    if (moveItem == int.parse("$count$position") &&
                        currentOffsets[moveItem]["moved"] == false) {
                      currentOffsets[moveItem]["xPosition"] = -1;
                      currentOffsets[moveItem]["bottom"] =
                          offsets[int.parse("$count$position")]["initBottom"];
                      currentOffsets[moveItem]["left"] =
                          offsets[int.parse("$count$position")]["initLeft"];
                      currentOffsets[moveItem]["moved"] = false;
                      currentOffsets[moveItem]["highlighted"] = false;
                      currentOffsets[moveItem]["predicted"] = false;
                      currentOffsets = unhighlightAll(currentOffsets);
                      setState(() {
                        move = false;
                        offsets = currentOffsets;
                      });
                    } else {
                      print("OUGHT TO MOVE");
                      // first check if the goti that was clicked is it in home.
                      // if it is home then change the selection without moving
                      if (offsets[int.parse("$count$position")]["xPosition"] ==
                          -1) {
                        unhighlightAll(currentOffsets);
                        print("EXCHANGING SELECTION");
                        // TODO: do the exchange here
                        moveItem = int.parse("$count$position");
                        currentOffsets[moveItem]["highlighted"] = true;
                        setState(() {
                          move = true;
                          offsets = currentOffsets;
                        });
                      } else {
                        print("MOVING SELECTION");
                        // this will set xPosition
                        currentOffsets[moveItem]["xPosition"] =
                            offsets[int.parse("$count$position")]["xPosition"];
                        currentOffsets[moveItem]["bottom"] =
                            offsets[int.parse("$count$position")]["bottom"];
                        currentOffsets[moveItem]["left"] =
                            offsets[int.parse("$count$position")]["left"];
                        currentOffsets[moveItem]["moved"] = true;
                        currentOffsets[moveItem]["highlighted"] = false;
                        currentOffsets[moveItem]["predicted"] = false;
                        currentOffsets = unhighlightAll(currentOffsets);
                        // check if it is a non safe position so kill
                        if (currentOffsets[moveItem]["playerIndex"] !=
                                currentOffsets[int.parse("$count$position")]
                                    ["playerIndex"] &&
                            isSafePosition(
                                    currentOffsets[int.parse("$count$position")]
                                        ["xPosition"]) ==
                                false) {
                          print("KILLING!!!!!!!!!!!!!!!!!!!!!!!!!!");
                          currentOffsets[int.parse("$count$position")] =
                              defaultOffsets[int.parse("$count$position")];
                          currentOffsets[int.parse("$count$position")]
                              ["moved"] = false;
                        }

                        // Check multiple on one walla case
                        currentOffsets = adjustForMultipleOnOne(currentOffsets);

                        setState(() {
                          move = false;
                          offsets = currentOffsets;
                        });
                      }
                    }
                    // itterate over the offsets to check ki kis kis ka
                  } else {
                    print("SET MOVE TRUE");
                    print(int.parse("$count$position"));
                    print(offsets[01]);
                    Map<int, dynamic> currentOffsets = offsets;

                    // Check if multiple Gotis are in the same box

                    if (currentOffsets[int.parse("$count$position")]
                        ["onMultiple"]) {
                      List<int> keys = [];
                      List<int> countpos = [];

                      int x = currentOffsets[int.parse("$count$position")]
                          ["xPosition"];
                      // for(int i; i < currentOffsets.length; i++) {
                      //   currentOffsets[i]
                      // }
                      currentOffsets.forEach((index, value) {
                        print(index);
                        if (value["xPosition"] == x) {
                          keys.add(index);
                        }
                      });
                      List<int> currentOffsetkeys =
                          currentOffsets.keys.toList();
                      for (int i = 0; i < keys.length; i++) {
                        countpos.add(currentOffsetkeys[i]);
                      }
                      moveGotiDialog(keys);
                    }

                    if (currentOffsets[int.parse("$count$position")]
                        ["predicted"]) {
                      print("---------------------> PREDICTED");
                      List<int> rowClm;
                      if (currentOffsets[int.parse("$count$position")]
                              ["xPosition"] ==
                          -1) {
                        rowClm = get2Dfrom1D(0);
                      } else {
                        rowClm = get2Dfrom1D(
                            currentOffsets[int.parse("$count$position")]
                                    ["xPosition"] +
                                diceNo);
                      }
                      moveGotiTo(rowClm[0], rowClm[1], currentOffsets,
                          int.parse("$count$position"));
                    } else {
                      currentOffsets = unhighlightAll(currentOffsets);
                      currentOffsets[int.parse("$count$position")]
                          ["highlighted"] = true;
                      setState(() {
                        move = true;
                        moveItem = int.parse("$count$position");
                        offsets = currentOffsets;
                      });
                    }
                  }
                },
                child: Container(
                    child: offsets[int.parse("$count$position")]["predicted"]
                        ? BlinkingWidget(Image.asset(
                            offsets[int.parse("$count$position")]["highlighted"]
                                ? "assets/_goti_${selectedColorList[position]["name"]}.png"
                                : "assets/goti_${selectedColorList[position]["name"]}.png",
                            width: size,
                            height: size,
                            fit: BoxFit.fitHeight,
                          ))
                        : Image.asset(
                            offsets[int.parse("$count$position")]["highlighted"]
                                ? "assets/_goti_${selectedColorList[position]["name"]}.png"
                                : "assets/goti_${selectedColorList[position]["name"]}.png",
                            width: size,
                            height: size,
                            fit: BoxFit.fitHeight,
                          ),
                    width: size,
                    height: size)))
      ]);
    } else {
      return Container();
    }
  }

  Map<int, dynamic> adjustForMultipleOnOne(Map<int, dynamic> currentOffsets) {
    for (int xPosition = 0; xPosition < 57; xPosition++) {
      // print('in adjustForMultipleOnOne xPosition: ' + xPosition.toString());
      List<int> rowClm = get2Dfrom1D(xPosition);
      int row = rowClm[0];
      int clm = rowClm[1];
      // //print("ROW: " + row.toString());
      // //print("CLM: " + clm.toString());
      List<int> overlapingKeys = [];
      currentOffsets.forEach((key, value) {
        if (value['xPosition'] == xPosition) {
          overlapingKeys.add(key);
        }
      });

      if (overlapingKeys.length > 1) {
        double gap = ((getLeft(context, 1) - getLeft(context, 0)) /
                overlapingKeys.length) *
            0.6;

        for (int i = 0; i < overlapingKeys.length; i++) {
          int center = (overlapingKeys.length / 2).floor();
          if ((overlapingKeys.length % 2) == 0) {
            //print("even");
            if (i < center) {
              print(i.toString() +
                  ' : ' +
                  getLeft(context, clm).toString() +
                  " : " +
                  (getLeft(context, clm) + gap * (i - center)).toString());
              currentOffsets[overlapingKeys[i]]['left'] =
                  getLeft(context, clm) + gap * (i - center);
            } else {
              print(i.toString() +
                  ' : ' +
                  getLeft(context, clm).toString() +
                  " : " +
                  (getLeft(context, clm) + gap * (i - center + 1)).toString());
              currentOffsets[overlapingKeys[i]]['left'] =
                  getLeft(context, clm) + gap * (i - center + 1);
            }
          } else {
            print("odd");
            print(i.toString() +
                ' : ' +
                getLeft(context, clm).toString() +
                " : " +
                (getLeft(context, clm) + gap * (i - center)).toString());
            currentOffsets[overlapingKeys[i]]['left'] =
                getLeft(context, clm) + gap * (i - center);
          }
          currentOffsets[overlapingKeys[i]]['sizeMultiplier'] =
              1.5 / overlapingKeys.length;
          currentOffsets[overlapingKeys[i]]['onMultiple'] = true;
        }

        print("adjustForMultipleOnOne gap: " +
            gap.toString() +
            " : " +
            overlapingKeys.toString());
      }
    }
    print(currentOffsets.toString());
    return currentOffsets;
  }

  Map<int, dynamic> unhighlightAll(Map<int, dynamic> currentOffsets) {
    currentOffsets.forEach((key, value) {
      value["highlighted"] = false;
      value["predicted"] = false;
      value['sizeMultiplier'] = 1;
      value['onMultiple'] = false;
      if (value['xPosition'] != -1) {
        value['left'] = getLeft(context, get2Dfrom1D(value['xPosition'])[1]);
      }
    });

    currentOffsets = adjustForMultipleOnOne(currentOffsets);

    return currentOffsets;
  }

  void moveGotiTo(int row, int clm, currentOffsets, moveItem) {
    print('moveGotiTo: ' +
        row.toString() +
        ' : ' +
        clm.toString() +
        ' : ' +
        currentOffsets.toString() +
        ' : ' +
        moveItem.toString());
    double bottom = getBottom(context, row);
    double left = getLeft(context, clm);
    int x = get1DPosfrom2D(int.parse("$row$clm"));
    currentOffsets[moveItem]["bottom"] = bottom * 1.05;
    currentOffsets[moveItem]["left"] = left;
    currentOffsets[moveItem]["moved"] = true;
    currentOffsets[moveItem]["highlighted"] = false;
    currentOffsets[moveItem]["predicted"] = false;
    currentOffsets[moveItem]["position"] =
        getActualposition(x, int.parse(moveItem.toString().split("").last));
    print('############ 1 SETTING xPosition to' + x.toString());
    currentOffsets[moveItem]["xPosition"] = x;

    var temp = currentOffsets[moveItem];

    // loop over all the offsets to see agar kissi ka xPossition same as this one to nahi
    currentOffsets.forEach((key, value) {
      if ((currentOffsets[moveItem]["playerIndex"] !=
              currentOffsets[key]["playerIndex"]) &&
          (key != moveItem) &&
          (currentOffsets[key]["xPosition"] == x) &&
          (isSafePosition(currentOffsets[key]["xPosition"]) == false)) {
        print("Auto Move KILLING!!!!!!!!!!!!!!!!!!!!!!!!!!");
        currentOffsets[key] = defaultOffsets[key];
        currentOffsets[key]["moved"] = false;
      }
    });

    // Check multiple on one walla case
    currentOffsets = adjustForMultipleOnOne(currentOffsets);

    currentOffsets[moveItem] = temp;

    currentOffsets = unhighlightAll(currentOffsets);

    setState(() {
      move = false;
      offsets = currentOffsets;
    });
  }

  void addMemberDialog(int position) {
    print('------------->in addMemberDialog()');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              scrollable: true,
              title: Container(
                width: MediaQuery.of(context).size.width * 0.66,
                child: topRow(context, "SELECT COLOR"),
              ),
              content: new Container(
                  // height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(children: [
                    // SvgPicture.asset("assets/popup_bg.svg",
                    //     color: Colors.white, semanticsLabel: 'A red up arrow'),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Column(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: <Widget>[
                        Text(
                          'NAME ',
                          style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          width: MediaQuery.of(context).size.width * 0.66,
                          height: 50,
                          child: TextFormField(
                            expands: false,
                            initialValue: currentPlayerName,
                            onChanged: (value) {
                              setState(() {
                                currentPlayerName = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  40,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: Colors.green.shade400,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        //   ],
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'HOUSE COLOR ',
                          style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[colorDropDown('Color', setState)],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        bottomRow(position)
                      ],
                    ),
                  ])),
            );
          });
        });
  }

  void resetDialog() {
    print('------------->in resetDialog()');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              scrollable: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "CONFIRM",
                    style: TextStyle(color: Colors.green.shade400),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('onTap #4');
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.green.shade400, width: 6)),
                      child: Icon(
                        Icons.close,
                        color: Colors.green.shade400,
                      ),
                    ),
                  )
                ],
              ),
              content: new Container(
                  // height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(children: [
                    // SvgPicture.asset("assets/popup_bg.svg",
                    //     color: Colors.white, semanticsLabel: 'A red up arrow'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          // child: SvgPicture.asset(
                          //   "assets/popup_ok.svg",
                          //   height: 40,
                          //   color: Colors.green.shade300,
                          // ),
                          child: Container(
                              width: 140,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: Colors.red.shade400, width: 6)),
                              child: Text(
                                'YES',
                                style: TextStyle(color: Colors.white),
                              )),
                          onTap: () {
                            print('onTap #5');
                            reset();
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  ])),
            );
          });
        });
  }

  List<Widget> layout() {
    print('------------->in layout()');
    List<Widget> layoutItems = [
      colorBox(0),
      colorBox(1),
      colorBox(2),
      colorBox(3),
      centerSquare()
    ];

    layoutItems.add(
        // Image.asset(
        //   "assets/board_wireframe.png",
        //   width: MediaQuery.of(context).size.width,
        //   height: MediaQuery.of(context).size.width,
        // ),
        image);
    List<List<Widget>> gridArray = List.generate(15, (_) => new List(15));

    gridArray.asMap().forEach((row, items) {
      items.asMap().forEach((col, eachItem) {
        int x = get1DPosfrom2D(int.parse("$row$col"));
        // int position = getActualposition(x, pos);

        double bottom = getBottom(context, row);
        double left = getLeft(context, col);
        Map<int, dynamic> currentOffsets = offsets;

        layoutItems.add(Positioned(
            bottom: bottom,
            left: left,
            child: ((row <= 5 && (col <= 5 || col > 8)) ||
                    (row > 8 && (col <= 5 || col > 8)))
                ? IgnorePointer(child: Container())
                : GestureDetector(
                    onTap: () {
                      print('onTap #6 move: ' +
                          move.toString() +
                          ' moveItem: ' +
                          moveItem.toString());
                      if (move && isLegal(row, col, moveItem)) {
                        currentOffsets = unhighlightAll(currentOffsets);
                        currentOffsets[moveItem]["bottom"] = bottom * 1.05;
                        currentOffsets[moveItem]["left"] = left;
                        currentOffsets[moveItem]["moved"] = true;
                        currentOffsets[moveItem]["highlighted"] = false;
                        currentOffsets[moveItem]["predicted"] = false;
                        currentOffsets[moveItem]["position"] =
                            getActualposition(x,
                                int.parse(moveItem.toString().split("").last));
                        print('############ 2 SETTING xPosition OF $moveItem' +
                            x.toString());
                        currentOffsets[moveItem]["xPosition"] = x;
                        setState(() {
                          move = false;
                          offsets = currentOffsets;
                        });
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
//                        margin: EdgeInsets.only(
//                          bottom: 5,
//                        ),
//                         child: Text(
//                           "$x",
//                           style: TextStyle(color: Colors.black),
//                         ),
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width * 0.0667,
                        height: MediaQuery.of(context).size.width * 0.0667))));
      });
    });

    layoutItems.addAll([
      renderGoti(0, 0),
      renderGoti(1, 0),
      renderGoti(2, 0),
      renderGoti(3, 0),
      renderGoti(0, 1),
      renderGoti(1, 1),
      renderGoti(2, 1),
      renderGoti(3, 1),
      renderGoti(0, 2),
      renderGoti(1, 2),
      renderGoti(2, 2),
      renderGoti(3, 2),
      renderGoti(0, 3),
      renderGoti(1, 3),
      renderGoti(2, 3),
      renderGoti(3, 3)
    ]);

    return layoutItems;
  }

  void changeSize(x, moveItem) {
    print('------------->in changeSize()');
    Map<int, dynamic> currentOffsets = offsets;

    List keysToBeModfied = [];

    currentOffsets.forEach((key, value) {
      if (value["xPosition"] == x && x != -1) {
        keysToBeModfied.add(key);
      }
    });

    for (int i = 0; i < keysToBeModfied.length; i++) {
      // currentOffsets[keysToBeModfied[i]]["sizeMultiplier"] =
      // currentOffsets[keysToBeModfied[i]]["bottom"] =
      //    currentOffsets[keysToBeModfied[i]]["bottom"] - 2;

      // print(bottom);
      // currentOffsets[keysToBeModfied[i]]["left"] = left;
    }
    setState(() {
      offsets = currentOffsets;
    });
  }

  Widget colorDropDown(String label, Function setStateFunc) {
    print('------------->in colorDropDown()');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.green.shade400, width: 2),
          borderRadius: BorderRadius.circular(25)),
      width: MediaQuery.of(context).size.width * 0.65,
      child: DropdownButton(
        underline: Container(),
        style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
        elevation: 0,
        isExpanded: true,
        items: availableColors
            .map((e) => new DropdownMenuItem(
                value: e["name"],
                child: Text(
                  e["name"].toString().toUpperCase(),
                  style: TextStyle(
                      fontSize: 18, fontFamily: 'Roboto', color: Colors.black),
                )))
            .toList(),
        value: selectedColor,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.green,
        ),
        hint: Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 25),
        ),
        onChanged: (item) {
          setStateFunc(() {
            selectedColor = item;
          });
        },
      ),
    );
  }

  Widget centerSquare() {
    List<Widget> centerTriangles = [];
    selectedColorList.asMap().forEach((index, value) {
      centerTriangles.add(Align(
        alignment: alignments[index],
        child: value == null
            ? Container()
            : Image.asset(
                "assets/${trianglePositions[index]}_${value["name"]}.png"),
      ));
    });

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Stack(
          children: centerTriangles,
        ),
      ),
    );
  }

  Widget bottomRow(int position) {
    print('------------->in bottomRow()');
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Stack(children: [
        GestureDetector(
          // child: SvgPicture.asset(
          //   "assets/popup_ok.svg",
          //   height: 40,
          //   color: Colors.green.shade300,
          // ),
          child: Container(
              width: 140,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.green.shade400, width: 6)),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              )),
          onTap: () {
            // if (currentPlayerName != null) {
            savePlayer(position);
            Navigator.pop(context);
            // } else {
            //   SnackBar(
            //     content: Text(
            //       "Please insert a name to save the player",
            //     ),
            //     duration: Duration(seconds: 1),
            //   );
            // }
          },
        ),
      ])
    ]);
  }

  Widget playerAddButton(int position) {
    return GestureDetector(
      onTap: () {
        print('onTap #8');
        addMemberDialog(position);
      },
      child: Row(
        children: <Widget>[
          (position == 0 || position == 1) ? avatar(position) : name(position),
          (position == 0 || position == 1) ? name(position) : avatar(position)
        ],
      ),
    );
  }

  Widget name(position) {
    return Text(selectedColorList[position] != null
        ? selectedColorList[position]["playerName"] != null
            ? selectedColorList[position]["playerName"]
            : ""
        : "");
  }

  Widget avatar(position) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      width: 50,
      height: 50,
      child: selectedColorList[position] != null
          ? Center(
              child: Image.asset(
                  "assets/avatar_${selectedColorList[position]["name"]}.png"),
            )
          : Center(
              child: Icon(Icons.add),
            ),
    );
  }

  void savePlayer(int position) {
    print('------------->in savePlayer()');
    List<Map<String, dynamic>> currentList = selectedColorList;
    currentList[position] = availableColors
        .firstWhere((element) => element["name"] == selectedColor);
    currentList[position]["playerName"] = currentPlayerName;
    List<Map<String, dynamic>> currentColors = availableColors;
    currentColors.removeWhere((element) => element["name"] == selectedColor);

    setState(() {
      selectedColorList = currentList;
      availableColors = currentColors;
      selectedColor =
          availableColors.length == 0 ? "red" : availableColors[0]["name"];
      currentPlayerName = null;
    });
  }

  Widget colorBox(int position) {
    if (selectedColorList[position] != null) {
      switch (position) {
        case 0:
          return bottomLeft(
              selectedColorList[position], context, position, positions);

          break;
        case 1:
          return topLeft(
              selectedColorList[position], context, position, positions);

          break;
        case 2:
          return topRight(
              selectedColorList[position], context, position, positions);

          break;
        case 3:
          return bottomRight(
              selectedColorList[position], context, position, positions);

          break;
        default:
          return Container();
      }
    } else {
      return Container();
    }
  }

  Widget screenBottomRow() {
    print('------------->in screenBottomRow()');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(children: [
          GestureDetector(
            onTap: () {
              print('onTap #9');
              resetDialog();
            },
            child: Image.asset(
              "assets/reset_icon.png",
              width: 30,
              fit: BoxFit.contain,
            ),
          ),
          Text('reset game')
        ]),
        SizedBox(
          width: 20,
        ),
        Row(
            children: [1, 2, 3, 4, 5, 6]
                .map((e) => GestureDetector(
                      onTap: () {
                        print('onTap #10');
                        onDiceTap(e);
                      },
                      child: Image.asset(
                        "assets/dice-$e.png",
                        fit: BoxFit.fill,
                        width: diceNo == e
                            ? MediaQuery.of(context).size.width * 0.12
                            : MediaQuery.of(context).size.width * 0.10,
                        height: diceNo == e
                            ? MediaQuery.of(context).size.width * 0.12
                            : MediaQuery.of(context).size.width * 0.10,
                      ),
                    ))
                .toList())
      ],
    );
  }

  void onDiceTap(int number) {
    print('------------->in onDiceTap()');
    Map<int, dynamic> currentOffsets = offsets;
    setState(() {
      diceNo = number;
    });
    int index = startGameSuggestion(getCurrentBoardStatus(number));
    if (index != -1) {
      currentOffsets = unhighlightAll(currentOffsets);
      currentOffsets[int.parse("${index}0")]["highlighted"] = true;
      currentOffsets[int.parse("${index}0")]["predicted"] = true;
      setState(() {
        diceNo = number;

        offsets = currentOffsets;
      });
    }
  }

  bool isSafePosition(int xPosition) {
    print('isSafePosition: ' + xPosition.toString());
    List<int> safePositions = [0, 8, 13, 21, 26, 34, 39, 47];
    for (int i = 0; i < safePositions.length; i++) {
      if (safePositions[i] == xPosition) {
        return true;
      }
    }
    return false;
  }

  Map getCurrentBoardStatus(int noOnDice) {
    print('------------->in getCurrentBoardStatus()');
    return {
      "0": {
        "0": offsets[00]["position"],
        "1": offsets[10]["position"],
        "2": offsets[20]["position"],
        "3": offsets[30]["position"]
      },
      "1": {
        "0": offsets[01]["position"],
        "1": offsets[11]["position"],
        "2": offsets[21]["position"],
        "3": offsets[31]["position"]
      },
      "2": {
        "0": offsets[02]["position"],
        "1": offsets[12]["position"],
        "2": offsets[22]["position"],
        "3": offsets[32]["position"]
      },
      "3": {
        "0": offsets[03]["position"],
        "1": offsets[13]["position"],
        "2": offsets[23]["position"],
        "3": offsets[33]["position"]
      },
      "noOnDice": noOnDice
    };
  }

  // x is xposition and pos is playerIndex
  int getActualposition(int x, int pos) {
    print('------------->in getActualposition()');
    int offset =
        pos == 0 ? 0 : pos == 1 ? 13 : pos == 2 ? 26 : pos == 3 ? 39 : null;

    if (offset != null) {
      if ((x - offset) < 0) {
        return (52 - offset) + x;
      } else {
        return x - offset;
      }
    } else {
      return 0;
    }
  }

  void moveGotiDialog(List<int> positions) {
    print("MULTIPLE MOVE DIALOG $positions");
    double size = MediaQuery.of(context).size.width * 0.064;
    Map<int, dynamic> currentOffsets = offsets;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              scrollable: true,
              title: Container(
                width: MediaQuery.of(context).size.width * 0.66,
                child: topRow(context, "SELECT TOKEN"),
              ),
              content: Column(children: [
                new Wrap(
                    // height: 250,
                    children: positions
                        .map((e) => GestureDetector(
                            onTap: () {
                              // currentOffsets[e]["highlighted"] = true;
                              for (int i = 0; i < positions.length; i++) {
                                if (e != positions[i]) {
                                  currentOffsets[positions[i]]["highlighted"] =
                                      false;
                                } else {
                                  currentOffsets[positions[i]]["highlighted"] =
                                      true;
                                }
                              }
                              setState(() {
                                move = true;
                                moveItem = e;
                                offsets = currentOffsets;
                              });
                            },
                            child: Container(
                                child: Image.asset(
                              currentOffsets[e]["highlighted"]
                                  ? "assets/_goti_${selectedColorList[int.parse(e.toString().split("").last)]["name"]}.png"
                                  : "assets/goti_${selectedColorList[int.parse(e.toString().split("").last)]["name"]}.png",
                              width: size,
                              height: size,
                              fit: BoxFit.fitHeight,
                            ))))
                        .toList()),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                        margin: EdgeInsets.all(10),
                        width: 140,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.green.shade400, width: 6)),
                        child: Text(
                          'OK',
                          style: TextStyle(color: Colors.white),
                        )))
              ]),
            );
          });
        });
  }
}
