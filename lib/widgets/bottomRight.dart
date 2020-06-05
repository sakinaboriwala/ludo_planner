import 'package:flutter/material.dart';

Widget bottomRight(
    selectedColorObject, BuildContext context, int position, List positions) {
  if (selectedColorObject != null) {
    return Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: EdgeInsets.only(bottom:MediaQuery.of(context).size.width * 0.0038),
            height: MediaQuery.of(context).size.width * 0.53,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              children: <Widget>[
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      // color: Colors.red,
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.075),
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.width * 0.130,
                        child: Image.asset(
                          "assets/${positions[position]}_${selectedColorObject["name"]}L.png",
                          fit: BoxFit.cover,
                        ))),
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
                )
              ],
            )));
  } else {
    return Container();
  }
}
