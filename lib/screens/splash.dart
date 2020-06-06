import 'dart:async';
import 'package:flutter/material.dart';

const SPLASH_DURATION = 2000;

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashState();
  }
}

class SplashState extends State<SplashScreen> {
  AnimationController _controller;
  String version = '';
  Image image = Image.asset("assets/splashscreen.jpg");
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(image.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(image: image.image, fit: BoxFit.cover)),
        child: Container()
      ),
    );
  }
}
