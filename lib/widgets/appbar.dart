import 'package:flutter/material.dart';

Widget appBar(BuildContext context, bool showSplash, Function undo) {
  return showSplash
      ? null
      : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // Image.asset(
                  //   "assets/undo_icon.png",
                  //   width: 30,
                  //   fit: BoxFit.contain,
                  // ),
                  // Text('undo'),
                ],
              ),
              Center(
                child: Image.asset(
                  "assets/logo.png",
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: undo,
                    child: Image.asset(
                      "assets/undo_icon.png",
                      width: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Text('undo'),
                ],
              ),
            ],
          ),
        );
}
