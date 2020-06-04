import 'package:flutter/material.dart';

double getBottom(BuildContext context, row) {
  double correction = MediaQuery.of(context).size.height / 61.3026819923;
  if (row < 7) {
    return MediaQuery.of(context).size.width * 0.0667 * row +
        ((correction * (row - 7).abs()) / 7);
  }
  if (row > 7) {
    return MediaQuery.of(context).size.width * 0.0667 * row -
        ((correction * (row - 7).abs()) / 7);
  }
  return MediaQuery.of(context).size.width * 0.0667 * row;
}

double getLeft(BuildContext context, col) {
  double correction = MediaQuery.of(context).size.width / 72;
  if (col < 7) {
    return MediaQuery.of(context).size.width * 0.0667 * col +
        ((correction * (col - 7).abs()) / 7);
  }
  if (col > 7) {
    return MediaQuery.of(context).size.width * 0.0667 * col -
        ((correction * (col - 7).abs()) / 7);
  }
  return MediaQuery.of(context).size.width * 0.0667 * col;
}
