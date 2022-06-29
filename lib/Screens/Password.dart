import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final email_controller = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Center(
              child: Image.asset(
                "assets/images/password.png",
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Forgot Your Password ?",
              style: TextStyle(fontSize: 25, color: Color(0xff3B3B3B)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Please enter the email address associated with your email. We will email you a link to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xff3B3B3B)),
              ),
            ),
            Spacer(),
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
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                if (email_controller.text != "") {
                  reset(email_controller.text);
                  showDialog(
                      context: context,
                      builder: (context) => SpinKitCircle(
                            color: Colors.white, //Color(0xffE25E31),
                            size: 50.0,
                          ));
                  email_controller.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 300),
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
                        const Color(0xFFF92B7F),
                        const Color(0xFFF58524),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Send",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        )));
  }

  void reset(String email) async {
    await auth
        .sendPasswordResetEmail(email: email)
        .then((uid) => {
              Navigator.of(context).pop(),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Password Reset email send successfully")))
            })
        .catchError((e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
    });
  }
}
