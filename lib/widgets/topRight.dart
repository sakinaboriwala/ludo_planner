import 'package:flutter/material.dart';

Widget topRight(selectedColorObject, BuildContext context, int position,
    List positions, Widget playerAddButton, Function onClick) {
  var colorObj = selectedColorObject == null
      ? null
      : selectedColorObject["name"] == null ? null : selectedColorObject;

  if (colorObj != null) {
    print("COLOR OBJECT ---------->>>>>>>>>> NOT NULL TOPRIG");

    return Align(
        alignment: Alignment.topRight,
        child: Container(
            // color: Colors.red,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.001),
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.534,
            child: Row(
              children: <Widget>[
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.075),
                        width: MediaQuery.of(context).size.width * 0.132,
                        height: MediaQuery.of(context).size.width * 0.34,
                        child: Image.asset(
                          "assets/${positions[position]}_${colorObj["name"]}L.png",
                          fit: BoxFit.fill,
                        ))),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: Stack(children: [
                    Image.asset(
                      "assets/bottom${position == 0 || position == 3 ? "left" : "right"}_${colorObj["name"]}BOX.png",
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/dots_${colorObj["name"]}.png",
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.width * 0.2,
                        ))
                  ]),
                )
              ],
            )));
  } else {
    print("ELSE//////////////////////////////");
    return Align(
        alignment: Alignment.topRight,
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
                onClick(2, false);
              },
              child: Center(
                child: playerAddButton,
              ),
            )));
  }
}
