import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';

import 'package:ludo_planner/widgets/appbar.dart';
import 'package:ludo_planner/widgets/bottomLeft.dart';
import 'package:ludo_planner/widgets/topLeft.dart';
import 'package:ludo_planner/widgets/topRight.dart';
import 'package:ludo_planner/widgets/bottomRight.dart';
import 'package:ludo_planner/utils/positions.dart';
import 'package:ludo_planner/service/service.dart';

class HomeScreen extends StatefulWidget {
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

  Map<dynamic, dynamic> defaultOffsets = {
    00: {
      "initBottom": BASEBOTTOM2,
      "initLeft": BASELEFT2,
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
      "initBottom": BASEBOTTOM2 * 2.2,
      "initLeft": BASELEFT2,
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
      "initBottom": BASEBOTTOM2 * 2.3,
      "initLeft": BASELEFT2 * 2.2,
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
      "initBottom": BASEBOTTOM2,
      "initLeft": BASELEFT2 * 2.2,
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
      "initBottom": BASEBOTTOM13,
      "initLeft": BASELEFT2,
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
      "initBottom": BASEBOTTOM13 * 1.2,
      "initLeft": BASELEFT2,
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
      "initBottom": BASEBOTTOM13 * 1.2,
      "initLeft": BASELEFT2 * 2.2,
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
      "initBottom": BASEBOTTOM13,
      "initLeft": BASELEFT2 * 2.2,
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
      "initBottom": BASEBOTTOM13,
      "initLeft": BASELEFT13,
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
      "initBottom": BASEBOTTOM13 * 1.2,
      "initLeft": BASELEFT13,
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
      "initBottom": BASEBOTTOM13 * 1.2,
      "initLeft": BASELEFT13 * 1.2,
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
      "initBottom": BASEBOTTOM13,
      "initLeft": BASELEFT13 * 1.2,
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
      "initBottom": BASEBOTTOM2,
      "initLeft": BASELEFT13,
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
      "initBottom": BASEBOTTOM2 * 2.3,
      "initLeft": BASELEFT13,
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
      "initBottom": BASEBOTTOM2 * 2.3,
      "initLeft": BASELEFT13 * 1.2,
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
      "initBottom": BASEBOTTOM2,
      "initLeft": BASELEFT13 * 1.2,
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

  // Board map UI format
  Map<dynamic, dynamic> offsets = {
    00: {
      "initBottom": BASEBOTTOM2,
      "initLeft": BASELEFT2,
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
      "initBottom": BASEBOTTOM2 * 2.2,
      "initLeft": BASELEFT2,
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
      "initBottom": BASEBOTTOM2 * 2.3,
      "initLeft": BASELEFT2 * 2.2,
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
      "initBottom": BASEBOTTOM2,
      "initLeft": BASELEFT2 * 2.2,
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
      "initBottom": BASEBOTTOM13,
      "initLeft": BASELEFT2,
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
      "initBottom": BASEBOTTOM13 * 1.2,
      "initLeft": BASELEFT2,
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
      "initBottom": BASEBOTTOM13 * 1.2,
      "initLeft": BASELEFT2 * 2.2,
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
      "initBottom": BASEBOTTOM13,
      "initLeft": BASELEFT2 * 2.2,
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
      "initBottom": BASEBOTTOM13,
      "initLeft": BASELEFT13,
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
      "initBottom": BASEBOTTOM13 * 1.2,
      "initLeft": BASELEFT13,
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
      "initBottom": BASEBOTTOM13 * 1.2,
      "initLeft": BASELEFT13 * 1.2,
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
      "initBottom": BASEBOTTOM13,
      "initLeft": BASELEFT13 * 1.2,
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
      "initBottom": BASEBOTTOM2,
      "initLeft": BASELEFT13,
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
      "initBottom": BASEBOTTOM2 * 2.3,
      "initLeft": BASELEFT13,
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
      "initBottom": BASEBOTTOM2 * 2.3,
      "initLeft": BASELEFT13 * 1.2,
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
      "initBottom": BASEBOTTOM2,
      "initLeft": BASELEFT13 * 1.2,
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
          "initBottom": BASEBOTTOM2,
          "initLeft": BASELEFT2,
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
          "initBottom": BASEBOTTOM2 * 2.2,
          "initLeft": BASELEFT2,
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
          "initBottom": BASEBOTTOM2 * 2.3,
          "initLeft": BASELEFT2 * 2.2,
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
          "initBottom": BASEBOTTOM2,
          "initLeft": BASELEFT2 * 2.2,
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
          "initBottom": BASEBOTTOM13,
          "initLeft": BASELEFT2,
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
          "initBottom": BASEBOTTOM13 * 1.2,
          "initLeft": BASELEFT2,
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
          "initBottom": BASEBOTTOM13 * 1.2,
          "initLeft": BASELEFT2 * 2.2,
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
          "initBottom": BASEBOTTOM13,
          "initLeft": BASELEFT2 * 2.2,
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
          "initBottom": BASEBOTTOM13,
          "initLeft": BASELEFT13,
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
          "initBottom": BASEBOTTOM13 * 1.2,
          "initLeft": BASELEFT13,
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
          "initBottom": BASEBOTTOM13 * 1.2,
          "initLeft": BASELEFT13 * 1.2,
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
          "initBottom": BASEBOTTOM13,
          "initLeft": BASELEFT13 * 1.2,
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
          "initBottom": BASEBOTTOM2,
          "initLeft": BASELEFT13,
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
          "initBottom": BASEBOTTOM2 * 2.3,
          "initLeft": BASELEFT13,
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
          "initBottom": BASEBOTTOM2 * 2.3,
          "initLeft": BASELEFT13 * 1.2,
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
          "initBottom": BASEBOTTOM2,
          "initLeft": BASELEFT13 * 1.2,
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
    Future.delayed(const Duration(milliseconds: SPLASH_DURATION), () {
      setState(() {
        showSplash = false;
      });
    });
  }

  Widget renderGoti(int count, int position) {
    print('------------->in renderGoti()');
    if (selectedColorList[position] != null) {
      double init = MediaQuery.of(context).size.width * 0.054;
      double size = MediaQuery.of(context).size.width *
          0.064 *
          offsets[int.parse("$count$position")]["sizeMultiplier"];
      double initBottom =
          init * offsets[int.parse("$count$position")]["initBottom"];
      double initLeft =
          init * offsets[int.parse("$count$position")]["initLeft"];

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
                    Map<dynamic, dynamic> currentOffsets = offsets;
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

                    Map<dynamic, dynamic> currentOffsets = offsets;

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
                      if(offsets[int.parse("$count$position")]["xPosition"] == -1) {
                        unhighlightAll(currentOffsets);
                        print("EXCHANGING SELECTION");
                        // TODO: do the exchange here
                        moveItem = int.parse("$count$position");
                        currentOffsets[moveItem]["highlighted"] = true;
                        setState(() {
                          move = true;
                          offsets = currentOffsets;
                        });
                      }else {
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
                        if (currentOffsets[moveItem]["playerIndex"] != currentOffsets[int.parse("$count$position")]["playerIndex"] &&
                            isSafePosition(currentOffsets[int.parse("$count$position")]["xPosition"]) == false) {
                          print("KILLING!!!!!!!!!!!!!!!!!!!!!!!!!!");
                          currentOffsets[int.parse("$count$position")] =
                          defaultOffsets[int.parse("$count$position")];
                          currentOffsets[int.parse("$count$position")]["moved"] =
                          false;
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
                    Map<dynamic, dynamic> currentOffsets = offsets;
                    if (currentOffsets[int.parse("$count$position")]
                            ["predicted"] ==
                        true) {
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
                    child: Image.asset(
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

  Map<dynamic, dynamic> adjustForMultipleOnOne(Map<dynamic, dynamic> currentOffsets) {
    for(int xPosition=0; xPosition<57; xPosition++) {
      print('in adjustForMultipleOnOne xPosition: ' + xPosition.toString());
      List<int> rowClm = get2Dfrom1D(xPosition);
      int row = rowClm[0];
      int clm = rowClm[1];
      print("ROW: " + row.toString());
      print("CLM: " + clm.toString());
      List<int> overlapingKeys = [];
      currentOffsets.forEach((key, value) {
        if (value['xPosition'] == xPosition) {
          overlapingKeys.add(key);
        }
      });

      if (overlapingKeys.length > 1) {
        double gap = ((getLeft(1) - getLeft(0)) / overlapingKeys.length) * 0.6;

        for (int i = 0; i < overlapingKeys.length; i++) {
          int center = (overlapingKeys.length / 2).floor();
          if ((overlapingKeys.length % 2) == 0) {
            print("even");
            if (i < center) {
              print(i.toString() + ' : ' + getLeft(clm).toString() + " : " +
                  (getLeft(clm) + gap * (i - center)).toString());
              currentOffsets[overlapingKeys[i]]['left'] =
                  getLeft(clm) + gap * (i - center);
            } else {
              print(i.toString() + ' : ' + getLeft(clm).toString() + " : " +
                  (getLeft(clm) + gap * (i - center + 1)).toString());
              currentOffsets[overlapingKeys[i]]['left'] =
                  getLeft(clm) + gap * (i - center + 1);
            }
          } else {
            print("odd");
            print(i.toString() + ' : ' + getLeft(clm).toString() + " : " +
                (getLeft(clm) + gap * (i - center)).toString());
            currentOffsets[overlapingKeys[i]]['left'] =
                getLeft(clm) + gap * (i - center);
          }
          currentOffsets[overlapingKeys[i]]['sizeMultiplier'] =
              1.5 / overlapingKeys.length;
          currentOffsets[overlapingKeys[i]]['onMultiple'] = true;
        }

        print("adjustForMultipleOnOne gap: " + gap.toString() + " : " +
            overlapingKeys.toString());
      }
    }
    print(currentOffsets.toString());
    return currentOffsets;
  }

  Map<dynamic, dynamic> unhighlightAll(Map<dynamic, dynamic> currentOffsets) {
    currentOffsets.forEach((key, value) {
      value["highlighted"] = false;
      value["predicted"] = false;
      value['sizeMultiplier'] = 1;
      value['onMultiple'] = false;
      if(value['xPosition'] != -1) {
        value['left'] = getLeft(get2Dfrom1D(value['xPosition'])[1]);
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
    double bottom = getBottom(row);
    double left = getLeft(clm);
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
      if ((currentOffsets[moveItem]["playerIndex"] != currentOffsets[key]["playerIndex"]) &&
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
          appBar: appBar(),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[playerAddButton(1), playerAddButton(2)],
                ),
                Center(
                  child: Container(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black)),
                      child: Stack(
                        children: layout(),
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[playerAddButton(0), playerAddButton(3)],
                ),
                screenBottomRow()
              ]),
        ),
      ),
      showSplash
          ? Container(
              height: MediaQuery.of(context).size.height,
              // decoration: BoxDecoration(
              //     image:
              //         DecorationImage(image: image1.image, fit: BoxFit.cover)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      // child: Image.asset('assets/logo.png'),\
                      child: CircularProgressIndicator(),
                      size: Size(30, 30),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            )
          : Container()
    ]);
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "SELECT COLOR",
                      style: TextStyle(color: Colors.green.shade400),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('onTap #3');
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

        double bottom = getBottom(row);
        double left = getLeft(col);
        Map<dynamic, dynamic> currentOffsets = offsets;

        layoutItems.add(Positioned(
            bottom: bottom,
            left: left,
            child: ((row <= 5 && (col <= 5 || col > 8)) ||
                    (row > 8 && (col <= 5 || col > 8)))
                ? IgnorePointer(child: Container())
                : GestureDetector(
                    onTap: () {
                      print('onTap #6 move: ' + move.toString() + ' moveItem: ' + moveItem.toString());
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
                        print('############ 2 SETTING xPosition to' +
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
    Map<dynamic, dynamic> currentOffsets = offsets;

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
            print('onTap #7');
            if (currentPlayerName != null) {
              savePlayer(position);
              Navigator.pop(context);
            } else {
              SnackBar(
                content: Text(
                  "Please insert a name to save the player",
                ),
                duration: Duration(seconds: 1),
              );
            }
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
        ? selectedColorList[position]["playerName"]
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
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.10,
                        height: MediaQuery.of(context).size.width * 0.10,
                      ),
                    ))
                .toList())
      ],
    );
  }

  void onDiceTap(int number) {
    print('------------->in onDiceTap()');
    Map<dynamic, dynamic> currentOffsets = offsets;
    diceNo = number;
    int index = startGameSuggestion(getCurrentBoardStatus(number));
    if (index != -1) {
      currentOffsets = unhighlightAll(currentOffsets);
      currentOffsets[int.parse("${index}0")]["highlighted"] = true;
      currentOffsets[int.parse("${index}0")]["predicted"] = true;
      setState(() {
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

  int get1DPosfrom2D(int rowcol) {
    switch (rowcol) {
      case 16:
        return 0;
      case 26:
        return 1;
      case 36:
        return 2;
      case 46:
        return 3;
      case 56:
        return 4;
      case 65:
        return 5;
      case 64:
        return 6;
      case 63:
        return 7;
      case 62:
        return 8;
      case 61:
        return 9;
      case 60:
        return 10;
      case 70:
        return 11;
      case 80:
        return 12;
      case 81:
        return 13;
      case 82:
        return 14;
      case 83:
        return 15;
      case 84:
        return 16;
      case 85:
        return 17;
      case 96:
        return 18;
      case 106:
        return 19;
      case 116:
        return 20;
      case 126:
        return 21;
      case 136:
        return 22;
      case 146:
        return 23;
      case 147:
        return 24;
      case 148:
        return 25;
      case 138:
        return 26;
      case 128:
        return 27;
      case 118:
        return 28;
      case 108:
        return 29;
      case 98:
        return 30;
      case 89:
        return 31;
      case 810:
        return 32;
      case 811:
        return 33;
      case 812:
        return 34;
      case 813:
        return 35;
      case 814:
        return 36;
      case 714:
        return 37;
      case 614:
        return 38;
      case 613:
        return 39;
      case 612:
        return 40;
      case 611:
        return 41;
      case 610:
        return 42;
      case 69:
        return 43;
      case 58:
        return 44;
      case 48:
        return 45;
      case 38:
        return 46;
      case 28:
        return 47;
      case 18:
        return 48;
      case 08:
        return 49;
      case 07:
        return 50;
      case 17:
        return 51;
      case 27:
        return 52;
      case 37:
        return 53;
      case 47:
        return 54;
      case 57:
        return 55;
      case 67:
        return 56;
      default:
        return -1;
    }
  }

  List<int> get2Dfrom1D(int x) {
    List<int> rowClm = List<int>();
    switch (x) {
      case 0:
        rowClm.add(1);
        rowClm.add(6);
        return rowClm;
      case 1:
        rowClm.add(2);
        rowClm.add(6);
        return rowClm;
      case 2:
        rowClm.add(3);
        rowClm.add(6);
        return rowClm;
      case 3:
        rowClm.add(4);
        rowClm.add(6);
        return rowClm;
      case 4:
        rowClm.add(5);
        rowClm.add(6);
        return rowClm;
      case 5:
        rowClm.add(6);
        rowClm.add(5);
        return rowClm;
      case 6:
        rowClm.add(6);
        rowClm.add(4);
        return rowClm;
      case 7:
        rowClm.add(6);
        rowClm.add(3);
        return rowClm;
      case 8:
        rowClm.add(6);
        rowClm.add(2);
        return rowClm;
      case 9:
        rowClm.add(6);
        rowClm.add(1);
        return rowClm;
      case 10:
        rowClm.add(6);
        rowClm.add(0);
        return rowClm;
      case 11:
        rowClm.add(7);
        rowClm.add(0);
        return rowClm;
      case 12:
        rowClm.add(8);
        rowClm.add(0);
        return rowClm;
      case 13:
        rowClm.add(8);
        rowClm.add(1);
        return rowClm;
      case 14:
        rowClm.add(8);
        rowClm.add(2);
        return rowClm;
      case 15:
        rowClm.add(8);
        rowClm.add(3);
        return rowClm;
      case 16:
        rowClm.add(8);
        rowClm.add(4);
        return rowClm;
      case 17:
        rowClm.add(8);
        rowClm.add(5);
        return rowClm;
      case 18:
        rowClm.add(9);
        rowClm.add(6);
        return rowClm;
      case 19:
        rowClm.add(10);
        rowClm.add(6);
        return rowClm;
      case 20:
        rowClm.add(11);
        rowClm.add(6);
        return rowClm;
      case 21:
        rowClm.add(12);
        rowClm.add(6);
        return rowClm;
      case 22:
        rowClm.add(13);
        rowClm.add(6);
        return rowClm;
      case 23:
        rowClm.add(14);
        rowClm.add(6);
        return rowClm;
      case 24:
        rowClm.add(14);
        rowClm.add(7);
        return rowClm;
      case 25:
        rowClm.add(14);
        rowClm.add(8);
        return rowClm;
      case 26:
        rowClm.add(13);
        rowClm.add(8);
        return rowClm;
      case 27:
        rowClm.add(12);
        rowClm.add(8);
        return rowClm;
      case 28:
        rowClm.add(11);
        rowClm.add(8);
        return rowClm;
      case 29:
        rowClm.add(10);
        rowClm.add(8);
        return rowClm;
      case 30:
        rowClm.add(9);
        rowClm.add(8);
        return rowClm;
      case 31:
        rowClm.add(8);
        rowClm.add(9);
        return rowClm;
      case 32:
        rowClm.add(8);
        rowClm.add(10);
        return rowClm;
      case 33:
        rowClm.add(8);
        rowClm.add(11);
        return rowClm;
      case 34:
        rowClm.add(8);
        rowClm.add(12);
        return rowClm;
      case 35:
        rowClm.add(8);
        rowClm.add(13);
        return rowClm;
      case 36:
        rowClm.add(8);
        rowClm.add(14);
        return rowClm;
      case 37:
        rowClm.add(7);
        rowClm.add(14);
        return rowClm;
      case 38:
        rowClm.add(6);
        rowClm.add(14);
        return rowClm;
      case 39:
        rowClm.add(6);
        rowClm.add(13);
        return rowClm;
      case 40:
        rowClm.add(6);
        rowClm.add(12);
        return rowClm;
      case 41:
        rowClm.add(6);
        rowClm.add(11);
        return rowClm;
      case 42:
        rowClm.add(6);
        rowClm.add(10);
        return rowClm;
      case 43:
        rowClm.add(6);
        rowClm.add(9);
        return rowClm;
      case 44:
        rowClm.add(5);
        rowClm.add(8);
        return rowClm;
      case 45:
        rowClm.add(4);
        rowClm.add(8);
        return rowClm;
      case 46:
        rowClm.add(3);
        rowClm.add(8);
        return rowClm;
      case 47:
        rowClm.add(2);
        rowClm.add(8);
        return rowClm;
      case 48:
        rowClm.add(1);
        rowClm.add(8);
        return rowClm;
      case 49:
        rowClm.add(0);
        rowClm.add(8);
        return rowClm;
      case 50:
        rowClm.add(0);
        rowClm.add(7);
        return rowClm;
      case 51:
        rowClm.add(1);
        rowClm.add(7);
        return rowClm;
      case 52:
        rowClm.add(2);
        rowClm.add(7);
        return rowClm;
      case 53:
        rowClm.add(3);
        rowClm.add(7);
        return rowClm;
      case 54:
        rowClm.add(4);
        rowClm.add(7);
        return rowClm;
      case 55:
        rowClm.add(5);
        rowClm.add(7);
        return rowClm;
      case 56:
        rowClm.add(6);
        rowClm.add(7);
        return rowClm;
      default:
        rowClm.add(null);
        rowClm.add(null);
        return rowClm;
    }
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

  bool isLegal(int row, int col, int moveItem) {
    print('ROW: ' + row.toString() + ' CLM: ' + col.toString());
    if ((row == 7 && col == 7) ||
        (row == 8 && col == 8) ||
        (row == 6 && col == 8) ||
        (row == 6 && col == 6) ||
        (row == 8 && col == 6)) {
      return false;
    }

    // for player at bottom left
    if (moveItem == 0 || moveItem == 10 || moveItem == 20 || moveItem == 30) {
      if (row == 7 && col <= 6 && col >= 1) {
        return false;
      }
      if (col == 7 && row <= 13 && row >= 8) {
        return false;
      }
      if (row == 7 && col <= 13 && col >= 8) {
        return false;
      }
      if (row == 0 && col == 6) {
        return false;
      }
    }

    // for player at top left
    if (moveItem == 1 || moveItem == 11 || moveItem == 21 || moveItem == 31) {
      if (col == 7 && row <= 13 && row >= 8) {
        return false;
      }
      if (row == 7 && col <= 13 && col >= 8) {
        return false;
      }
      if (col == 7 && row <= 6 && row >= 1) {
        return false;
      }
      if (row == 8 && col == 0) {
        return false;
      }
    }

    // for player at top right
    if (moveItem == 2 || moveItem == 12 || moveItem == 22 || moveItem == 32) {
      if (row == 7 && col <= 6 && col >= 1) {
        return false;
      }
      if (row == 7 && col <= 13 && col >= 8) {
        return false;
      }
      if (col == 7 && row <= 6 && row >= 1) {
        return false;
      }
      if (row == 14 && col == 8) {
        return false;
      }
    }

    // for player at top right
    if (moveItem == 3 || moveItem == 13 || moveItem == 23 || moveItem == 33) {
      if (row == 7 && col <= 6 && col >= 1) {
        return false;
      }
      if (col == 7 && row <= 13 && row >= 8) {
        return false;
      }
      if (col == 7 && row <= 6 && row >= 1) {
        return false;
      }
      if (row == 6 && col == 14) {
        return false;
      }
    }
    return true;
  }

  double getBottom(int row) {
    double correction = MediaQuery.of(context).size.height / 61.3026819923;
    if (row < 7) {
      return MediaQuery.of(context).size.width * 0.0667 * row +
          ((correction * (row - 7).abs()) / 7);
    }
    if (row > 7) {
      return MediaQuery.of(context).size.width * 0.0667 * row -
          ((correction * (row - 7).abs()) / 7);
    }
    return MediaQuery.of(context).size.width * 0.0667 * row;
  }

  double getLeft(int col) {
    double correction = MediaQuery.of(context).size.width / 72;
    if (col < 7) {
      return MediaQuery.of(context).size.width * 0.0667 * col +
          ((correction * (col - 7).abs()) / 7);
    }
    if (col > 7) {
      return MediaQuery.of(context).size.width * 0.0667 * col -
          ((correction * (col - 7).abs()) / 7);
    }
    return MediaQuery.of(context).size.width * 0.0667 * col;
  }
}
