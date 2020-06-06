import 'package:flutter/material.dart';

Widget appBar(BuildContext context, bool showSplash) {
  return showSplash
      ? null
      : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/logo.png",
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ],
          ),
        );
}
