import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:petlify/Screens/Home.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petlify/Models/usermodel.dart';
import 'package:petlify/Screens/Location.dart';
import 'package:petlify/Screens/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:regexpattern/src/regex_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final email_controller = TextEditingController();
  final password_controller = TextEditingController();
  final confirm_controller = TextEditingController();
  final name_controller = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool passwordVisible = true;
  bool passwordVisible2 = true;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final cloudinary =
      Cloudinary("366248915146297", "BIyUWoSbzvzjy2Xqx73JXnVnWzY", "dvhlfyvrr");
  File? image;

  bool loading = false;
  String photo =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";

  void cropper() async {
    final cropimage = await ImageCropper.cropImage(
        sourcePath: image!.path, compressQuality: 35);
    final Directory dir = await getApplicationDocumentsDirectory();
    final String appDir = dir.path;
    final File imageFile = File(appDir + '/profile_picture.jpg');
    if (await imageFile.exists()) {
      imageFile.delete();
    }
    imageCache.clearLiveImages();
    imageCache.clear();
    final File copiedImage =
        await cropimage!.copy('$appDir/profile_picture.jpg');
    setState(() {
      loading = true;
    });

    final response = await cloudinary.uploadFile(
      filePath: copiedImage.path,
      resourceType: CloudinaryResourceType.image,
      folder: "Petlify/Profile",
    );

    if (response.isSuccessful) {
      setState(() {
        photo = response.url!;

        loading = false;
      });
    }

    //  Reference ref = FirebaseStorage.instance.ref().child("image");
    // ref.putFile(crop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    AvatarGlow(
                      glowColor: Colors.grey,
                      endRadius: 70.0,
                      duration: Duration(milliseconds: 2000),
                      repeat: false,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.width / 2.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/profile.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Image.network(
                                photo,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: MediaQuery.of(context).size.width / 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Visibility(
                          visible: loading,
                          child: SpinKitCircle(
                            color: Colors.white, //Color(0xffE25E31),
                            size: 40.0,
                          ),
                        )),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () async {
                            // final getimage = await ImagePicker.platform
                            //      .pickImage(source: ImageSource.gallery);
                            //  setState(() {
                            //    image = File(getimage!.path);
                            //  });
                            //   cropper();
                            showMaterialModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final getimage = await ImagePicker
                                            .platform
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        setState(() {
                                          image = File(getimage!.path);
                                        });
                                        Navigator.of(context).pop();
                                        cropper();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 65,
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Icon(
                                                  Icons.collections,
                                                  color: Color(0xff3B3B3B),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  "Gallery",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Color(0xff3B3B3B),
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Spacer(),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Color(0xff3B3B3B),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final getimage = await ImagePicker
                                            .platform
                                            .pickImage(
                                                source: ImageSource.camera);
                                        setState(() {
                                          image = File(getimage!.path);
                                        });
                                        Navigator.of(context).pop();
                                        cropper();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 65,
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Icon(
                                                  Icons.add_a_photo,
                                                  color: Color(0xff3B3B3B),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  "Camera",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Color(0xff3B3B3B),
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Spacer(),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Color(0xff3B3B3B),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 33,
                            width: 33,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                gradient: RadialGradient(
                                  colors: const [
                                    const Color(0xFFF92B7F),
                                    const Color(0xFFF58524),
                                  ],
                                  // begin: const FractionalOffset(0.0, 0.0),
                                  // end: const FractionalOffset(1.0, 0.0),
                                  stops: const [0.0, 1.0],
                                ),
                                shape: BoxShape.circle),
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  cursorColor: Color(0xff707070),
                  controller: name_controller,
                  keyboardType: TextInputType.text,
                  autofillHints: [AutofillHints.name],
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      labelText: "Name",
                      labelStyle: TextStyle(color: Color(0xff707070))),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  cursorColor: Color(0xff707070),
                  controller: email_controller,
                  keyboardType: TextInputType.emailAddress,
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
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  obscureText: passwordVisible,
                  cursorColor: Color(0xff707070),
                  controller: password_controller,
                  autofillHints: [AutofillHints.password],
                  keyboardType: TextInputType.visiblePassword,
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
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  obscureText: passwordVisible2,
                  cursorColor: Color(0xff707070),
                  controller: confirm_controller,
                  autofillHints: [AutofillHints.password],
                  keyboardType: TextInputType.visiblePassword,
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
                            passwordVisible2 = !passwordVisible2;
                          });
                        },
                        icon: Icon(
                          passwordVisible2
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[500],
                        ),
                      ),
                      labelText: "Confirm Password",
                      labelStyle: TextStyle(color: Color(0xff707070))),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              GestureDetector(
                onTap: () {
                  if (name_controller.text.isNotEmpty) {
                    if (email_controller.text.isEmail()) {
                      if (password_controller.text.length > 5) {
                        if (password_controller.text
                            .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                          if (password_controller.text
                              .contains(RegExp(r"[a-z]"))) {
                            if (password_controller.text
                                .contains(RegExp(r"[0-9]"))) {
                              if (password_controller.text ==
                                  confirm_controller.text) {
                                signUp(email_controller.text,
                                    password_controller.text);
                                showDialog(
                                    context: context,
                                    builder: (context) => SpinKitCircle(
                                          color:
                                              Colors.white, //Color(0xffE25E31),
                                          size: 50.0,
                                        ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration: Duration(milliseconds: 500),
                                        backgroundColor: Colors.red,
                                        content:
                                            Text("Password doesn't match!")));
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  duration: Duration(milliseconds: 500),
                                  backgroundColor: Colors.red,
                                  content: Text(
                                      "Passwords must have at least one number")));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: Duration(milliseconds: 500),
                                backgroundColor: Colors.red,
                                content: Text(
                                    "Passwords must have at least one alphabet")));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(milliseconds: 500),
                              backgroundColor: Colors.red,
                              content: Text(
                                  "Passwords must have at least one special character")));
                        }
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 500),
                        backgroundColor: Colors.red,
                        content: Text("Please Enter your name")));
                  }
                },
                child: Container(
                  height: 52,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                        colors: const [
                          const Color(0xFFF58524),
                          const Color(0xFFF92B7F),
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 0.0),
                        stops: const [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Image.network(
                          "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641292589/Pet%20Life/Data/Path_8_wmyigp.png",
                          width: 25,
                          height: 25,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You already have an account? ",
                    style: TextStyle(fontSize: 16, color: Color(0xff707070)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      " Login",
                      style: TextStyle(fontSize: 16, color: Color(0xffF92B7F)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
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
      )),
    );
  }

  void signUp(String email, String password) async {
    await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((uid) => {
              postDetailsToFirestore(),
            })
        .catchError((e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
    });
  }

  postDetailsToFirestore() async {
    final status = await OneSignal.shared.getDeviceState();
    final String? tokenId = status?.userId;
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;

    usermodel userModel = usermodel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.name = name_controller.text;
    userModel.photo = photo;
    userModel.tokenid = tokenId;
    userModel.status = "Online";
    userModel.followers = [];
    userModel.following = [];
    userModel.lan = "";
    userModel.lon = "";
    userModel.verified = false;
    userModel.location = "";
    userModel.bio = "";
    userModel.search =
        name_controller.text.toLowerCase().replaceAll(RegExp(r"\s+"), "");

    await firebaseFirestore
        .collection("Users")
        .doc(userModel.uid)
        .set(userModel.toMap());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text("Account Created Successfully")));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => userLocation()));
  }
}
