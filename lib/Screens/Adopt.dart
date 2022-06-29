import 'dart:developer';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_latlong/flutter_latlong.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:petlify/Screens/Account.dart';
import 'package:petlify/Screens/Chats.dart';
import 'package:petlify/Screens/EditProfile.dart';
import 'package:petlify/Screens/MyProfile.dart';
import 'package:share/share.dart';

class Adopt extends StatefulWidget {
  final String id;
  final String photo;
  final String? lon;
  final String? lan;
  final String? sex;
  final String? age;
  final String? uid;
  final String? more;
  final String? name;
  final String? price;

  const Adopt({
    Key? key,
    required this.id,
    required this.age,
    required this.lan,
    required this.lon,
    required this.more,
    required this.photo,
    required this.sex,
    required this.name,
    required this.uid,
    required this.price,
  }) : super(key: key);

  @override
  _AdoptState createState() => _AdoptState();
}

class _AdoptState extends State<Adopt> {
  final Distance distance = new Distance();
  String username = "username";
  String username2 = "username";
  String userphoto =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
  bool verified = false;
  String userphoto2 =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
  String photo = "";
  String useremail = "";
  String lan = ".0";
  String lon = ".0";
  var location = "";

  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    userinfo() async {
      final user = await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          lan = value.data()!['lan'];
          lon = value.data()!['lon'];
          userphoto2 = value.data()!['photo'];
          username2 = value.data()!['name'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      final user2 = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .get()
          .then((value) {
        setState(() {
          useremail = value.data()!['email'];
          username = value.data()!['name'];
          verified = value.data()!['verified'];
          userphoto = value.data()!['photo'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    userinfo();
    Future loc() async {
      double lot = .0;
      double lat = .0;
      try {
        setState(() {
          lat = double.parse(widget.lan.toString());
          lot = double.parse(widget.lon.toString());
        });
      } catch (NumberFormatException) {}

      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(Coordinates(
        lat,
        lot,
      ));
      location =
          "${addresses.first.countryName.toString()},${addresses.first.adminArea.toString()},${addresses.first.locality.toString()},${addresses.first.subLocality.toString()}";
    }

    loc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            AvatarGlow(
              glowColor: Colors.black,
              endRadius: 30.0,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: IconButton(
                      onPressed: () {
                        Share.share("https://petlify.page.link/p");
                      },
                      icon: Icon(Icons.reply))),
            ),
            SizedBox(
              width: 10,
            )
          ]),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Hero(
              tag: widget.photo,
              child: Image.network(
                widget.photo,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 1.2,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          widget.name.toString(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Color(0xff3B3B3B),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          widget.price.toString(),
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff1c3c87),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Icon(Icons.room, color: Colors.grey, size: 14),
                            Text(
                              location,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "(${distance.as(LengthUnit.Kilometer, LatLng(double.parse(widget.lan.toString()), double.parse(widget.lon.toString())), LatLng(double.parse(lan.toString()), double.parse(lon.toString()))).toString()} km)",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          ' Pet Owner',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff3B3B3B),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            if (widget.uid == auth.currentUser!.uid) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MyProfile(),
                              ));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Profile(
                                  id: widget.uid.toString(),
                                  lan: lan,
                                  lon: lon,
                                ),
                              ));
                            }
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/profile.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                userphoto,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () async {
                            if (widget.uid == auth.currentUser!.uid) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MyProfile(),
                              ));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Profile(
                                  id: widget.uid.toString(),
                                  lan: lan,
                                  lon: lon,
                                ),
                              ));
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                username.length > 16
                                    ? "${username.substring(0, 16)}..."
                                    : username,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xff3B3B3B),
                                    fontWeight: FontWeight.w500),
                              ),
                              Visibility(
                                  visible: verified,
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.green, //Color(0xFFE25E31),
                                    size: 20,
                                  )),
                            ],
                          ),
                        ),
                        trailing: AvatarGlow(
                          glowColor: Colors.grey,
                          endRadius: 25.0,
                          duration: Duration(milliseconds: 2000),
                          repeat: true,
                          child: IconButton(
                              icon: Icon(
                                Icons.chat,
                                color: Color(0xFFF58524),
                              ),
                              onPressed: () async {
                                if (widget.uid == auth.currentUser!.uid) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MyProfile(),
                                  ));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) => SpinKitCircle(
                                            color: Colors
                                                .white, //Color(0xffE25E31),
                                            size: 70.0,
                                          ));
                                  final id =
                                      new DateTime.now().millisecondsSinceEpoch;
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(widget.id)
                                      .collection("Chats")
                                      .doc(auth.currentUser!.uid)
                                      .set({
                                    'id': auth.currentUser!.uid.toString(),
                                    'name': username,
                                    'photo': userphoto,
                                    'msg': "",
                                    'seen': true,
                                    'email': auth.currentUser!.email.toString(),
                                    'time': id.toString(),
                                    'status': ""
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(auth.currentUser!.uid)
                                      .collection("Chats")
                                      .doc(widget.id)
                                      .set({
                                    'id': widget.id.toString(),
                                    'name': username,
                                    'photo': userphoto,
                                    'msg': "",
                                    'seen': true,
                                    'email': useremail,
                                    'time': id.toString(),
                                    'status': ""
                                  });
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Chats(
                                            id: widget.uid.toString(),
                                            useremail: useremail,
                                            username: username,
                                            userphoto: userphoto,
                                          )));
                                }
                              }),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          ' Details',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff3B3B3B),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Age",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  widget.age.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xffF75950),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Sex",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  widget.sex.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xffF75950),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          widget.more.toString(),
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (widget.uid == auth.currentUser!.uid) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyProfile(),
                            ));
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => SpinKitCircle(
                                      color: Colors.white, //Color(0xffE25E31),
                                      size: 70.0,
                                    ));
                            final id =
                                new DateTime.now().millisecondsSinceEpoch;
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(widget.uid)
                                .collection("Chats")
                                .doc(auth.currentUser!.uid)
                                .set({
                              'id': auth.currentUser!.uid.toString(),
                              'name': username,
                              'photo': userphoto,
                              'msg': "",
                              'seen': true,
                              'email': auth.currentUser!.email.toString(),
                              'time': id.toString(),
                              'status': ""
                            });
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(auth.currentUser!.uid)
                                .collection("Chats")
                                .doc(widget.id)
                                .set({
                              'id': widget.id.toString(),
                              'name': username,
                              'photo': userphoto,
                              'msg': "",
                              'seen': true,
                              'email': useremail,
                              'time': id.toString(),
                              'status': ""
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Chats(
                                      id: widget.uid.toString(),
                                      useremail: useremail,
                                      username: username,
                                      userphoto: userphoto,
                                    )));
                          }
                        },
                        child: Container(
                          height: 52,
                          width: MediaQuery.of(context).size.width / 1.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                                colors: const [
                                  Color(0xFFF58524),
                                  Color(0xFFF92B7F),
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
                                  "Adopt",
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
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
