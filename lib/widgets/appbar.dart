import 'package:flutter/material.dart';

Widget appBar(BuildContext context, bool showSplash, Function undo) {
  return showSplash
      ? null
      : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Stack(children: <Widget>[
            Center(
              child: Image.asset(
                "assets/logo.png",
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ),
            Positioned(
              top: 10,
              right: -2,
              child: Row(
                children: <Widget>[
                  Text('UNDO',
                      style: TextStyle(color: Color(0xff465e6e), fontSize: 12)),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: undo,
                    child: Image.asset(
                      "assets/undo_icon.png",
                      width: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            )
          ]));
}
