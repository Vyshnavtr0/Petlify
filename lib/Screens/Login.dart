import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petlify/Models/usermodel.dart';
import 'package:petlify/Screens/EditProfile.dart';
import 'package:petlify/Screens/Home.dart';
import 'package:petlify/Screens/Location.dart';
import 'package:petlify/Screens/Password.dart';
import 'package:petlify/Screens/Register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:regexpattern/src/regex_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email_controller = TextEditingController();
  final password_controller = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool passwordVisible = true;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? googleSignInAccount;
  var list = [
    'name',
    'text',
    'id',
  ];
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _random = new Random();
    String element = list[_random.nextInt(list.length)];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/logo.png",
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.width / 3,
                      ),
                      Image.asset(
                        "assets/images/logoname.png",
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: MediaQuery.of(context).size.width / 3.5,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: TextField(
                    cursorColor: Color(0xff707070),
                    keyboardType: TextInputType.emailAddress,
                    controller: email_controller,
                    autofillHints: [AutofillHints.email],
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff707070)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff707070)),
                        ),
                        labelText: "Email",
                        labelStyle: TextStyle(color: Color(0xff707070))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: TextField(
                    cursorColor: Color(0xff707070),
                    keyboardType: TextInputType.visiblePassword,
                    controller: password_controller,
                    obscureText: passwordVisible,
                    autofillHints: [AutofillHints.password],
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff707070)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff707070)),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[500],
                          ),
                        ),
                        labelText: "Password",
                        labelStyle: TextStyle(color: Color(0xff707070))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Password()));
                        },
                        child: Text(
                          "Forgot Password ?",
                          style:
                              TextStyle(fontSize: 16, color: Color(0xff707070)),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    if (email_controller.text.isEmail()) {
                      if (password_controller.text.length > 5) {
                        signIn(email_controller.text, password_controller.text);
                        showDialog(
                            context: context,
                            builder: (context) => SpinKitCircle(
                                  color: Colors.white, //Color(0xffE25E31),
                                  size: 50.0,
                                ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(milliseconds: 500),
                            backgroundColor: Colors.red,
                            content: Text(
                                "Please Enter your password (Min. 6 character)")));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(milliseconds: 500),
                          backgroundColor: Colors.red,
                          content: Text("Please Enter your email")));
                    }
                  },
                  child: Container(
                    height: 52,
                    width: MediaQuery.of(context).size.width / 1.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF58524),
                            const Color(0xFFF92B7F),
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(1.0, 0.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Image.network(
                            "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641286477/Pet%20Life/Data/Group_74_lya4we.png",
                            width: 25,
                            height: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) => SpinKitCircle(
                              color: Colors.white, //Color(0xffE25E31),
                              size: 50.0,
                            ));
                    try {
                      final GoogleSignInAccount? googleSignInAccount =
                          await _googleSignIn.signIn();
                      final GoogleSignInAuthentication
                          googleSignInAuthentication =
                          await googleSignInAccount!.authentication;
                      final AuthCredential credential =
                          GoogleAuthProvider.credential(
                        accessToken: googleSignInAuthentication.accessToken,
                        idToken: googleSignInAuthentication.idToken,
                      );
                      await auth.signInWithCredential(credential);

                      final status = await OneSignal.shared.getDeviceState();
                      final String? tokenId = status?.userId;
                      FirebaseFirestore firebaseFirestore =
                          FirebaseFirestore.instance;

                      User? user = auth.currentUser;
                      usermodel userModel = usermodel();

                      userModel.email = user!.email;
                      userModel.uid = user.uid;
                      userModel.name = user.displayName;
                      userModel.photo = user.photoURL;
                      userModel.tokenid = tokenId;
                      userModel.status = "Online";
                      userModel.followers = [];
                      userModel.following = [];
                      userModel.lan = "";
                      userModel.lon = "";
                      userModel.bio = "";
                      userModel.search = user.displayName
                          .toString()
                          .toLowerCase()
                          .replaceAll(RegExp(r"\s+"), "");
                      userModel.verified = false;

                      await firebaseFirestore
                          .collection("Users")
                          .doc(userModel.uid)
                          .set(userModel.toMap());
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Account Created Successfully")));
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => userLocation()));
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(e.message!)));
                      print(e.message);
                      throw e;
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: 52,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Login With Google ",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          Image.network(
                            "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641288186/Pet%20Life/Data/icons8-google-48_kiatwa.png",
                            width: 25,
                            height: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You don't have any account? ",
                      style: TextStyle(fontSize: 16, color: Color(0xff707070)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => Register()));
                      },
                      child: Text(
                        " Register",
                        style:
                            TextStyle(fontSize: 16, color: Color(0xffF92B7F)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    launch(
                        'https://www.freeprivacypolicy.com/live/e5f55e44-63ff-416c-910e-8058204d1bbf');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "By continuing, you agree to the ",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      Text(
                        "Terms of Services",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    launch(
                        'https://www.freeprivacypolicy.com/live/e5f55e44-63ff-416c-910e-8058204d1bbf');
                  },
                  child: Text(
                    " & Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signIn(String email, String password) async {
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((uid) => {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Login Successful"))),
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Home(
                        random: 'id',
                      )))
            })
        .catchError((e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
    });
  }
}
