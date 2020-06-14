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
    {"name": "yellow", "value": Colors.yellow},
    {"name": "blue", "value": Colors.blue},
    {"name": "green", "value": Colors.green},
  ];
  List<Map<String, dynamic>> allColors = [
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
  bool playerAutoMove = true;
  int tappedPlayer = 0;
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
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/ludo_background.png"),
                fit: BoxFit.cover)),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar(context, showSplash, undo),
            body: showSplash
                ? SplashScreen()
                : Stack(children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          availableColors.length < 2
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
                              playerAddButton(0),
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
                        child: Text("v1.1.5"),
                      )),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.15,
                      right: 10,
                      child: Center(
                          child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(0),
                        child: FlatButton(
                          child: Text('END GAME'),
                          onPressed: () {
                            endGame();
                          },
                          color: Colors.green,
                        ),
                      )),
                    ),
                    Visibility(
                        visible: tappedPlayer == 0,
                        child: Positioned(
                          bottom: MediaQuery.of(context).size.height * 0.15,
                          left: 0,
                          child: Center(
                              child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(0),
                            child: Text(predictionText),
                          )),
                        )),
                    Visibility(
                        visible: availableColors.length < 2 &&
                            ((selectedColorList.length > 2 &&
                                    selectedColorList[2] != null)
                                ? selectedColorList[2]['user'] != null
                                    ? true
                                    : false
                                : false),
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
                                                  print('onTap #10');
                                                  setState(() {
                                                    playerAutoMove = true;
                                                    tappedPlayer = 2;
                                                  });
                                                  onDiceTap(e, 2);
                                                },
                                                child: Image.asset(
                                                  "assets/dice-$e.png",
                                                  fit: BoxFit.fill,
                                                  width: diceNo == e &&
                                                          tappedPlayer == 2
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.12
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.10,
                                                  height: diceNo == e &&
                                                          tappedPlayer == 2
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.12
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.10,
                                                ),
                                              ))
                                          .toList()),
                                  Text(selectedColorList[2] == null
                                      ? ''
                                      : selectedColorList[2]['user'] == null
                                          ? ''
                                          : "Winning Stats: ${selectedColorList[2]['user'].wins}/${selectedColorList[2]['user'].games} (${((selectedColorList[2]['user'].wins / selectedColorList[2]['user'].games) * 100).round()} %)"),
                                  Text(
                                    "Total Houses: ${getTotalHouses(2)}",
                                    style: TextStyle(color: Color(0xff465e6e)),
                                  ),
                                  Text("Sixes to start: ${getSixToStart(2)}",
                                      style:
                                          TextStyle(color: Color(0xff465e6e))),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Killed: ${getKills(2)}",
                                          style: TextStyle(
                                              color: Color(0xff465e6e))),
                                    ],
                                  )
                                ],
                              ),
                            ))),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.1,
                      child: Visibility(
                          visible: availableColors.length < 2 &&
                              ((selectedColorList.length > 2 &&
                                      selectedColorList[2] != null)
                                  ? selectedColorList[2]['user'] != null
                                      ? true
                                      : false
                                  : false) &&
                              invalidDiceNos.length > 0,
                          child: Center(
                              child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                                "Cannot get ${invalidDiceNos.join(',')}",
                                style: TextStyle(color: Color(0xff465e6e))),
                          ))),
                    )
                  ])),
      ),
    ]);
  }

  void undo() {
    if ([...prevOffsets].length != 0) {
      print(prevOffsets[0][00]);
      setState(() {
        offsets = new Map.from(prevOffsets.first);
        prevOffsets = prevOffsets.sublist(1, (prevOffsets.length - 1));
      });
    }
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
      diceNo = null;
      moveItem = null;
      offsets = {
        00: offsets[00],
        10: offsets[10],
        20: offsets[20],
        30: offsets[30],

        // 00: {
        //   "initBottom":
        //       getBottom(context, 2) * 0.5 + getBottom(context, 1) * 0.5,
        //   "initLeft": getLeft(context, 2) * 0.4 + getLeft(context, 1) * 0.6,
        //   "bottom": null,
        //   "left": null,
        //   "sameBottom": null,
        //   "sameLeft": null,
        //   "moved": false,
        //   "position": -1,
        //   "highlighted": false,
        //   "predicted": false,
        //   "xPosition": -1,
        //   "sizeMultiplier": 1,
        //   "playerIndex": 0,
        //   "onMultiple": false,
        //   "kills": 0
        // },
        // 10: {
        //   "initBottom":
        //       getBottom(context, 3) * 0.5 + getBottom(context, 4) * 0.5,
        //   "initLeft": getLeft(context, 2) * 0.4 + getLeft(context, 1) * 0.6,
        //   "bottom": null,
        //   "left": null,
        //   "sameBottom": null,
        //   "sameLeft": null,
        //   "moved": false,
        //   "position": -1,
        //   "highlighted": false,
        //   "predicted": false,
        //   "xPosition": -1,
        //   "sizeMultiplier": 1,
        //   "playerIndex": 0,
        //   "onMultiple": false,
        //   "kills": 0
        // },
        // 20: {
        //   "initBottom": (getBottom(context, 3) + getBottom(context, 4)) / 2,
        //   "initLeft": getLeft(context, 3) * 0.6 + getLeft(context, 4) * 0.4,
        //   "bottom": null,
        //   "left": null,
        //   "sameBottom": null,
        //   "sameLeft": null,
        //   "moved": false,
        //   "position": -1,
        //   "highlighted": false,
        //   "predicted": false,
        //   "xPosition": -1,
        //   "sizeMultiplier": 1,
        //   "playerIndex": 0,
        //   "onMultiple": false,
        //   "kills": 0
        // },
        // 30: {
        //   "initBottom": (getBottom(context, 2) + getBottom(context, 1)) / 2,
        //   "initLeft": getLeft(context, 3) * 0.6 + getLeft(context, 4) * 0.4,
        //   "bottom": null,
        //   "left": null,
        //   "sameBottom": null,
        //   "sameLeft": null,
        //   "moved": false,
        //   "position": -1,
        //   "highlighted": false,
        //   "predicted": false,
        //   "xPosition": -1,
        //   "sizeMultiplier": 1,
        //   "playerIndex": 0,
        //   "onMultiple": false,
        //   "kills": 0
        // },
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
    });
    getInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(image.image, context);
  }

  void initState() {
    super.initState();

    postInit(() {
      getInfo();
      setOffsets();
      getUsers();
    });
  }

  void getUsers() async {
    List<User> temporaryUsers = await DBProvider.db.getUsers();
    print("TEMP USERS ==========>>>>>>>>>>>>");
    print(temporaryUsers);
    setState(() {
      users = temporaryUsers;
    });
  }

  List<String> getSuggestions(String query) {
    // setState(() {
    //   currentPlayerName = query;
    // });
    List<User> tempUsers = [...users];

    List<String> userNames = [];
    tempUsers.retainWhere((s) {
      if (s.name == null) {
        return false;
      } else {
        print(s.name.toLowerCase());
        print(query.toLowerCase());
        print(s.name.toLowerCase().contains(query.toLowerCase()));
        return s.name.toLowerCase().contains(query.toLowerCase());
      }
    });

    [...tempUsers].asMap().forEach((key, value) {
      userNames.add(value.name);
    });

    return userNames;
  }

  void getInfo() async {
    // await DBProvider.db.deleteUser(1);
    // debugger();
    User user = await DBProvider.db.getSelfUser();
    print("GET UNFO $user");
    if (user == null) {
      print("USER -----------> $user");
      addMemberDialog(0, true);
    } else {
      saveSelfPlayer(user);
    }
    setSplash();
  }

  void setOffsets() {
    offsets = {
      00: {
        "initBottom": getBottom(context, 2) * 0.5 + getBottom(context, 1) * 0.5,
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
        "initBottom": getBottom(context, 3) * 0.5 + getBottom(context, 4) * 0.5,
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
    print("OFFFFSEEETTT RECVVDDD +++++++++++++++++++++++++++++++++++++++");
    print(offsetRecvd[00]);

    offsetRecvd.forEach((key, value) {});

    List<Map<int, dynamic>> tempPrevOffsets = prevOffsets;

    tempPrevOffsets.add(new Map.fromEntries(offsetRecvd.entries));

    setState(() {
      prevOffsets = tempPrevOffsets;
    });
  }

  Widget renderGoti(int count, int position) {
    print('------------->in renderGoti()');
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
                    print('onTap #1 move: ' + move.toString());
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
                    setPrevOffset(new Map.from(currentOffsets));
                    // await new Future.delayed(const Duration(seconds : 5));
                    if (playerAutoMove && position == tappedPlayer) {
                      print("AUTOMOVE TRUE");

                      moveGotiToV2(
                          currentOffsets, int.parse("$count$position"), diceNo);
                    } else {
                      if (move) {
                        int row = get2Dfrom1D(
                            offsets[int.parse("$count$position")]
                                ['xPosition'])[0];
                        int clm = get2Dfrom1D(
                            offsets[int.parse("$count$position")]
                                ['xPosition'])[1];
                        print('onTap #2 move: ' +
                            move.toString() +
                            " : " +
                            get2Dfrom1D(offsets[int.parse("$count$position")]
                                    ['xPosition'])
                                .toString());
                        if (!isLegal(row, clm, moveItem)) {
                          return;
                        }

                        print("SET MOVE FALSE");

                        if (moveItem == int.parse("$count$position") &&
                            currentOffsets[moveItem]["moved"] == false) {
                          print("UNMARKING THE POSITION TO MOVE");
                          currentOffsets[moveItem]["xPosition"] = -1;
                          currentOffsets[moveItem]["bottom"] =
                              offsets[int.parse("$count$position")]
                                  ["initBottom"];
                          currentOffsets[moveItem]["left"] =
                              offsets[int.parse("$count$position")]["initLeft"];
                          currentOffsets[moveItem]["moved"] = false;
                          currentOffsets[moveItem]["highlighted"] = false;
                          currentOffsets[moveItem]["predicted"] = false;
                          currentOffsets = unhighlightAll(currentOffsets);
                          setState(() {
                            move = false;
                            offsets = currentOffsets;
                            diceNo = null;
                          });
                        } else if (moveItem == int.parse("$count$position") &&
                            currentOffsets[moveItem]["moved"]) {
                          currentOffsets[moveItem]["highlighted"] = false;
                          setState(() {
                            move = false;
                            offsets = currentOffsets;
                            diceNo = null;
                          });
                        } else {
                          print("OUGHT TO MOVE");
                          // first check if the goti that was clicked is it in home.
                          // if it is home then change the selection without moving
                          if (offsets[int.parse("$count$position")]
                                  ["xPosition"] ==
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
                                offsets[int.parse("$count$position")]
                                    ["xPosition"];
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
                                isSafePosition(currentOffsets[
                                            int.parse("$count$position")]
                                        ["xPosition"]) ==
                                    false) {
                              currentOffsets[moveItem]["playerIndex"] += 1;
                              print("KILLING!!!!!!!!!!!!!!!!!!!!!!!!!!");
                              currentOffsets[moveItem]["kills"] += 1;
                              // currentOffsets[int.parse("$count$position")] =
                              //     defaultOffsets[int.parse("$count$position")];
                              currentOffsets[int.parse("$count$position")]
                                  ["xPosition"] = -1;
                              currentOffsets[int.parse("$count$position")]
                                  ["onMultiple"] = false;
                              currentOffsets[int.parse("$count$position")]
                                  ["sizeMultiplier"] = 1;
                              print(currentOffsets[int.parse("$count$position")]
                                  ["xPosition"]);
                              currentOffsets[int.parse("$count$position")]
                                  ["moved"] = false;
                            }

                            // Check multiple on one walla case
                            currentOffsets =
                                adjustForMultipleOnOne(currentOffsets);
                            print("SETSTATE----------------");

                            setState(() {
                              move = false;
                              offsets = currentOffsets;
                              diceNo = null;
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
                          moveGotiToV2(currentOffsets,
                              int.parse("$count$position"), diceNo);
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
                    }
                  },
                  child: Container(
                      child: offsets[int.parse("$count$position")]["predicted"]
                          ? BlinkingWidget(Image.asset(
                              offsets[int.parse("$count$position")]
                                      ["highlighted"]
                                  ? "assets/_goti_${selectedColorList[position]["name"]}.png"
                                  : "assets/goti_${selectedColorList[position]["name"]}.png",
                              width: size,
                              height: size,
                              fit: BoxFit.fitHeight,
                            ))
                          : Image.asset(
                              offsets[int.parse("$count$position")]
                                      ["highlighted"]
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
    } else {
      return Container();
    }
  }

  Map<int, dynamic> adjustForMultipleOnOne(Map<int, dynamic> currentOffsets) {
    for (int xPosition = 0; xPosition < 75; xPosition++) {
      print('in adjustForMultipleOnOne xPosition: ' + xPosition.toString());
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
        print(">>>>>>>>>>>>>>>>>>>>>>GREATER THAN 0 ${overlapingKeys.length}");
        double gap = ((getLeft(context, 1) - getLeft(context, 0)) /
                overlapingKeys.length) *
            0.6;

        for (int i = 0; i < overlapingKeys.length; i++) {
          print("KEYYSSS >>>>>>>>>>> ${overlapingKeys[i]}");
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
      } else if (overlapingKeys.length == 1) {
        print("ONLY ONE KEY IN BOX");
        currentOffsets[overlapingKeys[0]]['onMultiple'] = false;
        currentOffsets[overlapingKeys[0]]['sizeMultiplier'] = 1;
        currentOffsets[overlapingKeys[0]]['left'] = getLeft(context, clm);
      } else if (xPosition == -1 && overlapingKeys.length > 0) {
        print("MULTIPLE -1 _____________________--");

        for (int i = 0; i < overlapingKeys.length; i++) {
          currentOffsets[overlapingKeys[i]]['sizeMultiplier'] = 1;
          currentOffsets[overlapingKeys[i]]['onMultiple'] = false;
          currentOffsets[overlapingKeys[0]]['left'] = getLeft(context, clm);
        }
      }
    }
    print(currentOffsets.toString());
    print("------------------------DOONNEEE WITH CALCULATION");
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

    print("SETSTATE----------------");

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
    print("SETSTATE----------------");

    currentOffsets[moveItem] = temp;

    currentOffsets = unhighlightAll(currentOffsets);

    setState(() {
      move = false;
      offsets = currentOffsets;
      diceNo = null;
    });
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
      print("newXPos: " + newXPos.toString());
      if (newXPos == 52 && diceNo == 1) {
        newXPos = 0;
      } else if (currentOffsets[moveItem]["playerIndex"] == 0) {
        rowClm = get2Dfrom1D(newXPos);
      } else {
        if (currentOffsets[moveItem]["playerIndex"] == 1) {
          print('player 1');
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
          print('player 2');
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
          print('player 3');
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
    print("SETSTATE----------------");

    currentOffsets[moveItem] = temp;

    currentOffsets = unhighlightAll(currentOffsets);

    setState(() {
      move = false;
      offsets = currentOffsets;
    });
    if (diceNo != 6) {
      print("DICE NUMBER NOT 6 $diceNo");

      setState(() {
        tappedPlayer = tappedPlayer == 0 ? 2 : 0;
        predictionText = '';
      });
    }
    // else {
    //   setState(() {
    //     tappedPlayer = 2;
    //   });
    print("DICE NO 6 $diceNo");
    // }

    setState(() {
      diceNo = null;
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
      print(diceNo);
      player2xPositions.forEach((xPos) {
        if (!isSafePosition(xPos + diceNo)) {
          int index = player2xPositions
              .indexWhere((xPosition) => xPosition == (xPos + diceNo));
          if (index != -1) {
            if (invalidNos.indexOf(diceNo) == -1) {
              invalidNos.add(diceNo);
              print("INVALID $diceNo");
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
                child: topRow(context, "STATS"),
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
                            print(temp[winningPlayer]['user'].wins);
                            setState(() {
                              selectedColorList = temp;
                            });
                            DBProvider.db.updateUser(user);
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
        width: 50,
        height: 50,
        child: selectedColorList[position] != null
            ? Center(
                child: Column(children: [
                Image.asset(
                    "assets/${position == winningPlayer ? '_' : ''}avatar_${selectedColorList[position]["name"]}.png",
                    height: 50,
                    width: 50),
              ]))
            : Center(
                child: Icon(Icons.add),
              ),
      ),
    );
  }

  void addMemberDialog(int position, bool self, {User user}) {
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
                          child: user == null
                              ? nameTextForm()
                              : TextFormField(
                                  expands: false,
                                  initialValue: user.name,
                                  onChanged: (value) {
                                    print("ONCHANGED $value");
                                    setState(() {
                                      print(value);
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
                          children: <Widget>[
                            colorDropDown('Color', setState, user: user)
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        bottomRow(position, self, user: user)
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
      onSaved: (value) {
        print(value);
        setState(() {
          currentPlayerName = value;
        });
      },
    );
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
    List<Widget> layoutItems = [];
    layoutItems.addAll([colorBox(0), colorBox(1), colorBox(3), centerSquare()]);
    if (selectedColorList[2] != null) {
      layoutItems.add(colorBox(2));
    }
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
                      print("================LAYOUT============");

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
                        currentOffsets = unhighlightAll(currentOffsets);

                        setState(() {
                          move = false;
                          offsets = currentOffsets;
                          diceNo = null;
                        });
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
//                        margin: EdgeInsets.only(
//                          bottom: 5,
//                        ),
                        // child:
                        // Text(
                        //   // $row,$col\n
                        //   "$x",
                        //   style: TextStyle(color: Colors.black, fontSize: 10),
                        // ),
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

  Widget colorDropDown(String label, Function setStateFunc, {User user}) {
    List<Map<String, dynamic>> temp =
        user == null ? availableColors : allColors;
    print(temp);
    print('------------->in colorDropDown()');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.green.shade400, width: 2),
          borderRadius: BorderRadius.circular(25)),
      width: MediaQuery.of(context).size.width * 0.65,
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

  Widget bottomRow(int position, bool self, {User user}) {
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
            if (user == null) {
              setState(() {
                currentPlayerName = _typeAheadController.text;
              });
            }

            // if (currentPlayerName != null) {
            savePlayer(position, self, user: user);
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
        Map<int, dynamic> currentOffsets = offsets;

        if (selectedColorList[position] == null) {
          addMemberDialog(position, false);
        } else {
          if (position != 0) {
            if (playerAutoMove) {
              for (int i = 0; i < 4; i++) {
                currentOffsets[int.parse("$i$tappedPlayer")]["highlighted"] =
                    false;
                print("AUTOMOVE TRUE");
              }
              setState(() {
                offsets = currentOffsets;
              });
              if (position == tappedPlayer) {
                setState(() {
                  playerAutoMove = false;
                  tappedPlayer = null;
                });
              } else {
                setState(() {
                  playerAutoMove = true;
                  tappedPlayer = position;
                });
              }
            } else {
              setState(() {
                playerAutoMove = true;
                tappedPlayer = position;
              });
            }
          } else {
            if (playerAutoMove) {
              for (int i = 0; i < 4; i++) {
                currentOffsets[int.parse("$i$tappedPlayer")]["highlighted"] =
                    false;
                print("AUTOMOVE TRUE");
              }
              setState(() {
                offsets = currentOffsets;
              });
              setState(() {
                playerAutoMove = false;
                tappedPlayer = null;
              });
            } else {
              setState(() {
                playerAutoMove = true;
                tappedPlayer = position;
              });
            }
          }
        }
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
          Text(selectedColorList[position] != null
              ? selectedColorList[position]["playerName"] != null
                  ? selectedColorList[position]["playerName"]
                  : ""
              : ""),
          position == 0
              ? GestureDetector(
                  child: Icon(Icons.edit),
                  onTap: () {
                    setState(() {
                      selectedColor = selectedColorList[0]['user'].color;
                      currentPlayerName = selectedColorList[0]['user'].name;
                    });
                    print(selectedColorList[0]['user'].color);
                    addMemberDialog(0, true,
                        user: selectedColorList[0]['user']);
                  },
                )
              : Container()
          // selectedColorList[position] != null
          //     ? (selectedColorList[position]["playerName"] != null &&
          //             selectedColorList[position]["playerName"] != '')
          //         ? GestureDetector(
          //             onTap: () {
          //               print("Get Stats for: " + position.toString());

          //               // calculate stats
          //               int totalHouses = getTotalHouses(position);
          //               print("totalHouses :" + totalHouses.toString());

          //               // calculate stats
          //               int sixToStart = getSixToStart(position);
          //               print("sixToStart :" + sixToStart.toString());

          //               // calculate stats
          //               int kills = getKills(position);
          //               print("kills :" + kills.toString());

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
                            margin: EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: e["value"]),
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
        child: selectedColorList[position] != null
            ? Center(
                child: Column(children: [
                Image.asset(
                    "assets/${position == tappedPlayer ? '_' : ''}avatar_${selectedColorList[position]["name"]}.png",
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
    print("SELFPLAYERNAME ${user.color}");
    List<Map<String, dynamic>> currentList = selectedColorList;
    currentList[0] =
        availableColors.firstWhere((element) => element["name"] == user.color);
    currentList[0]["playerName"] = user.name;
    currentList[0]["kills"] = 0;
    currentList[0]["houses"] = 0;
    currentList[0]["sixes"] = 0;
    currentList[0]['user'] = user;

    List<Map<String, dynamic>> currentColors = availableColors;
    currentColors.removeWhere((element) => element["name"] == user.color);

    setState(() {
      selectedColorList = currentList;
      availableColors = currentColors;
      selectedColor =
          availableColors.length == 0 ? "red" : availableColors[0]["name"];
      currentPlayerName = null;
    });
  }

  void savePlayer(int position, bool self, {User user}) async {
    List<Map<String, dynamic>> currentColors = availableColors;
    if (user != null && selectedColorList[0]['color'] != selectedColor) {
      print("ADD COLORRR");
      print(selectedColorList[0]);
      currentColors.add(allColors.firstWhere(
          (element) => element["name"] == selectedColorList[0]['name']));
    }
    print('------------->in savePlayer()');
    List<Map<String, dynamic>> currentList = selectedColorList;
    currentList[position] = user == null
        ? availableColors
            .firstWhere((element) => element["name"] == selectedColor)
        : allColors.firstWhere((element) => element["name"] == selectedColor);
    currentList[position]["playerName"] = currentPlayerName;
    print("CURRENT PLAYER NAME $currentPlayerName");
    currentList[position]["kills"] = 0;
    currentList[position]["houses"] = 0;
    currentList[position]["sixes"] = 0;

    currentColors.removeWhere((element) => element["name"] == selectedColor);

    if (currentColors.length == 1) {
      int otherPos = position == 1 ? 3 : 1;
      currentList[otherPos] = currentColors[0];
      currentList[otherPos]["playerName"] = null;
      currentList[otherPos]["kills"] = 0;
      currentList[otherPos]["houses"] = 0;
      currentList[otherPos]["sixes"] = 0;
    }

    if (position == 2 || position == 0) {
      print("CURRENT PLAYER NAME $currentPlayerName");
      if (user != null) {
        await DBProvider.db.updateUser(User(
            id: user.id,
            color: selectedColor,
            name: currentPlayerName,
            games: user.games,
            wins: user.wins,
            self: self));
        currentList[position]["user"] = User(
            id: user.id,
            color: selectedColor,
            name: currentPlayerName,
            games: user.games,
            wins: user.wins,
            self: self);
      } else {
        User userRcvd = await DBProvider.db.newUser(User(
            color: selectedColor,
            name: currentPlayerName,
            games: 0,
            wins: 0,
            self: self));
        currentList[position]["user"] = userRcvd;
      }
    }
    setState(() {
      selectedColorList = currentList;
      availableColors = currentColors;
      selectedColor =
          availableColors.length == 0 ? "red" : availableColors[0]["name"];
      currentPlayerName = null;
    });
  }

  Widget colorBox(int position) {
    // if (selectedColorList[position] != null) {
    switch (position) {
      case 0:
        return bottomLeft(selectedColorList[position], context, position,
            positions, playerAddButton(0));

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
    print('------------->in screenBottomRow()');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(children: [
          SizedBox(
            width: 10,
          ),
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
          SizedBox(
            width: 10,
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
                        setState(() {
                          tappedPlayer = 0;
                        });
                        onDiceTap(e, 0);
                      },
                      child: Image.asset(
                        "assets/dice-$e.png",
                        fit: BoxFit.fill,
                        width: diceNo == e && tappedPlayer == 0
                            ? MediaQuery.of(context).size.width * 0.12
                            : MediaQuery.of(context).size.width * 0.10,
                        height: diceNo == e && tappedPlayer == 0
                            ? MediaQuery.of(context).size.width * 0.12
                            : MediaQuery.of(context).size.width * 0.10,
                      ),
                    ))
                .toList())
      ],
    );
  }

  void onDiceTap(int number, int position) {
    print('------------->in onDiceTap()');
    Map<int, dynamic> currentOffsets = offsets;

    setState(() {
      diceNo = number;
    });
    if (position == 2) {
      for (int i = 0; i < 4; i++) {
        currentOffsets[int.parse("$i$tappedPlayer")]["highlighted"] = true;
      }
    } else {
      int index = startGameSuggestion(getCurrentBoardStatus(number));
      setState(() {
        predictionText =
            "MOVE ${selectedColorList[0]['name'].toString().substring(0, 1).toUpperCase()}$index";
      });
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
