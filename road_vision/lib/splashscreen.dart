import 'dart:async';

import 'package:flutter/material.dart';
import 'package:road_vision/home.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _load = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
        Duration(seconds: 4),
        () => Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryanimation) {
                return Home();
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            )));
// 2. Future.delayed
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _load = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              height: 230,
            ),
            VxBox(
              child: Image.asset("assets/images/Logo.png"),
            ).p20.make(),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 60,
            ),
            if (_load)
              ...[]
            else ...[
              const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              )
            ]
          ],
        ),
      ),
    );
  }
}
