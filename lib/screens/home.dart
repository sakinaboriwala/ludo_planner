import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
import 'package:ludo_planner/utils/database.dart';

import 'package:ludo_planner/models/user.dart';
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
    {"name": "green", "value": Colors.green},
    {"name": "yellow", "value": Colors.yellow},
    {"name": "blue", "value": Colors.blue},
  ];
  List<Map<String, dynamic>> allColors = [
    {"name": "red", "value": Colors.red},
    {"name": "green", "value": Colors.green},
    {"name": "yellow", "value": Colors.yellow},
    {"name": "blue", "value": Colors.blue},
  ];

  String selectedColor = "red";
  String currentPlayerName;
  List<Map<String, dynamic>> selectedColorList = [
    {"playerName": null, "kills": 0, "houses": 0, "name": null},
    {"playerName": null, "kills": 0, "houses": 0, "name": null},
    {"playerName": null},
    {"playerName": null, "kills": 0, "houses": 0, "name": null}
  ];

  List<Widget> gridItems = List.generate(15, (index) => Container());
  bool isLoading = true;
  bool move = false;
  bool playerAutoMove = true;
  int tappedPlayer = 0;
  bool init = false;
  int moveItem;
  int diceNo;
  List<int> invalidDiceNos = [];
  String predictionText = '';
  Image image = Image.asset("assets/board_wireframe.png");
  Image image1 = Image.asset("assets/ludo_background.png");
  List<User> users = [];
  // List<Map<int, dynamic>>;
  List<Map<int, dynamic>> prevOffsets = [];
  bool showSplash = true;
  bool infoRecvd = false;
  bool offsetsSet = false;
  bool dbSet = false;
  bool first = true;
  bool killed = false;
  List<int> playerTurns = [];
  final TextEditingController _typeAheadController = TextEditingController();

  static const double BASEBOTTOM2 = 2.0;
  static const double BASEBOTTOM13 = 13.0;

  static const double BASELEFT2 = 2.0;
  static const double BASELEFT13 = 13.0;
  static const SPLASH_DURATION = 5000;

  int winningPlayer = 0;

  // Map<int, dynamic> defaultOffsets;

  // Board map UI format
  Map<int, dynamic> offsets;

  @override
  Widget build(BuildContext context) {
    // print("VARS --------------__________________----------------------_________________________________________________");
    // print(!(infoRecvd && dbSet && offsetsSet));
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/ludo_background.png"),
                fit: BoxFit.cover)),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar(context, showSplash, undo),
            body: showSplash || !(infoRecvd && dbSet && offsetsSet)
                ? SplashScreen()
                : Stack(children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          selectedColorList[2] == null
                              ? Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.transparent)
                              : availableColors.length < 2
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[playerAddButton(2)],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                              selectedColorList[0] == null
                                  ? Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.transparent)
                                  : playerAddButton(0),
                              playerAddButton(3)
                            ],
                          ),
                          screenBottomRow(),
                        ]),
                    Positioned(
                      bottom: 0,
                      child: Center(
                          child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(0),
                        child: Text("v1.2.8"),
                      )),
                    ),
                    // Positioned(
                    //   top: 0,
                    //   right: 10,
                    //   child: Row(
                    //     children: <Widget>[
                    //       Text('UNDO'),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       GestureDetector(
                    //         onTap: undo,
                    //         child: Image.asset(
                    //           "assets/undo_icon.png",
                    //           width: 30,
                    //           fit: BoxFit.contain,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    selfDiceRow(),
                    Visibility(
                        visible: tappedPlayer == 0,
                        child: Positioned(
                          bottom: MediaQuery.of(context).size.height * 0.1,
                          left: 10,
                          child: Center(
                              child: Container(
                            alignment: Alignment.center,
                            // width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(0),
                            child: Text(
                              predictionText,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
                        )),
                    oppDiceRow(),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.12,
                      child: Visibility(
                          visible: availableColors.length < 2 &&
                              ((selectedColorList.length > 2 &&
                                      selectedColorList[2] != null)
                                  ? selectedColorList[2]['user'] != null
                                      ? true
                                      : false
                                  : false) &&
                              invalidDiceNos.length > 0 &&
                              tappedPlayer == 2,
                          child: Center(
                              child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                                "CANNOT GET ${invalidDiceNos.join(',')}",
                                style: TextStyle(color: Color(0xff465e6e))),
                          ))),
                    ),
                    endGameButton(),
                    selfStats()
                  ])),
      ),
    ]);
  }

  void undo() {
    // print("PREV OFFSETS LENGTH ____________________");
    // print(prevOffsets.length);
    // print(prevOffsets[0][00]);

    if ([...prevOffsets].length != 0) {
      List<Map<int, dynamic>> tempOffsets = prevOffsets;
      List<int> tempPrevTurns = playerTurns;

      int tempPlayer = tempPrevTurns[tempPrevTurns.length - 1];

      // print(tempOffsets[tempOffsets.length - 1]);

      // Map<int, dynamic> offsetRecvd = tempOffsets[0][00];

      Map<int, dynamic> tempofsetmap = {
        00: {
          "initBottom": tempOffsets[tempOffsets.length - 1][00]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][00]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][00]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][00]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][00]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][00]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][00]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][00]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][00]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][00]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][00]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][00]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][00]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][00]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][00]["kills"],
        },
        10: {
          "initBottom": tempOffsets[tempOffsets.length - 1][10]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][10]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][10]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][10]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][10]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][10]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][10]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][10]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][10]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][10]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][10]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][10]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][10]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][10]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][10]["kills"],
        },
        20: {
          "initBottom": tempOffsets[tempOffsets.length - 1][20]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][20]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][20]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][20]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][20]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][20]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][20]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][20]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][20]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][20]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][20]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][20]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][20]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][20]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][20]["kills"],
        },
        30: {
          "initBottom": tempOffsets[tempOffsets.length - 1][30]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][30]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][30]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][30]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][30]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][30]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][30]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][30]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][30]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][30]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][30]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][30]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][30]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][30]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][30]["kills"],
        },
        01: {
          "initBottom": tempOffsets[tempOffsets.length - 1][01]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][01]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][01]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][01]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][01]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][01]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][01]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][01]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][01]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][01]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][01]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][01]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][01]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][01]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][01]["kills"],
        },
        11: {
          "initBottom": tempOffsets[tempOffsets.length - 1][11]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][11]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][11]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][11]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][11]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][11]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][11]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][11]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][11]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][11]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][11]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][11]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][11]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][11]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][11]["kills"],
        },
        21: {
          "initBottom": tempOffsets[tempOffsets.length - 1][21]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][21]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][21]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][21]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][21]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][21]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][21]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][21]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][21]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][21]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][21]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][21]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][21]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][21]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][21]["kills"],
        },
        31: {
          "initBottom": tempOffsets[tempOffsets.length - 1][31]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][31]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][31]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][31]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][31]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][31]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][31]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][31]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][31]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][31]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][31]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][31]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][31]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][31]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][31]["kills"],
        },
        02: {
          "initBottom": tempOffsets[tempOffsets.length - 1][02]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][02]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][02]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][02]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][02]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][02]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][02]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][02]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][02]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][02]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][02]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][02]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][02]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][02]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][02]["kills"],
        },
        12: {
          "initBottom": tempOffsets[tempOffsets.length - 1][12]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][12]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][12]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][12]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][12]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][12]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][12]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][12]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][12]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][12]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][12]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][12]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][12]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][12]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][12]["kills"],
        },
        22: {
          "initBottom": tempOffsets[tempOffsets.length - 1][22]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][22]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][22]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][22]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][22]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][22]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][22]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][22]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][22]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][22]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][22]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][22]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][22]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][22]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][22]["kills"],
        },
        32: {
          "initBottom": tempOffsets[tempOffsets.length - 1][32]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][32]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][32]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][32]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][32]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][32]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][32]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][32]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][32]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][32]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][32]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][32]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][32]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][32]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][32]["kills"],
        },
        03: {
          "initBottom": tempOffsets[tempOffsets.length - 1][03]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][03]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][03]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][03]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][03]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][03]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][03]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][03]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][03]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][03]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][03]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][03]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][03]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][03]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][03]["kills"],
        },
        13: {
          "initBottom": tempOffsets[tempOffsets.length - 1][13]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][13]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][13]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][13]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][13]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][13]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][13]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][13]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][13]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][13]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][13]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][13]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][13]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][13]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][13]["kills"],
        },
        23: {
          "initBottom": tempOffsets[tempOffsets.length - 1][23]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][23]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][23]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][23]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][23]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][23]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][23]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][23]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][23]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][23]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][23]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][23]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][23]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][23]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][23]["kills"],
        },
        33: {
          "initBottom": tempOffsets[tempOffsets.length - 1][33]["initBottom"],
          "initLeft": tempOffsets[tempOffsets.length - 1][33]["initLeft"],
          "bottom": tempOffsets[tempOffsets.length - 1][33]["bottom"],
          "left": tempOffsets[tempOffsets.length - 1][33]["left"],
          "sameBottom": tempOffsets[tempOffsets.length - 1][33]["sameBottom"],
          "sameLeft": tempOffsets[tempOffsets.length - 1][33]["sameLeft"],
          "moved": tempOffsets[tempOffsets.length - 1][33]["moved"],
          "position": tempOffsets[tempOffsets.length - 1][33]["position"],
          "highlighted": tempOffsets[tempOffsets.length - 1][33]["highlighted"],
          "predicted": tempOffsets[tempOffsets.length - 1][33]["predicted"],
          "xPosition": tempOffsets[tempOffsets.length - 1][33]["xPosition"],
          "sizeMultiplier": tempOffsets[tempOffsets.length - 1][33]
              ["sizeMultiplier"],
          "playerIndex": tempOffsets[tempOffsets.length - 1][33]["playerIndex"],
          "onMultiple": tempOffsets[tempOffsets.length - 1][33]["onMultiple"],
          "kills": tempOffsets[tempOffsets.length - 1][33]["kills"],
        },
      };
      tempOffsets.removeAt(prevOffsets.length - 1);
      tempPrevTurns.removeAt(tempPrevTurns.length - 1);

      setState(() {
        offsets = new Map.fromEntries(tempofsetmap.entries);
        prevOffsets = tempOffsets;
        tappedPlayer = tempPlayer;
      });
    }
  }

  void reset() {
    // print('------------->in reset()');
    setState(() {
      prevOffsets = [];
      availableColors = [
        {"name": "red", "value": Colors.red},
        {"name": "yellow", "value": Colors.yellow},
        {"name": "blue", "value": Colors.blue},
        {"name": "green", "value": Colors.green},
      ];
      selectedColor = "red";
      currentPlayerName = "";
      selectedColorList = [
        {"playerName": null, "kills": 0, "houses": 0, "name": null},
        {"playerName": null, "kills": 0, "houses": 0, "name": null},
        {"playerName": null},
        {"playerName": null, "kills": 0, "houses": 0, "name": null}
      ];
      gridItems = List.generate(15, (index) => Container());
      move = false;
      diceNo = null;
      moveItem = null;
    });
    getInfo();
    setOffsets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(image.image, context);
  }

  void initState() {
    super.initState();
    Color color =
        allColors.firstWhere((element) => element["name"] == "red")["value"];

    postInit(() {
      getInfo();
      setOffsets();
      getUsers();
    });
  }

  void getUsers() async {
    List<User> temporaryUsers = await DBProvider.db.getUsers();
    // print("TEMP USERS ==========>>>>>>>>>>>>");
    // print(temporaryUsers);
    setState(() {
      users = temporaryUsers;
      dbSet = true;
    });
  }

  List<String> getSuggestions(String query) {
    // setState(() {
    //   currentPlayerName = query;
    // });
    if (query.trim() == '') {
      return [];
    } else {
      List<User> tempUsers = [...users];

      List<String> userNames = [];
      tempUsers.retainWhere((s) {
        if (s.name == null) {
          return false;
        } else {
          // print(s.name.toLowerCase());
          // print(query.toLowerCase());
          // print(s.name.toLowerCase().contains(query.toLowerCase()));
          return s.name.toLowerCase().contains(query.toLowerCase());
        }
      });

      [...tempUsers].asMap().forEach((key, value) {
        userNames.add(value.name);
      });

      return userNames;
    }
  }

  void getInfo() async {
    // await DBProvider.db.deleteUser(1);
    // debugger();
    User user = await DBProvider.db.getSelfUser();
    print("GET UNFO $user");
    if (user == null) {
      // print("USER -----------> $user");
      addMemberDialog(0, true, user: User(), exists: false);
    } else {
      setState(() {
        first = false;
      });
      saveSelfPlayer(user);
    }
    setState(() {
      infoRecvd = true;
    });
    setSplash();
  }

  void setOffsets() {
    setState(() {
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
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
          "onMultiple": false,
          "kills": 0
        },
      };
      offsetsSet = true;
    });
  }

  void setSplash() {
    Completer<Size> completer = Completer();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );

    completer.future.then((value) => setState(() {
          showSplash = false;
        }));
  }

  void setPrevOffset(Map<int, dynamic> offsetRecvd) {
    Map<int, dynamic> tempofsetmap = {
      00: {
        "initBottom": offsetRecvd[00]["initBottom"],
        "initLeft": offsetRecvd[00]["initLeft"],
        "bottom": offsetRecvd[00]["bottom"],
        "left": offsetRecvd[00]["left"],
        "sameBottom": offsetRecvd[00]["sameBottom"],
        "sameLeft": offsetRecvd[00]["sameLeft"],
        "moved": offsetRecvd[00]["moved"],
        "position": offsetRecvd[00]["position"],
        "highlighted": offsetRecvd[00]["highlighted"],
        "predicted": offsetRecvd[00]["predicted"],
        "xPosition": offsetRecvd[00]["xPosition"],
        "sizeMultiplier": offsetRecvd[00]["sizeMultiplier"],
        "playerIndex": offsetRecvd[00]["playerIndex"],
        "onMultiple": offsetRecvd[00]["onMultiple"],
        "kills": offsetRecvd[00]["kills"],
      },
      10: {
        "initBottom": offsetRecvd[10]["initBottom"],
        "initLeft": offsetRecvd[10]["initLeft"],
        "bottom": offsetRecvd[10]["bottom"],
        "left": offsetRecvd[10]["left"],
        "sameBottom": offsetRecvd[10]["sameBottom"],
        "sameLeft": offsetRecvd[10]["sameLeft"],
        "moved": offsetRecvd[10]["moved"],
        "position": offsetRecvd[10]["position"],
        "highlighted": offsetRecvd[10]["highlighted"],
        "predicted": offsetRecvd[10]["predicted"],
        "xPosition": offsetRecvd[10]["xPosition"],
        "sizeMultiplier": offsetRecvd[10]["sizeMultiplier"],
        "playerIndex": offsetRecvd[10]["playerIndex"],
        "onMultiple": offsetRecvd[10]["onMultiple"],
        "kills": offsetRecvd[10]["kills"],
      },
      20: {
        "initBottom": offsetRecvd[20]["initBottom"],
        "initLeft": offsetRecvd[20]["initLeft"],
        "bottom": offsetRecvd[20]["bottom"],
        "left": offsetRecvd[20]["left"],
        "sameBottom": offsetRecvd[20]["sameBottom"],
        "sameLeft": offsetRecvd[20]["sameLeft"],
        "moved": offsetRecvd[20]["moved"],
        "position": offsetRecvd[20]["position"],
        "highlighted": offsetRecvd[20]["highlighted"],
        "predicted": offsetRecvd[20]["predicted"],
        "xPosition": offsetRecvd[20]["xPosition"],
        "sizeMultiplier": offsetRecvd[20]["sizeMultiplier"],
        "playerIndex": offsetRecvd[20]["playerIndex"],
        "onMultiple": offsetRecvd[20]["onMultiple"],
        "kills": offsetRecvd[20]["kills"],
      },
      30: {
        "initBottom": offsetRecvd[30]["initBottom"],
        "initLeft": offsetRecvd[30]["initLeft"],
        "bottom": offsetRecvd[30]["bottom"],
        "left": offsetRecvd[30]["left"],
        "sameBottom": offsetRecvd[30]["sameBottom"],
        "sameLeft": offsetRecvd[30]["sameLeft"],
        "moved": offsetRecvd[30]["moved"],
        "position": offsetRecvd[30]["position"],
        "highlighted": offsetRecvd[30]["highlighted"],
        "predicted": offsetRecvd[30]["predicted"],
        "xPosition": offsetRecvd[30]["xPosition"],
        "sizeMultiplier": offsetRecvd[30]["sizeMultiplier"],
        "playerIndex": offsetRecvd[30]["playerIndex"],
        "onMultiple": offsetRecvd[30]["onMultiple"],
        "kills": offsetRecvd[30]["kills"],
      },
      01: {
        "initBottom": offsetRecvd[01]["initBottom"],
        "initLeft": offsetRecvd[01]["initLeft"],
        "bottom": offsetRecvd[01]["bottom"],
        "left": offsetRecvd[01]["left"],
        "sameBottom": offsetRecvd[01]["sameBottom"],
        "sameLeft": offsetRecvd[01]["sameLeft"],
        "moved": offsetRecvd[01]["moved"],
        "position": offsetRecvd[01]["position"],
        "highlighted": offsetRecvd[01]["highlighted"],
        "predicted": offsetRecvd[01]["predicted"],
        "xPosition": offsetRecvd[01]["xPosition"],
        "sizeMultiplier": offsetRecvd[01]["sizeMultiplier"],
        "playerIndex": offsetRecvd[01]["playerIndex"],
        "onMultiple": offsetRecvd[01]["onMultiple"],
        "kills": offsetRecvd[01]["kills"],
      },
      11: {
        "initBottom": offsetRecvd[11]["initBottom"],
        "initLeft": offsetRecvd[11]["initLeft"],
        "bottom": offsetRecvd[11]["bottom"],
        "left": offsetRecvd[11]["left"],
        "sameBottom": offsetRecvd[11]["sameBottom"],
        "sameLeft": offsetRecvd[11]["sameLeft"],
        "moved": offsetRecvd[11]["moved"],
        "position": offsetRecvd[11]["position"],
        "highlighted": offsetRecvd[11]["highlighted"],
        "predicted": offsetRecvd[11]["predicted"],
        "xPosition": offsetRecvd[11]["xPosition"],
        "sizeMultiplier": offsetRecvd[11]["sizeMultiplier"],
        "playerIndex": offsetRecvd[11]["playerIndex"],
        "onMultiple": offsetRecvd[11]["onMultiple"],
        "kills": offsetRecvd[11]["kills"],
      },
      21: {
        "initBottom": offsetRecvd[21]["initBottom"],
        "initLeft": offsetRecvd[21]["initLeft"],
        "bottom": offsetRecvd[21]["bottom"],
        "left": offsetRecvd[21]["left"],
        "sameBottom": offsetRecvd[21]["sameBottom"],
        "sameLeft": offsetRecvd[21]["sameLeft"],
        "moved": offsetRecvd[21]["moved"],
        "position": offsetRecvd[21]["position"],
        "highlighted": offsetRecvd[21]["highlighted"],
        "predicted": offsetRecvd[21]["predicted"],
        "xPosition": offsetRecvd[21]["xPosition"],
        "sizeMultiplier": offsetRecvd[21]["sizeMultiplier"],
        "playerIndex": offsetRecvd[21]["playerIndex"],
        "onMultiple": offsetRecvd[21]["onMultiple"],
        "kills": offsetRecvd[21]["kills"],
      },
      31: {
        "initBottom": offsetRecvd[31]["initBottom"],
        "initLeft": offsetRecvd[31]["initLeft"],
        "bottom": offsetRecvd[31]["bottom"],
        "left": offsetRecvd[31]["left"],
        "sameBottom": offsetRecvd[31]["sameBottom"],
        "sameLeft": offsetRecvd[31]["sameLeft"],
        "moved": offsetRecvd[31]["moved"],
        "position": offsetRecvd[31]["position"],
        "highlighted": offsetRecvd[31]["highlighted"],
        "predicted": offsetRecvd[31]["predicted"],
        "xPosition": offsetRecvd[31]["xPosition"],
        "sizeMultiplier": offsetRecvd[31]["sizeMultiplier"],
        "playerIndex": offsetRecvd[31]["playerIndex"],
        "onMultiple": offsetRecvd[31]["onMultiple"],
        "kills": offsetRecvd[31]["kills"],
      },
      02: {
        "initBottom": offsetRecvd[02]["initBottom"],
        "initLeft": offsetRecvd[02]["initLeft"],
        "bottom": offsetRecvd[02]["bottom"],
        "left": offsetRecvd[02]["left"],
        "sameBottom": offsetRecvd[02]["sameBottom"],
        "sameLeft": offsetRecvd[02]["sameLeft"],
        "moved": offsetRecvd[02]["moved"],
        "position": offsetRecvd[02]["position"],
        "highlighted": offsetRecvd[02]["highlighted"],
        "predicted": offsetRecvd[02]["predicted"],
        "xPosition": offsetRecvd[02]["xPosition"],
        "sizeMultiplier": offsetRecvd[02]["sizeMultiplier"],
        "playerIndex": offsetRecvd[02]["playerIndex"],
        "onMultiple": offsetRecvd[02]["onMultiple"],
        "kills": offsetRecvd[02]["kills"],
      },
      12: {
        "initBottom": offsetRecvd[12]["initBottom"],
        "initLeft": offsetRecvd[12]["initLeft"],
        "bottom": offsetRecvd[12]["bottom"],
        "left": offsetRecvd[12]["left"],
        "sameBottom": offsetRecvd[12]["sameBottom"],
        "sameLeft": offsetRecvd[12]["sameLeft"],
        "moved": offsetRecvd[12]["moved"],
        "position": offsetRecvd[12]["position"],
        "highlighted": offsetRecvd[12]["highlighted"],
        "predicted": offsetRecvd[12]["predicted"],
        "xPosition": offsetRecvd[12]["xPosition"],
        "sizeMultiplier": offsetRecvd[12]["sizeMultiplier"],
        "playerIndex": offsetRecvd[12]["playerIndex"],
        "onMultiple": offsetRecvd[12]["onMultiple"],
        "kills": offsetRecvd[12]["kills"],
      },
      22: {
        "initBottom": offsetRecvd[22]["initBottom"],
        "initLeft": offsetRecvd[22]["initLeft"],
        "bottom": offsetRecvd[22]["bottom"],
        "left": offsetRecvd[22]["left"],
        "sameBottom": offsetRecvd[22]["sameBottom"],
        "sameLeft": offsetRecvd[22]["sameLeft"],
        "moved": offsetRecvd[22]["moved"],
        "position": offsetRecvd[22]["position"],
        "highlighted": offsetRecvd[22]["highlighted"],
        "predicted": offsetRecvd[22]["predicted"],
        "xPosition": offsetRecvd[22]["xPosition"],
        "sizeMultiplier": offsetRecvd[22]["sizeMultiplier"],
        "playerIndex": offsetRecvd[22]["playerIndex"],
        "onMultiple": offsetRecvd[22]["onMultiple"],
        "kills": offsetRecvd[22]["kills"],
      },
      32: {
        "initBottom": offsetRecvd[32]["initBottom"],
        "initLeft": offsetRecvd[32]["initLeft"],
        "bottom": offsetRecvd[32]["bottom"],
        "left": offsetRecvd[32]["left"],
        "sameBottom": offsetRecvd[32]["sameBottom"],
        "sameLeft": offsetRecvd[32]["sameLeft"],
        "moved": offsetRecvd[32]["moved"],
        "position": offsetRecvd[32]["position"],
        "highlighted": offsetRecvd[32]["highlighted"],
        "predicted": offsetRecvd[32]["predicted"],
        "xPosition": offsetRecvd[32]["xPosition"],
        "sizeMultiplier": offsetRecvd[32]["sizeMultiplier"],
        "playerIndex": offsetRecvd[32]["playerIndex"],
        "onMultiple": offsetRecvd[32]["onMultiple"],
        "kills": offsetRecvd[32]["kills"],
      },
      03: {
        "initBottom": offsetRecvd[03]["initBottom"],
        "initLeft": offsetRecvd[03]["initLeft"],
        "bottom": offsetRecvd[03]["bottom"],
        "left": offsetRecvd[03]["left"],
        "sameBottom": offsetRecvd[03]["sameBottom"],
        "sameLeft": offsetRecvd[03]["sameLeft"],
        "moved": offsetRecvd[03]["moved"],
        "position": offsetRecvd[03]["position"],
        "highlighted": offsetRecvd[03]["highlighted"],
        "predicted": offsetRecvd[03]["predicted"],
        "xPosition": offsetRecvd[03]["xPosition"],
        "sizeMultiplier": offsetRecvd[03]["sizeMultiplier"],
        "playerIndex": offsetRecvd[03]["playerIndex"],
        "onMultiple": offsetRecvd[03]["onMultiple"],
        "kills": offsetRecvd[03]["kills"],
      },
      13: {
        "initBottom": offsetRecvd[13]["initBottom"],
        "initLeft": offsetRecvd[13]["initLeft"],
        "bottom": offsetRecvd[13]["bottom"],
        "left": offsetRecvd[13]["left"],
        "sameBottom": offsetRecvd[13]["sameBottom"],
        "sameLeft": offsetRecvd[13]["sameLeft"],
        "moved": offsetRecvd[13]["moved"],
        "position": offsetRecvd[13]["position"],
        "highlighted": offsetRecvd[13]["highlighted"],
        "predicted": offsetRecvd[13]["predicted"],
        "xPosition": offsetRecvd[13]["xPosition"],
        "sizeMultiplier": offsetRecvd[13]["sizeMultiplier"],
        "playerIndex": offsetRecvd[13]["playerIndex"],
        "onMultiple": offsetRecvd[13]["onMultiple"],
        "kills": offsetRecvd[13]["kills"],
      },
      23: {
        "initBottom": offsetRecvd[23]["initBottom"],
        "initLeft": offsetRecvd[23]["initLeft"],
        "bottom": offsetRecvd[23]["bottom"],
        "left": offsetRecvd[23]["left"],
        "sameBottom": offsetRecvd[23]["sameBottom"],
        "sameLeft": offsetRecvd[23]["sameLeft"],
        "moved": offsetRecvd[23]["moved"],
        "position": offsetRecvd[23]["position"],
        "highlighted": offsetRecvd[23]["highlighted"],
        "predicted": offsetRecvd[23]["predicted"],
        "xPosition": offsetRecvd[23]["xPosition"],
        "sizeMultiplier": offsetRecvd[23]["sizeMultiplier"],
        "playerIndex": offsetRecvd[23]["playerIndex"],
        "onMultiple": offsetRecvd[23]["onMultiple"],
        "kills": offsetRecvd[23]["kills"],
      },
      33: {
        "initBottom": offsetRecvd[33]["initBottom"],
        "initLeft": offsetRecvd[33]["initLeft"],
        "bottom": offsetRecvd[33]["bottom"],
        "left": offsetRecvd[33]["left"],
        "sameBottom": offsetRecvd[33]["sameBottom"],
        "sameLeft": offsetRecvd[33]["sameLeft"],
        "moved": offsetRecvd[33]["moved"],
        "position": offsetRecvd[33]["position"],
        "highlighted": offsetRecvd[33]["highlighted"],
        "predicted": offsetRecvd[33]["predicted"],
        "xPosition": offsetRecvd[33]["xPosition"],
        "sizeMultiplier": offsetRecvd[33]["sizeMultiplier"],
        "playerIndex": offsetRecvd[33]["playerIndex"],
        "onMultiple": offsetRecvd[33]["onMultiple"],
        "kills": offsetRecvd[33]["kills"],
      },
    };

    List<Map<int, dynamic>> tempPrevOffsets = prevOffsets;

    List<int> tempPrevTurns = playerTurns;

    tempPrevTurns.add(tappedPlayer);

    tempPrevOffsets.add(new Map.fromEntries(tempofsetmap.entries));

    setState(() {
      playerTurns = tempPrevTurns;
    });
  }

  Widget renderGoti(int count, int position) {
    // print('------------->in renderGoti()');
    if (selectedColorList[position] != null) {
      if (selectedColorList[position]["playerName"] != null &&
          selectedColorList[position]["playerName"] != "") {
        double init = MediaQuery.of(context).size.width * 0.054;
        double size = MediaQuery.of(context).size.width * 0.064 * 1;
        // offsets[int.parse("$count$position")]["sizeMultiplier"];
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
                    // print('onTap #1 move: ' + move.toString());
                    if (move) {
                      Map<int, dynamic> currentOffsets = offsets;
                      currentOffsets[moveItem]["moved"] = false;
                      currentOffsets[moveItem]["highlighted"] = false;
                      currentOffsets[moveItem]["predicted"] = false;
                      currentOffsets[moveItem]["position"] = -1;
                      currentOffsets[moveItem]["xPosition"] = -1;

                      currentOffsets = unhighlightAll(currentOffsets);

                      setState(() {
                        move = false;
                        offsets = currentOffsets;
                        diceNo = null;
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
                  onTap: () async {
                    Map<int, dynamic> currentOffsets = offsets;
                    Map<int, dynamic> newOffsets =
                        new Map.fromEntries(offsets.entries);
                    setPrevOffset(new Map.fromEntries(newOffsets.entries));

                    // await new Future.delayed(const Duration(seconds : 5));
                    if (playerAutoMove && position == tappedPlayer) {
                      // print("AUTOMOVE TRUE");
                      Map<int, dynamic> newOffsets =
                          new Map.fromEntries(offsets.entries);
                      setPrevOffset(new Map.fromEntries(newOffsets.entries));
                      moveGotiToV2(
                          currentOffsets, int.parse("$count$position"), diceNo);
                    } else {
                      // if (move) {
                      //   int row = get2Dfrom1D(
                      // offsets[int.parse("$count$position")]
                      //     ['xPosition'])[0];
                      //   int clm = get2Dfrom1D(
                      //       offsets[int.parse("$count$position")]
                      //           ['xPosition'])[1];
                      // // print('onTap #2 move: ' +
                      //       move.toString() +
                      //       " : " +
                      //       get2Dfrom1D(offsets[int.parse("$count$position")]
                      //               ['xPosition'])
                      //           .toString());
                      //   if (!isLegal(row, clm, moveItem)) {
                      //     return;
                      //   }

                      //   print("SET MOVE FALSE");

                      //   if (moveItem == int.parse("$count$position") &&
                      //       currentOffsets[moveItem]["moved"] == false) {
                      //     print("UNMARKING THE POSITION TO MOVE");
                      //     currentOffsets[moveItem]["xPosition"] = -1;
                      //     currentOffsets[moveItem]["bottom"] =
                      //         offsets[int.parse("$count$position")]
                      //             ["initBottom"];
                      //     currentOffsets[moveItem]["left"] =
                      //         offsets[int.parse("$count$position")]["initLeft"];
                      //     currentOffsets[moveItem]["moved"] = false;
                      //     currentOffsets[moveItem]["highlighted"] = false;
                      //     currentOffsets[moveItem]["predicted"] = false;
                      //     currentOffsets = unhighlightAll(currentOffsets);
                      //     setState(() {
                      //       move = false;
                      //       offsets = currentOffsets;
                      //       diceNo = null;
                      //     });
                      //   } else if (moveItem == int.parse("$count$position") &&
                      //       currentOffsets[moveItem]["moved"]) {
                      //     currentOffsets[moveItem]["highlighted"] = false;
                      //     setState(() {
                      //       move = false;
                      //       offsets = currentOffsets;
                      //       diceNo = null;
                      //     });
                      //   } else {
                      //     print("OUGHT TO MOVE");
                      //     // first check if the goti that was clicked is it in home.
                      //     // if it is home then change the selection without moving
                      //     if (offsets[int.parse("$count$position")]
                      //             ["xPosition"] ==
                      //         -1) {
                      //       unhighlightAll(currentOffsets);
                      //       print("EXCHANGING SELECTION");
                      //       // TODO: do the exchange here
                      //       moveItem = int.parse("$count$position");
                      //       currentOffsets[moveItem]["highlighted"] = true;
                      //       setState(() {
                      //         move = true;
                      //         offsets = currentOffsets;
                      //       });
                      //     } else {
                      //       print("MOVING SELECTION");
                      //       // this will set xPosition
                      //       currentOffsets[moveItem]["xPosition"] =
                      //           offsets[int.parse("$count$position")]
                      //               ["xPosition"];
                      //       currentOffsets[moveItem]["bottom"] =
                      //           offsets[int.parse("$count$position")]["bottom"];
                      //       currentOffsets[moveItem]["left"] =
                      //           offsets[int.parse("$count$position")]["left"];
                      //       currentOffsets[moveItem]["moved"] = true;
                      //       currentOffsets[moveItem]["highlighted"] = false;
                      //       currentOffsets[moveItem]["predicted"] = false;
                      //       currentOffsets = unhighlightAll(currentOffsets);
                      //       // check if it is a non safe position so kill
                      //       if (currentOffsets[moveItem]["playerIndex"] !=
                      //               currentOffsets[int.parse("$count$position")]
                      //                   ["playerIndex"] &&
                      //           isSafePosition(currentOffsets[
                      //                       int.parse("$count$position")]
                      //                   ["xPosition"]) ==
                      //               false) {
                      //         currentOffsets[moveItem]["playerIndex"] += 1;
                      //         print("KILLING!!!!!!!!!!!!!!!!!!!!!!!!!!");
                      //         currentOffsets[moveItem]["kills"] += 1;
                      //         // currentOffsets[int.parse("$count$position")] =
                      //         //     defaultOffsets[int.parse("$count$position")];
                      //         currentOffsets[int.parse("$count$position")]
                      //             ["xPosition"] = -1;
                      //         currentOffsets[int.parse("$count$position")]
                      //             ["onMultiple"] = false;
                      //         currentOffsets[int.parse("$count$position")]
                      //             ["sizeMultiplier"] = 1;
                      //         print(currentOffsets[int.parse("$count$position")]
                      //             ["xPosition"]);
                      //         currentOffsets[int.parse("$count$position")]
                      //             ["moved"] = false;
                      //       }

                      //       // Check multiple on one walla case
                      //       currentOffsets =
                      //           adjustForMultipleOnOne(currentOffsets);
                      //       print("SETSTATE----------------");

                      //       setState(() {
                      //         move = false;
                      //         offsets = currentOffsets;
                      //         diceNo = null;
                      //       });
                      //     }
                      //   }
                      //   // itterate over the offsets to check ki kis kis ka
                      // } else {
                      // print("SET MOVE TRUE");
                      // print(int.parse("$count$position"));
                      // print(offsets[01]);
                      // Map<int, dynamic> currentOffsets = offsets;

                      // // Check if multiple Gotis are in the same box

                      // if (currentOffsets[int.parse("$count$position")]
                      //     ["onMultiple"]) {
                      //   List<int> keys = [];
                      //   List<int> countpos = [];

                      //   int x = currentOffsets[int.parse("$count$position")]
                      //       ["xPosition"];
                      //   // for(int i; i < currentOffsets.length; i++) {
                      //   //   currentOffsets[i]
                      //   // }
                      //   currentOffsets.forEach((index, value) {
                      //     print(index);
                      //     if (value["xPosition"] == x) {
                      //       keys.add(index);
                      //     }
                      //   });
                      //   List<int> currentOffsetkeys =
                      //       currentOffsets.keys.toList();
                      //   for (int i = 0; i < keys.length; i++) {
                      //     countpos.add(currentOffsetkeys[i]);
                      //   }
                      //   moveGotiDialog(keys);
                      // }

                      if (currentOffsets[int.parse("$count$position")]
                          ["predicted"]) {
                        print("---------------------> PREDICTED");
                        moveGotiToV2(currentOffsets,
                            int.parse("$count$position"), diceNo);
                      } else {
                        // currentOffsets = unhighlightAll(currentOffsets);
                        // currentOffsets[int.parse("$count$position")]
                        //     ["highlighted"] = true;
                        // setState(() {
                        //   move = true;
                        //   moveItem = int.parse("$count$position");
                        //   offsets = currentOffsets;
                        // });
                      }
                    }
                    // }
                  },
                  child: Container(
                      child: offsets[int.parse("$count$position")]["predicted"]
                          ? BlinkingWidget(Image.asset(
                              offsets[int.parse("$count$position")]
                                      ["highlighted"]
                                  ? "assets/_goti_${selectedColorList[position]["name"]}_${count + 1}.png"
                                  : "assets/goti_${selectedColorList[position]["name"]}_${count + 1}.png",
                              width: size,
                              height: size,
                              fit: BoxFit.fitHeight,
                            ))
                          : Image.asset(
                              offsets[int.parse("$count$position")]
                                      ["highlighted"]
                                  ? "assets/_goti_${selectedColorList[position]["name"]}_${count + 1}.png"
                                  : "assets/goti_${selectedColorList[position]["name"]}_${count + 1}.png",
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
    } else {
      return Container();
    }
  }

  Map<int, dynamic> adjustForMultipleOnOne(Map<int, dynamic> currentOffsets) {
    for (int xPosition = 0; xPosition < 75; xPosition++) {
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

      if (overlapingKeys.length == 4 && (xPosition == 69 || xPosition == 57)) {
        endGame();
      }

      if (overlapingKeys.length > 1 && xPosition != -1) {
        // print(">>>>>>>>>>>>>>>>>>>>>>GREATER THAN 0 ${overlapingKeys.length}");
        double gap = ((getLeft(context, 1) - getLeft(context, 0)) /
                overlapingKeys.length) *
            0.6;

        for (int i = 0; i < overlapingKeys.length; i++) {
          // print("KEYYSSS >>>>>>>>>>> ${overlapingKeys[i]}");
          int center = (overlapingKeys.length / 2).floor();
          if ((overlapingKeys.length % 2) == 0) {
            //print("even");
            if (i < center) {
              // print(i.toString() +
              //       ' : ' +
              //       getLeft(context, clm).toString() +
              //       " : " +
              //       (getLeft(context, clm) + gap * (i - center)).toString());
              currentOffsets[overlapingKeys[i]]['left'] =
                  getLeft(context, clm) + gap * (i - center);
            } else {
              // print(i.toString() +
              //     ' : ' +
              //     getLeft(context, clm).toString() +
              //     " : " +
              //     (getLeft(context, clm) + gap * (i - center + 1)).toString());
              currentOffsets[overlapingKeys[i]]['left'] =
                  getLeft(context, clm) + gap * (i - center + 1);
            }
          } else {
            // print("odd");
            // print(i.toString() +
            //     ' : ' +
            //     getLeft(context, clm).toString() +
            //     " : " +
            //     (getLeft(context, clm) + gap * (i - center)).toString());
            currentOffsets[overlapingKeys[i]]['left'] =
                getLeft(context, clm) + gap * (i - center);
          }
          currentOffsets[overlapingKeys[i]]['sizeMultiplier'] =
              1.5 / overlapingKeys.length;
          currentOffsets[overlapingKeys[i]]['onMultiple'] = true;
        }

        // print("adjustForMultipleOnOne gap: " +
        //     gap.toString() +
        //     " : " +
        //     overlapingKeys.toString());
      } else if (overlapingKeys.length == 1) {
        // print("ONLY ONE KEY IN BOX");
        currentOffsets[overlapingKeys[0]]['onMultiple'] = false;
        currentOffsets[overlapingKeys[0]]['sizeMultiplier'] = 1;
        currentOffsets[overlapingKeys[0]]['left'] = getLeft(context, clm);
      } else if (xPosition == -1 && overlapingKeys.length > 0) {
        // print("MULTIPLE -1 _____________________--");

        for (int i = 0; i < overlapingKeys.length; i++) {
          currentOffsets[overlapingKeys[i]]['sizeMultiplier'] = 1;
          currentOffsets[overlapingKeys[i]]['onMultiple'] = false;
          currentOffsets[overlapingKeys[0]]['left'] = getLeft(context, clm);
        }
      }
    }
    // print(currentOffsets.toString());
    // print("------------------------DOONNEEE WITH CALCULATION");
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

    // print("SETSTATE----------------");

    return currentOffsets;
  }

  void moveGotiToV2(currentOffsets, moveItem, diceCount) {
    print('in moveGotiToV2');
    List<int> rowClm;
    if (currentOffsets[moveItem]["xPosition"] == -1) {
      if (currentOffsets[moveItem]["playerIndex"] == 0) {
        rowClm = get2Dfrom1D(0);
      }
      if (currentOffsets[moveItem]["playerIndex"] == 1) {
        rowClm = get2Dfrom1D(13);
      }
      if (currentOffsets[moveItem]["playerIndex"] == 2) {
        rowClm = get2Dfrom1D(26);
      }
      if (currentOffsets[moveItem]["playerIndex"] == 3) {
        rowClm = get2Dfrom1D(39);
      }
    } else {
      int newXPos = currentOffsets[moveItem]["xPosition"] + diceNo;
      // print("newXPos: " + newXPos.toString());
      if (newXPos == 52 && diceNo == 1) {
        newXPos = 0;
      } else if (currentOffsets[moveItem]["playerIndex"] == 0) {
        if (newXPos == 51) {
          newXPos = newXPos + 1;
        }
        rowClm = get2Dfrom1D(newXPos);
      } else {
        if (currentOffsets[moveItem]["playerIndex"] == 1) {
          // print('player 1');
          if (newXPos >= 51 && newXPos <= 56) {
            // if x >= 53 so x-53
            if (newXPos == 52) {
              newXPos = 0;
            } else if (newXPos >= 53) {
              newXPos = newXPos - 52;
            }
          } else if (newXPos == 12) {
            newXPos = 58;
          } else if (newXPos >= 13 &&
              currentOffsets[moveItem]["xPosition"] <= 11) {
            newXPos = newXPos + 46;
          } else if (newXPos >= 63) {
            newXPos = 63;
          }
        }
        if (currentOffsets[moveItem]["playerIndex"] == 2) {
          // print('player 2');
          if (newXPos >= 51 && newXPos <= 56) {
            // if x >= 53 so x-53
            if (newXPos == 52) {
              newXPos = 0;
            } else if (newXPos >= 53) {
              newXPos = newXPos - 52;
            }
          } else if (newXPos == 25) {
            newXPos = 64;
          } else if (newXPos >= 26 &&
              currentOffsets[moveItem]["xPosition"] <= 24) {
            newXPos = newXPos + 39;
          } else if (newXPos >= 69) {
            newXPos = 69;
          }
        }
        if (currentOffsets[moveItem]["playerIndex"] == 3) {
          // print('player 3');
          if (newXPos >= 51 && newXPos <= 56) {
            // if x >= 53 so x-53
            if (newXPos == 52) {
              newXPos = 0;
            } else if (newXPos >= 53) {
              newXPos = newXPos - 52;
            }
          } else if (newXPos == 38) {
            newXPos = 70;
          } else if (newXPos >= 39 &&
              currentOffsets[moveItem]["xPosition"] <= 37) {
            newXPos = newXPos + 32;
          } else if (newXPos >= 75) {
            newXPos = 75;
          }
        }
      }
      rowClm = get2Dfrom1D(newXPos);
    }

    int row = rowClm[0];
    int clm = rowClm[1];

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
    currentOffsets[moveItem]["xPosition"] = x;

    var temp = currentOffsets[moveItem];
    bool tempKilled = false;
    // loop over all the offsets to see agar kissi ka xPossition same as this one to nahi
    currentOffsets.forEach((key, value) {
      if ((currentOffsets[moveItem]["playerIndex"] !=
              currentOffsets[key]["playerIndex"]) &&
          (key != moveItem) &&
          (currentOffsets[key]["xPosition"] == x) &&
          (isSafePosition(currentOffsets[key]["xPosition"]) == false)) {
        print("Auto Move KILLING!!!!!!!!!!!!!!!!!!!!!!!!!!");
        tempKilled = true;
        setState(() {
          killed = true;
        });
        currentOffsets[moveItem]["kills"] += 1;
        // currentOffsets[key] = defaultOffsets[key];
        currentOffsets[key]["xPosition"] = -1;
        currentOffsets[key]["onMultiple"] = false;
        currentOffsets[key]["sizeMultiplier"] = 1;
        currentOffsets[key]["moved"] = false;
      }
    });

    // Check multiple on one walla case
    currentOffsets = adjustForMultipleOnOne(currentOffsets);
    // print("SETSTATE----------------");

    currentOffsets[moveItem] = temp;

    currentOffsets = unhighlightAll(currentOffsets);

    setState(() {
      move = false;
      offsets = currentOffsets;
    });
    print("KILLED");
    print(killed);
    print("XPOSITION!!!!!!!!!!!!!!! $x");
    if (diceNo != 6 && !killed && x != 57 && x != 69) {
      // print("DICE NUMBER NOT 6 $diceNo");
      List<int> tempPrevTurns = playerTurns;

      tempPrevTurns.add(tappedPlayer);

      setState(() {
        tappedPlayer = tappedPlayer == 0 ? 2 : 0;
        predictionText = '';
        playerTurns = tempPrevTurns;
      });
    }

    setState(() {
      diceNo = null;
      killed = false;
    });
    setinvalidDiceNumbers();
  }

  void setinvalidDiceNumbers() {
    List<int> invalidNos = [];
    List player2xPositions = [
      offsets[02]['xPosition'],
      offsets[12]['xPosition'],
      offsets[22]['xPosition'],
      offsets[32]['xPosition']
    ];

    [1, 2, 3, 4, 5, 6].forEach((diceNo) {
      // print(diceNo);
      player2xPositions.forEach((xPos) {
        if (!isSafePosition(xPos + diceNo)) {
          int index = player2xPositions
              .indexWhere((xPosition) => xPosition == (xPos + diceNo));
          if (index != -1) {
            if (invalidNos.indexOf(diceNo) == -1) {
              invalidNos.add(diceNo);
              // print("INVALID $diceNo");
            }

            return;
          }
        }
      });
    });
    setState(() {
      invalidDiceNos = invalidNos;
    });
  }

  void showStats(int position) {
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
                child: topRow(context, "STATS"),
              ),
              content: new Container(
                  // height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Total Houses: ${getTotalHouses(position)}",
                          style: TextStyle(color: Color(0xff465e6e)),
                        ),
                        Text("Sixes to start: ${getSixToStart(position)}",
                            style: TextStyle(color: Color(0xff465e6e))),
                        Text("Killed: ${getKills(position)}",
                            style: TextStyle(color: Color(0xff465e6e))),
                      ],
                    ),
                  ])),
            );
          });
        });
  }

  void endGame() {
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
                child: topRow(context, "SELECT WINNER"),
              ),
              content: new Container(
                  // height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            winnerAvatar(0, setState),
                            winnerAvatar(2, setState),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          child: Container(
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
                              )),
                          onTap: () {
                            User user =
                                selectedColorList[winningPlayer]["user"];
                            List<Map<String, dynamic>> temp = selectedColorList;
                            user.wins = user.wins + 1;

                            temp[winningPlayer]['user'] = user;
                            setState(() {
                              first = false;
                              selectedColorList = temp;
                            });
                            DBProvider.db.updateUser(user);
                            Navigator.pop(context);

                            reset();
                            // Navigator.pushAndRemoveUntil(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (BuildContext context) => HomeScreen(
                            //           Image.asset(
                            //               "assets/ludo_background.png"))),
                            //   ModalRoute.withName('/'),
                            // );
                          },
                        )
                      ],
                    ),
                  ])),
            );
          });
        });
  }

  Widget winnerAvatar(int position, Function setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          winningPlayer = position;
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: selectedColorList[position] != null
                ? null
                : Border.all(color: Color(0xff465e6e))),
        width: 70,
        height: 70,
        child: selectedColorList[position]["name"] != null
            ? Center(
                child: Column(children: [
                Image.asset(
                    "assets/${position == winningPlayer ? '_' : ''}avatar_${selectedColorList[position]["name"]}.png",
                    height: 50,
                    width: 50),
                Text(selectedColorList[position] != null
                    ? selectedColorList[position]["playerName"] != null
                        ? selectedColorList[position]["playerName"]
                        : ""
                    : "")
              ]))
            : Center(
                child: Icon(Icons.add),
              ),
      ),
    );
  }

  void addMemberDialog(int position, bool self,
      {User user, bool exists = true, showColor = true}) {
    User usertobeSent = exists ? user : null;
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
                child: topRow(
                    context,
                    position == 2
                        ? "SELECT OPPONENT"
                        : !showColor ? "EDIT NAME" : "SELECT COLOR"),
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
                          child: user == null
                              ? nameTextForm()
                              : TextFormField(
                                  expands: false,
                                  initialValue: exists ? user.name : '',
                                  onChanged: (value) {
                                    // print("ONCHANGED $value");
                                    setState(() {
                                      // print(value);
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
                        SizedBox(
                          height: 20,
                        ),
                        //   ],
                        // ),
                        position == 0 && showColor
                            ? Column(children: [
                                Text(
                                  'HOUSE COLOR ',
                                  style: TextStyle(
                                      fontSize: 18, fontFamily: 'Roboto'),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    colorDropDown('Color', setState,
                                        user: usertobeSent)
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ])
                            : Container(),
                        bottomRow(position, self,
                            user: usertobeSent,
                            exists: exists,
                            showColor: showColor)
                      ],
                    ),
                  ])),
            );
          });
        });
  }

  Widget nameTextForm() {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._typeAheadController,
      ),
      suggestionsCallback: (pattern) {
        // setState(() {
        //   currentPlayerName = pattern;
        // });
        return getSuggestions(pattern);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (suggestion) {
        setState(() {
          currentPlayerName = suggestion;
        });
        this._typeAheadController.text = suggestion;
      },
      validator: (String value) {
        // setState(() {
        //   currentPlayerName = value;
        // });
        if (value.isEmpty) {
          return 'Enter a name!';
        } else {
          return '';
        }
      },
      autovalidate: true,
      onSaved: (value) {
        // print(value);
        setState(() {
          currentPlayerName = value;
        });
      },
    );
  }

  void resetDialog() {
    // print('------------->in resetDialog()');
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
                      // print('onTap #4');
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
                  width: MediaQuery.of(context).size.width,
                  child: Stack(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                            // print('onTap #5');
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
    // print('------------->in layout()');
    List<Widget> layoutItems = [];
    layoutItems.addAll([colorBox(0), colorBox(1), colorBox(3), centerSquare()]);
    if (selectedColorList[2] != null) {
      layoutItems.add(colorBox(2));
    }
    layoutItems.add(image);
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
                      // print("================LAYOUT============");

                      // print('onTap #6 move: ' +
                      //     move.toString() +
                      //     ' moveItem: ' +
                      //     moveItem.toString());
                      // if (move && isLegal(row, col, moveItem)) {
                      //   currentOffsets = unhighlightAll(currentOffsets);
                      //   currentOffsets[moveItem]["bottom"] = bottom * 1.05;
                      //   currentOffsets[moveItem]["left"] = left;
                      //   currentOffsets[moveItem]["moved"] = true;
                      //   currentOffsets[moveItem]["highlighted"] = false;
                      //   currentOffsets[moveItem]["predicted"] = false;
                      //   currentOffsets[moveItem]["position"] =
                      //       getActualposition(x,
                      //           int.parse(moveItem.toString().split("").last));
                      //   print('############ 2 SETTING xPosition OF $moveItem' +
                      //       x.toString());
                      //   currentOffsets[moveItem]["xPosition"] = x;
                      //   currentOffsets = unhighlightAll(currentOffsets);

                      //   setState(() {
                      //     move = false;
                      //     offsets = currentOffsets;
                      //     diceNo = null;
                      //   });
                      // }
                    },
                    child: Container(
                        alignment: Alignment.center,
//                        margin: EdgeInsets.only(
//                          bottom: 5,
//                        ),
                        child: Text(
                          // $row,$col\n
                          "$x",
                          style: TextStyle(color: Colors.black, fontSize: 10),
                        ),
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
    if (selectedColorList[2] == null) {
      layoutItems.add(colorBox(2));
    }
    if (selectedColorList[0] == null) {
      // print("NULL");
      layoutItems.add(colorBox(0));
    }
    return layoutItems;
  }

  void changeSize(x, moveItem) {
    // print('------------->in changeSize()');
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

  Widget colorDropDown(String label, Function setStateFunc, {User user}) {
    List<Map<String, dynamic>> temp =
        user == null ? availableColors : allColors;
    // print(temp);
    // print('------------->in colorDropDown()');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.green.shade400, width: 2),
          borderRadius: BorderRadius.circular(25)),
      width: MediaQuery.of(context).size.width * 0.64,
      child: Platform.isIOS
          ? iOSDropDown(label, setStateFunc, temp, user: user)
          : androidDropdown(label, setStateFunc, temp, user: user),
    );
  }

  Widget iOSDropDown(
      String label, Function setStateFunc, List<Map<String, dynamic>> colorlist,
      {User user}) {
    return CupertinoPicker(
        itemExtent: 40,
        onSelectedItemChanged: (item) {
          setStateFunc(() {
            // print("CHANGING SELECTED COLOR");
            selectedColor = user == null
                ? availableColors[item]["name"]
                : allColors[item]["name"];
          });
        },
        children: colorlist
            .map((e) => new DropdownMenuItem(
                value: e["name"],
                child: Text(
                  e["name"].toString().toUpperCase(),
                  style: TextStyle(
                      fontSize: 18, fontFamily: 'Roboto', color: Colors.black),
                )))
            .toList());
  }

  Widget androidDropdown(
      String label, Function setStateFunc, List<Map<String, dynamic>> colorlist,
      {User user}) {
    // print("SELECTED COLOR $selectedColor");
    return DropdownButton(
      underline: Container(),
      style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
      elevation: 0,
      isExpanded: true,
      items: colorlist
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
    );
  }

  Widget centerSquare() {
    List<Widget> centerTriangles = [];
    selectedColorList.asMap().forEach((index, value) {
      centerTriangles.add(Align(
        alignment: alignments[index],
        child: value == null
            ? Container()
            : value["name"] == null
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

  Widget endGameButton() {
    return Visibility(
        visible: selectedColorList[2] != null &&
            selectedColorList[1] != null &&
            selectedColorList[0] != null &&
            selectedColorList[3] != null,
        child: Positioned(
          bottom: 5,
          right: 10,
          child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerRight,
              child: FlatButton(
                child: Text(
                  'END GAME',
                ),
                color: Colors.green,
                onPressed: () {
                  endGame();
                },
              )),
        ));
  }

  List<Widget> getEachGoti(int position) {
    List<Widget> columns = [];
    if (selectedColorList[position] != null) {
      for (int i = 0; i < 4; i++) {
        int positionsLeft = offsets[int.parse("$i$position")]['xPosition'] == -1
            ? 56
            : gethouses(int.parse("$i$position"), position);

        columns.add(Container(
            decoration: BoxDecoration(
                border: Border(
              left: BorderSide(color: Colors.black),
              top: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
            )),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(color: Colors.black),
                  )),
                  child: Text(
                      '  ${selectedColorList[position]['name'].toString().substring(0, 1).toUpperCase()}${i + 1} '),
                ),
                Text('  $positionsLeft ')
              ],
            )));
      }

      columns.add(Container(
        // margin: EdgeInsets.only(right: 5, left: 5),
        decoration: BoxDecoration(
            border: Border(
          left: BorderSide(color: Colors.black),
          top: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        )),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(color: Colors.black),
              )),
              child: Text('  M6  '),
            ),
            Text('  ${getSixToStart(position)}  ')
          ],
        ),
      ));
      columns.add(Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(color: Colors.black),
              )),
              child: Text('  TOTAL '),
            ),
            Text('  ${getTotalHouses(position)} ')
          ],
        ),
      ));
    }

    return columns;
  }

  String getWinningStats(int pos) {
    int wins = selectedColorList[pos]['user'].wins;
    int games = selectedColorList[pos]['user'].games;
    double percent = games == 0 ? 0 : (wins / games) * 100;
    return "Winning Stats: $wins/$games (${((percent).round())} %)";
  }

  Widget selfStats() {
    return Positioned(
        bottom: MediaQuery.of(context).size.height * 0.06,
        right: 10,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: getEachGoti(0)),
          SizedBox(
            height: 5,
          ),
          Text(selectedColorList[0] == null
              ? ''
              : selectedColorList[0]['user'] == null ? '' : getWinningStats(0)),
          Text("Total killed: ${getKills(0)}",
              style: TextStyle(color: Color(0xff465e6e))),
          Text("No sixes: ${getNoSixCount(0)}",
              style: TextStyle(color: Color(0xff465e6e))),
          SizedBox(
            height: 10,
          )
        ]));
  }

  Widget oppDiceRow() {
    // selectedColorList[2]['user'] != null
    return Visibility(
        visible: selectedColorList[2]['playerName'] != null ? true : false,
        child: Positioned(
            left: 2,
            child: Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                      children: [1, 2, 3, 4, 5, 6]
                          .map((e) => GestureDetector(
                              onTap: () {
                                // print('onTap #10');
                                if (tappedPlayer == 2 || init) {
                                  setState(() {
                                    playerAutoMove = true;
                                    // tappedPlayer = 2;
                                  });
                                }

                                onDiceTap(e, 2);
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: tappedPlayer != 2 ? 10 : 5,
                                    bottom: tappedPlayer != 2 ? 5 : 0),
                                child: Image.asset(
                                  tappedPlayer == 2 || init
                                      ? "assets/dice-$e.png"
                                      : "assets/dice_disable.png",
                                  fit: BoxFit.fill,
                                  width: diceNo == e && tappedPlayer == 2 ||
                                          init
                                      ? MediaQuery.of(context).size.width * 0.12
                                      : MediaQuery.of(context).size.width *
                                          0.10,
                                  height: diceNo == e && tappedPlayer == 2 ||
                                          init
                                      ? MediaQuery.of(context).size.width * 0.12
                                      : MediaQuery.of(context).size.width *
                                          0.10,
                                ),
                              )))
                          .toList()),
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: getEachGoti(2)),
                            SizedBox(
                              height: 5,
                            ),
                            Row(children: [
                              Text(selectedColorList[2] == null
                                  ? ''
                                  : selectedColorList[2]['user'] == null
                                      ? ''
                                      : " ${getWinningStats(2)}; "),
                              Text("Total killed: ${getKills(2)}; ",
                                  style: TextStyle(color: Color(0xff465e6e))),
                              Text("No sixes: ${getNoSixCount(2)}; ",
                                  style: TextStyle(color: Color(0xff465e6e)))
                            ]),
                          ]))
                ],
              ),
            )));
  }

  int getNoSixCount(int pos) {
    if (selectedColorList[pos] == null) {
      return 0;
    } else {
      return selectedColorList[pos]['nosix'];
    }
  }

  Widget selfDiceRow() {
    return Visibility(
      visible: true,
      child: Positioned(
          bottom: MediaQuery.of(context).size.height * 0.18,
          right: 10,
          child: Row(
              children: [1, 2, 3, 4, 5, 6]
                  .map((e) => GestureDetector(
                      onTap: () {
                        onDiceTap(e, 0);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Image.asset(
                          tappedPlayer == 0 || init
                              ? "assets/dice-$e.png"
                              : "assets/dice_disable.png",
                          fit: BoxFit.fill,
                          width: diceNo == e && tappedPlayer == 0 || init
                              ? MediaQuery.of(context).size.width * 0.12
                              : MediaQuery.of(context).size.width * 0.10,
                          height: diceNo == e && tappedPlayer == 0 || init
                              ? MediaQuery.of(context).size.width * 0.12
                              : MediaQuery.of(context).size.width * 0.10,
                        ),
                      )))
                  .toList())),
    );
  }

  Widget bottomRow(int position, bool self,
      {User user, bool exists, bool showColor = true}) {
    // print('------------->in bottomRow()');
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Stack(children: [
        GestureDetector(
          child: Container(
              width: 140,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: (position == 0 &&
                          (currentPlayerName == null ||
                              currentPlayerName == ''))
                      // )
                      ? Colors.grey
                      : Colors.green.shade400,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: (position == 0 &&
                              (currentPlayerName == null ||
                                  currentPlayerName == ''))
                          // )
                          ? Colors.grey
                          : Colors.green.shade400,
                      width: 6)),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              )),
          onTap: () {
            if (!((_typeAheadController.text == '' ||
                        _typeAheadController.text == null) &&
                    position == 2 ||
                (position == 0 &&
                    (currentPlayerName == null || currentPlayerName == '')))) {
              if (user == null && !self) {
                setState(() {
                  currentPlayerName = _typeAheadController.text;
                });
              }

              savePlayer(position, self,
                  user: user, exists: exists, showColor: showColor);
              Navigator.pop(context);
            }
          },
        ),
      ])
    ]);
  }

  Widget playerAddButton(int position) {
    return GestureDetector(
      onTap: () {
        // print('onTap #8');
        Map<int, dynamic> currentOffsets = offsets;

        // addMemberDialog(position, false);

        // else {
        //   if (position != 0) {
        //     if (playerAutoMove) {
        //       for (int i = 0; i < 4; i++) {
        //         currentOffsets[int.parse("$i$tappedPlayer")]["highlighted"] =
        //             false;
        //       // print("AUTOMOVE TRUE");
        //       }
        //       setState(() {
        //         offsets = currentOffsets;
        //       });
        //       if (position == tappedPlayer) {
        //         setState(() {
        //           playerAutoMove = false;
        //           tappedPlayer = null;
        //         });
        //       } else {
        //         setState(() {
        //           playerAutoMove = true;
        //           tappedPlayer = position;
        //         });
        //       }
        //     } else {
        //       setState(() {
        //         playerAutoMove = true;
        //         tappedPlayer = position;
        //       });
        //     }
        //   } else {
        //     if (playerAutoMove) {
        //       for (int i = 0; i < 4; i++) {
        //         currentOffsets[int.parse("$i$tappedPlayer")]["highlighted"] =
        //             false;
        //       // print("AUTOMOVE TRUE");
        //       }
        //       setState(() {
        //         offsets = currentOffsets;
        //       });
        //       setState(() {
        //         playerAutoMove = false;
        //         tappedPlayer = null;
        //       });
        //     } else {
        //       setState(() {
        //         playerAutoMove = true;
        //         tappedPlayer = position;
        //       });
        //     }
        // }
        // }
      },
      child: Row(
        children: <Widget>[
          (position == 0 || position == 1) ? avatar(position) : name(position),
          (position == 0 || position == 1) ? name(position) : avatar(position)
        ],
      ),
    );
  }

  int getTotalHouses(player) {
    int totalHouses = 0;
    // player 0
    if (player == 0) {
      for (int i in [00, 10, 20, 30]) {
        if (offsets[i]['xPosition'] == -1) {
          totalHouses += 62;
        }
        if (offsets[i]['xPosition'] >= 0 && offsets[i]['xPosition'] <= 50) {
          totalHouses += (56 - (offsets[i]['xPosition']));
        }
        if (offsets[i]['xPosition'] >= 52 && offsets[i]['xPosition'] <= 57) {
          totalHouses += (57 - offsets[i]['xPosition']);
        }
      }
    }

    // player 1
    if (player == 1) {
      for (int i in [01, 11, 21, 31]) {
        if (offsets[i]['xPosition'] == -1) {
          totalHouses += 6 + 56;
        }
        if (offsets[i]['xPosition'] >= 13 && offsets[i]['xPosition'] <= 51) {
          totalHouses += (56 - (offsets[i]['xPosition'] - 13));
        }
        if (offsets[i]['xPosition'] >= 0 && offsets[i]['xPosition'] <= 11) {
          totalHouses += (17 - offsets[i]['xPosition']);
        }
        if (offsets[i]['xPosition'] >= 58 && offsets[i]['xPosition'] <= 63) {
          totalHouses += (63 - offsets[i]['xPosition']);
        }
      }
    }

    // player 2
    if (player == 2) {
      for (int i in [02, 12, 22, 32]) {
        if (offsets[i]['xPosition'] == -1) {
          totalHouses += 6 + 56;
        }
        if (offsets[i]['xPosition'] >= 26 && offsets[i]['xPosition'] <= 51) {
          totalHouses += (56 - (offsets[i]['xPosition'] - 26));
        }
        if (offsets[i]['xPosition'] >= 0 && offsets[i]['xPosition'] <= 24) {
          totalHouses += (30 - offsets[i]['xPosition']);
        }
        if (offsets[i]['xPosition'] >= 64 && offsets[i]['xPosition'] <= 69) {
          totalHouses += (69 - offsets[i]['xPosition']);
        }
      }
    }

    // player 3
    if (player == 3) {
      for (int i in [03, 13, 23, 33]) {
        if (offsets[i]['xPosition'] == -1) {
          totalHouses += 6 + 56;
        }
        if (offsets[i]['xPosition'] >= 13 && offsets[i]['xPosition'] <= 51) {
          totalHouses += (56 - (offsets[i]['xPosition'] - 13));
        }
        if (offsets[i]['xPosition'] >= 0 && offsets[i]['xPosition'] <= 11) {
          totalHouses += (17 - offsets[i]['xPosition']);
        }
        if (offsets[i]['xPosition'] >= 58 && offsets[i]['xPosition'] <= 63) {
          totalHouses += (63 - offsets[i]['xPosition']);
        }
      }
    }

    return totalHouses;
  }

  int gethouses(int key, int player) {
    // print("____________________$key ______________________$player");
    int house = 0;
    // player 0
    if (player == 0) {
      if (offsets[key]['xPosition'] == -1) {
        house += 62;
      }
      if (offsets[key]['xPosition'] >= 0 && offsets[key]['xPosition'] <= 50) {
        house += (56 - (offsets[key]['xPosition']));
      }
      if (offsets[key]['xPosition'] >= 52 && offsets[key]['xPosition'] <= 57) {
        house += (57 - offsets[key]['xPosition']);
      }
    }

    // player 1
    if (player == 1) {
      if (offsets[key]['xPosition'] == -1) {
        house += 6 + 56;
      }
      if (offsets[key]['xPosition'] >= 13 && offsets[key]['xPosition'] <= 51) {
        house += (56 - (offsets[key]['xPosition'] - 13));
      }
      if (offsets[key]['xPosition'] >= 0 && offsets[key]['xPosition'] <= 11) {
        house += (17 - offsets[key]['xPosition']);
      }
      if (offsets[key]['xPosition'] >= 58 && offsets[key]['xPosition'] <= 63) {
        house += (63 - offsets[key]['xPosition']);
      }
    }

    // player 2
    if (player == 2) {
      if (offsets[key]['xPosition'] >= 26 && offsets[key]['xPosition'] <= 51) {
        house += (56 - (offsets[key]['xPosition'] - 26));
      }
      if (offsets[key]['xPosition'] >= 0 && offsets[key]['xPosition'] <= 24) {
        house += (30 - offsets[key]['xPosition']);
      }
      if (offsets[key]['xPosition'] >= 64 && offsets[key]['xPosition'] <= 69) {
        house += (69 - offsets[key]['xPosition']);
      }
    }

    // player 3
    if (player == 3) {
      if (offsets[key]['xPosition'] == -1) {
        house += 6 + 56;
      }
      if (offsets[key]['xPosition'] >= 13 && offsets[key]['xPosition'] <= 51) {
        house += (56 - (offsets[key]['xPosition'] - 13));
      }
      if (offsets[key]['xPosition'] >= 0 && offsets[key]['xPosition'] <= 11) {
        house += (17 - offsets[key]['xPosition']);
      }
      if (offsets[key]['xPosition'] >= 58 && offsets[key]['xPosition'] <= 63) {
        house += (63 - offsets[key]['xPosition']);
      }
    }

    return house;
  }

  int getSixToStart(player) {
    int sixToStart = 0;
    // player 0
    if (player == 0) {
      for (int i in [00, 10, 20, 30]) {
        if (offsets[i]['xPosition'] == -1) {
          sixToStart += 1;
        }
      }
    }

    // player 1
    if (player == 1) {
      for (int i in [01, 11, 21, 31]) {
        if (offsets[i]['xPosition'] == -1) {
          sixToStart += 1;
        }
      }
    }

    // player 2
    if (player == 2) {
      for (int i in [02, 12, 22, 32]) {
        if (offsets[i]['xPosition'] == -1) {
          sixToStart += 1;
        }
      }
    }

    // player 3
    if (player == 3) {
      for (int i in [03, 13, 23, 33]) {
        if (offsets[i]['xPosition'] == -1) {
          sixToStart += 1;
        }
      }
    }

    return sixToStart;
  }

  int getKills(player) {
    int kills = 0;
    // player 0
    if (player == 0) {
      for (int i in [00, 10, 20, 30]) {
        kills += offsets[i]['kills'];
      }
    }

    // player 1
    if (player == 1) {
      for (int i in [01, 11, 21, 31]) {
        kills += offsets[i]['kills'];
      }
    }

    // player 2
    if (player == 2) {
      for (int i in [02, 12, 22, 32]) {
        kills += offsets[i]['kills'];
      }
    }

    // player 3
    if (player == 3) {
      for (int i in [03, 13, 23, 33]) {
        kills += offsets[i]['kills'];
      }
    }

    return kills;
  }

  Widget name(position) {
    return Container(
        height: 50,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () {
              if (position == 0) {
                setState(() {
                  selectedColor = selectedColorList[0]['user'].color;
                  currentPlayerName = selectedColorList[0]['user'].name;
                });
                // print(selectedColorList[0]['user'].color);
                addMemberDialog(0, true,
                    user: selectedColorList[0]['user'],
                    exists: true,
                    showColor: false);
              }
            },
            child: Text(position == 1 || position == 3
                ? ""
                : selectedColorList[position] != null
                    ? selectedColorList[position]["playerName"] != null
                        ? selectedColorList[position]["playerName"]
                        : ""
                    : ""),
          ),
          // selectedColorList[position] != null
          //     ? (selectedColorList[position]["playerName"] != null &&
          //             selectedColorList[position]["playerName"] != '')
          //         ? GestureDetector(
          //             onTap: () {
          //             // print("Get Stats for: " + position.toString());

          //               // calculate stats
          //               int totalHouses = getTotalHouses(position);
          //             // print("totalHouses :" + totalHouses.toString());

          //               // calculate stats
          //               int sixToStart = getSixToStart(position);
          //             // print("sixToStart :" + sixToStart.toString());

          //               // calculate stats
          //               int kills = getKills(position);
          //             // print("kills :" + kills.toString());

          //               showStats(position);
          //             },
          //             child: Image.asset(
          //               "assets/stats.png",
          //               height: 30,
          //               width: 30,
          //             ))
          // : Container()
          // : Container()
        ]));
  }

  Widget avatar(position) {
    if ((position == 1) && availableColors.length <= 2) {
      double width = selectedColorList[position] == null ? 35 : 50;
      return selectedColorList[position] != null
          ? Container()
          : Column(
              children: <Widget>[
                Row(
                  children: availableColors
                      .map((e) => GestureDetector(
                          onTap: () {
                            setState(() {
                              currentPlayerName = null;
                              selectedColor = e["name"];
                            });
                            savePlayer(position, false);
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: ClipOval(
                                child: Image.asset(
                                    "assets/dot_${e['name']}.png",
                                    height: 25,
                                    width: 25)),
                            width: 25,
                            height: 25,
                          )))
                      .toList(),
                )
              ],
            );
    } else if (position == 2 || position == 0) {
      return Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: selectedColorList[position] != null
                ? null
                : Border.all(color: Color(0xff465e6e))),
        width: 50,
        height: 50,
        child: selectedColorList[position]["name"] != null
            ? Center(
                child: Column(children: [
                Image.asset(
                    "assets/${(position == tappedPlayer || init) ? '_' : ''}avatar_${selectedColorList[position]["name"]}.png",
                    height: 50,
                    width: 50),
              ]))
            : Center(
                child: Icon(Icons.add),
              ),
      );
    } else {
      return Container();
    }
  }

  void saveSelfPlayer(User user) {
    // print("SELFPLAYERNAME ${user.color}");
    List<Map<String, dynamic>> currentList = selectedColorList;
    // int index = availableColors.indexOf(
    //     availableColors.firstWhere((element) => element["name"] == user.color));
    currentList[0] =
        availableColors.firstWhere((element) => element["name"] == user.color);
    currentList[0]["playerName"] = user.name;
    currentList[0]["kills"] = 0;
    currentList[0]["houses"] = 0;
    currentList[0]["sixes"] = 0;
    currentList[0]['user'] = user;
    currentList[0]['nosix'] = 0;

    List<Map<String, dynamic>> currentColors = availableColors;

    // currentColors.removeWhere((element) => element["name"] == user.color);

    // for (int i = 1; i <= 3; i++) {
    //   print(i + index);
    //   int colorIdx = (i + index) > 3 ? 3 - (((i + index) - 1)) : i + index;
    //   currentList[i] = availableColors[colorIdx.abs()];
    //   currentList[i]["playerName"] = null;
    //   currentList[i]["kills"] = null;
    //   currentList[i]["houses"] = null;
    //   currentList[i]["sixes"] = null;
    //   currentList[i]['user'] = null;
    //   currentList[i]['nosix'] = null;
    // }

    setState(() {
      selectedColorList = currentList;
      availableColors = currentColors;
      selectedColor = user.color;
      currentPlayerName = user.name;
    });
    addMemberDialog(0, true, exists: true, user: user);
  }

  void savePlayer(int position, bool self,
      {User user, bool exists = true, showColor = true}) async {
    if (position == 2) {
      setState(() {
        init = true;
      });
    }
    List<Map<String, dynamic>> currentColors = availableColors;
    List<Map<String, dynamic>> currentList = selectedColorList;

    if (position == 0 && showColor) {
      print("SELECTED COLOR!! $selectedColor");
      int index = allColors.indexOf(
          allColors.firstWhere((element) => element["name"] == selectedColor));
      _typeAheadController.text = '';
      for (int i = 1; i <= 3; i++) {
        print("NAME ${selectedColorList[i]["playerName"]}");
        int colorIdx = (i + index) > 3 ? 3 - (((i + index) - 1)) : i + index;
        currentList[i]["color"] = allColors[colorIdx.abs()];
        currentList[i] = allColors[colorIdx.abs()];
        currentList[i]["playerName"] = selectedColorList[i]["playerName"];
        currentList[i]["kills"] = selectedColorList[i]["kills"];
        currentList[i]["houses"] = selectedColorList[i]["houses"];
        currentList[i]["sixes"] = selectedColorList[i]["sixes"];
        currentList[i]['user'] = selectedColorList[i]["user"];
        currentList[i]['nosix'] = selectedColorList[i]["nosix"] == null
            ? 0
            : selectedColorList[i]["nosix"];
      }
    }

    if (position == 0 || position == 2) {
      if (position == 0) {
        currentList[0] =
            allColors.firstWhere((element) => element["name"] == selectedColor);
      }
      if (user != null) {
        print(position);
        print("COLOR uSER NULL");
        print(currentList[2]["name"]);
        await DBProvider.db.updateUser(User(
            id: user.id,
            color:
                position == 0 ? selectedColor : currentList[position]["name"],
            name: currentPlayerName,
            games: user.games,
            wins: user.wins,
            self: self));
        currentList[position]["user"] = User(
            id: user.id,
            color:
                position == 0 ? selectedColor : currentList[position]["name"],
            name: currentPlayerName,
            games: user.games,
            wins: user.wins,
            self: self);
        currentList[position]["playerName"] = currentPlayerName;
        currentList[position]["nosix"] = 0;
      } else {
        User userRcvd = await DBProvider.db.newUser(
            User(
                color: position == 0
                    ? selectedColor
                    : currentList[position]["name"],
                name: currentPlayerName,
                games: 0,
                wins: 0,
                self: self),
            selectedColorList[0]['user'],
            first);
        currentList[position]["user"] = userRcvd;
        currentList[position]["playerName"] = userRcvd.name;
        currentList[position]["nosix"] = 0;
      }
    }
    String color = currentColors[0]["name"];

    setState(() {
      selectedColorList = currentList;
      availableColors = currentColors;
      selectedColor = color;
      currentPlayerName = '';
    });
    getUsers();
    print(selectedColorList[2]);
    if (position == 0 && showColor) {
      addMemberDialog(2, false);
    }
  }

  Widget colorBox(int position) {
    // if (selectedColorList[position] != null) {
    switch (position) {
      case 0:
        return bottomLeft(selectedColorList[position], context, position,
            positions, avatar(0), addMemberDialog);

        break;
      case 1:
        return topLeft(
            selectedColorList[position], context, position, positions);

        break;
      case 2:
        return topRight(selectedColorList[position], context, position,
            positions, avatar(2), addMemberDialog);

        break;
      case 3:
        return bottomRight(
            selectedColorList[position], context, position, positions);

        break;
      default:
        return Container();
    }
  }

  Widget screenBottomRow() {
    // print('------------->in screenBottomRow()');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(children: [
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              // print('onTap #9');
              resetDialog();
            },
            child: Image.asset(
              "assets/reset_icon.png",
              width: 30,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text('RESET GAME')
        ]),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  void onDiceTap(int number, int position) {
    if (init) {
      List<int> tempPrevTurns = playerTurns;

      tempPrevTurns.add(tappedPlayer);

      setState(() {
        tappedPlayer = position;
        init = false;
        playerTurns = tempPrevTurns;
      });
    }
    unhighlightAll(offsets);
    // print('------------->in onDiceTap()');
    Map<int, dynamic> currentOffsets = offsets;
    List<Map<String, dynamic>> tempList = selectedColorList;
    if (number == 6) {
      if (tempList[position] != null) {
        tempList[position]['nosix'] = 0;
      }
    } else {
      if (tempList[position] != null) {
        tempList[position]['nosix'] = tempList[position]['nosix'] + 1;
      }
    }

    setState(() {
      diceNo = number;
    });
    int legalCount = 0;
    bool samex = true;
    List<int> movableGotis = [];
    for (int i = 0; i < 4; i++) {
      bool legal = isLegalPos(
          currentOffsets[int.parse("$i$tappedPlayer")]["xPosition"],
          number,
          position);
      if (legal) {
        legalCount = legalCount + 1;
        movableGotis.add(int.parse("$i$tappedPlayer"));
        if (i > 0) {
          if (samex) {
            bool samexPos = true;
            for (int j = 0; j < movableGotis.length; j++) {
              if (samexPos) {
                samexPos = currentOffsets[int.parse("${movableGotis[j]}")]
                        ["xPosition"] ==
                    currentOffsets[int.parse("$i$tappedPlayer")]["xPosition"];
              }
            }
            samex = samexPos;
            // samex = currentOffsets[int.parse("$i$tappedPlayer")]["xPosition"] ==
            //     currentOffsets[int.parse("${i - 1}$tappedPlayer")]["xPosition"];
          }
        }
      }
    }
    if (legalCount == 0) {
      List<int> tempPrevTurns = playerTurns;

      tempPrevTurns.add(tappedPlayer);

      setState(() {
        tappedPlayer = tappedPlayer == 0 ? 2 : 0;
        playerTurns = tempPrevTurns;
      });
    } else if (legalCount > 1) {
      print("LEGAL COUNT $legalCount SAME X $samex");
      if (samex) {
        Map<int, dynamic> newOffsets = new Map.fromEntries(offsets.entries);
        setPrevOffset(new Map.fromEntries(newOffsets.entries));
        moveGotiToV2(currentOffsets, movableGotis[0], number);
        return;
      } else if (tappedPlayer == 2) {
        for (int j = 0; j < movableGotis.length; j++) {
          currentOffsets[int.parse("${movableGotis[j]}")]["highlighted"] = true;
        }
      }
    } else if (legalCount == 1) {
      Map<int, dynamic> newOffsets = new Map.fromEntries(offsets.entries);
      setPrevOffset(new Map.fromEntries(newOffsets.entries));
      moveGotiToV2(currentOffsets, movableGotis[0], number);
      return;
    }

    if (position != 2) {
      print("===============================================");
      print(getCurrentBoardStatus(number));
      print("===============================================");
      int index = startGameSuggestion(getCurrentBoardStatus(number));
      setState(() {
        predictionText =
            "Move ${selectedColorList[0]['name'].toString().substring(0, 1).toUpperCase()}${index + 1} ahead";
      });
      if (index != -1) {
        currentOffsets = unhighlightAll(currentOffsets);
        currentOffsets[int.parse("${index}0")]["highlighted"] = true;
        currentOffsets[int.parse("${index}0")]["predicted"] = true;
        setState(() {
          diceNo = number;
          selectedColorList = tempList;
          offsets = currentOffsets;
        });
      }
    }
  }

  bool isLegalPos(int currentXPos, int diceNo, int position) {
    if (currentXPos == -1) {
      if (diceNo == 6) {
        return true;
      } else {
        return false;
      }
    }
    if (position == 2) {
      if (currentXPos == 24) {
        if (diceNo < 6) {
          return true;
        } else {
          return false;
        }
      } else if (currentXPos >= 64) {
        if ((69 - currentXPos) >= diceNo) {
          return true;
        } else
          return false;
      } else {
        return true;
      }
    } else {
      if (currentXPos == 50) {
        if (diceNo < 6) {
          return true;
        } else {
          return false;
        }
      } else if (currentXPos >= 52) {
        if (((57 - currentXPos) >= diceNo)) {
          return true;
        } else
          return false;
      } else {
        return true;
      }
    }
  }

  bool isSafePosition(int xPosition) {
    // print('isSafePosition: ' + xPosition.toString());
    List<int> safePositions = [0, 8, 13, 21, 26, 34, 39, 47];
    for (int i = 0; i < safePositions.length; i++) {
      if (safePositions[i] == xPosition) {
        return true;
      }
    }
    return false;
  }

  Map getCurrentBoardStatus(int noOnDice) {
    // print('------------->in getCurrentBoardStatus()');
    return {
      "0": {
        "0": offsets[00]["position"],
        "1": offsets[10]["position"],
        "2": offsets[20]["position"],
        "3": offsets[30]["position"]
      },
//      "1": {
//        "0": offsets[01]["position"],
//        "1": offsets[11]["position"],
//        "2": offsets[21]["position"],
//        "3": offsets[31]["position"]
//      },
      "1": {"0": -2, "1": -2, "2": -2, "3": -2},
      "2": {
        "0": offsets[02]["position"],
        "1": offsets[12]["position"],
        "2": offsets[22]["position"],
        "3": offsets[32]["position"]
      },
//      "3": {
//        "0": offsets[03]["position"],
//        "1": offsets[13]["position"],
//        "2": offsets[23]["position"],
//        "3": offsets[33]["position"]
//      },
      "3": {"0": -2, "1": -2, "2": -2, "3": -2},
      "noOnDice": noOnDice
    };
  }

  // x is xposition and pos is playerIndex
  int getActualposition(int x, int pos) {
    // print('------------->in getActualposition()');
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
    // print("MULTIPLE MOVE DIALOG $positions");
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
