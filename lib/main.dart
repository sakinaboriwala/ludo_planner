import 'package:flutter/material.dart';
import 'package:ludo_planner/screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Planner',
      theme: ThemeData(
          fontFamily: 'RifficFree',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(bodyText2: TextStyle(color: Color(0xff465e6e), fontSize: 12))),
      routes: {
        '/': (context) => HomeScreen(Image.asset("assets/ludo_background.png")),
      },
    );
  }
}
