import 'package:petlify/Screens/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(),
    home: DogLife(),
  ));
}

class DogLife extends StatelessWidget {
  const DogLife({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Splash();
  }
}
