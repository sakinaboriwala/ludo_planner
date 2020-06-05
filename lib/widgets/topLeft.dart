import 'package:flutter/material.dart';

Widget topLeft(
    selectedColorObject, BuildContext context, int position, List positions) {
  if (selectedColorObject != null) {
    return Align(
        alignment: Alignment.topLeft,
        child: Container(
            // color: Colors.red,
            margin: EdgeInsets.only(top:0),
            height: MediaQuery.of(context).size.width * 0.531,
            width: MediaQuery.of(context).size.width * 0.41,
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4,
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.007),
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
                        width: MediaQuery.of(context).size.width * 0.335,
                        height: MediaQuery.of(context).size.width * 0.1230,
                        child: Image.asset(
                          "assets/${positions[position]}_${selectedColorObject["name"]}L.png",
                          fit: BoxFit.fill,
                        )))
              ],
            )));
  } else {
    return Container();
  }
}
