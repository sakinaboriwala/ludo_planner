import 'package:flutter/material.dart';

List<List<Widget>> initGridState(BuildContext context) {
  List<List<Widget>> gridArray = List.generate(14, (_) => new List(14));
  for (int i = 0; i <= 14; i++) {
    for (int j = 0; j <= 14; j++) {
      gridArray[i][j] = Positioned(
        bottom: MediaQuery.of(context).size.width * 0.066 * i,
        left: MediaQuery.of(context).size.width * 0.066 * j,
        child: Container(
            color: Colors.red,
            width: MediaQuery.of(context).size.width * 0.066,
            height: MediaQuery.of(context).size.width * 0.066),
      );
    }
  }

  return [[]];
}
