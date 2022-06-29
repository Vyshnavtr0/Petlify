import 'dart:async';
import 'dart:math';
import 'package:petlify/Screens/Home.dart';
import 'package:petlify/Screens/Location.dart';
import 'package:petlify/Screens/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final auth = FirebaseAuth.instance;
  var list = [
    'text',
    'id',
    'post',
  ];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
    configOneSignel();
  }

  void configOneSignel() {
    OneSignal.shared.setAppId('fe28bc6d-c813-4e9b-8a69-c95c63638c32');
  }

  @override
  Widget build(BuildContext context) {
    final _random = Random();

    String element = list[_random.nextInt(list.length)];

    Future<void> nextscreen(ctx) async {
      await Future.delayed(Duration(seconds: 3));

      if (auth.currentUser == null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Home(
                  random: element,
                )));
      }
    }

    nextscreen(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          decoration: BoxDecoration(

              /*  image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              "assets/images/bg.png",
            ),
          )*/
              ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: MediaQuery.of(context).size.width / 4,
                height: MediaQuery.of(context).size.width / 4,
              ),
              Image.asset(
                "assets/images/logoname.png",
                width: MediaQuery.of(context).size.width / 4.5,
                height: MediaQuery.of(context).size.width / 4.5,
              ),
            ],
          ))),
    );
  }
}
