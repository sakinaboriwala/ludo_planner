import 'package:flutter/material.dart';
import 'package:ludo_planner/models/user.dart';

Widget bottomLeft(selectedColorObject, BuildContext context, int position,
    List positions, Widget playerAddButton, Function onClick) {
  if (selectedColorObject != null) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
            height: MediaQuery.of(context).size.width * 0.41,
            width: MediaQuery.of(context).size.width * 0.55,
            margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.0038),
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: Stack(children: [
                    Image.asset(
                      "assets/bottom${position == 0 || position == 3 ? "left" : "right"}_${selectedColorObject["name"]}BOX.png",
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/dots_${selectedColorObject["name"]}.png",
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.width * 0.2,
                        ))
                  ]),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        margin: EdgeInsets.only(top: 1),
                        width: MediaQuery.of(context).size.width * 0.130,
                        height: MediaQuery.of(context).size.width * 0.33,
                        child: Image.asset(
                          "assets/${positions[position]}_${selectedColorObject["name"]}L.png",
                          fit: BoxFit.fill,
                        )))
              ],
            )));
  } else {
    // return Align(
    //     alignment: Alignment.bottomLeft,
    //     child: Container(
    //         alignment: Alignment.center,
    //         height: MediaQuery.of(context).size.width * 0.4,
    //         width: MediaQuery.of(context).size.width * 0.4,
    //         margin: EdgeInsets.only(
    //             left: MediaQuery.of(context).size.width * 0.0038),
    //         child: GestureDetector(
    //           onTap: () {
    //             print("ON CLICKKK");
    //             onClick(0, true, user: User(), exists: false);
    //           },
    //           child: Center(child: selfPlayerAddButton),
    //         )));
    return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
            alignment: Alignment.center,
            // color: Colors.red,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.001),
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: GestureDetector(
              onTap: () {
                print("TAPPINNGGG");
                onClick(0, true, user: User(), exists: false);
              },
              child: Center(
                child: playerAddButton,
              ),
            )));
  }
}
