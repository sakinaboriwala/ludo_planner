import 'package:flutter/material.dart';

Widget appBar(bool showSplash) {
  return showSplash
      ? null
      : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Row(
              //   children: <Widget>[
              //     Text('drag'),
              //     Switch(
              //       value: false,
              //       onChanged: (value) {},
              //     ),
              //   ],
              // ),
              Text(
                'Ludo Planner',
                style: TextStyle(fontSize: 20),
              ),
              // Row(
              //   children: <Widget>[
              //     Image.asset(
              //       "assets/undo_icon.png",
              //       width: 30,
              //       fit: BoxFit.contain,
              //     ),
              //     Text('undo'),
              //   ],
              // ),
            ],
          ),
        );
}
