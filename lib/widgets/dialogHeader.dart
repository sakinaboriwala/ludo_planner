import 'package:flutter/material.dart';

Widget topRow(BuildContext context, String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(
        text,
        style: TextStyle(color: Colors.green.shade400),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade400, width: 6)),
          child: Icon(
            Icons.close,
            color: Colors.green.shade400,
          ),
        ),
      )
    ],
  );
}
