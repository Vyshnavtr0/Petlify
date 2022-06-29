import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_latlong/flutter_latlong.dart';
import 'package:group_button/group_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:petlify/Screens/Adopt.dart';
import 'package:petlify/Screens/Chats.dart';
import 'package:petlify/Screens/Follow.dart';
import 'package:petlify/Screens/Newpost.dart';
import 'package:petlify/Screens/Snaps.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:video_player/video_player.dart';
import 'package:like_button/like_button.dart';
import 'package:readmore/readmore.dart';
import 'package:share/share.dart';
import 'dart:math' as math;
import "dart:math";
import 'package:timestamp_time_ago/timestamp_time_ago.dart';
import 'package:validated/validated.dart';

class Profile extends StatefulWidget {
  final String id;
  final String lan;
  final String lon;
  const Profile(
      {Key? key, required this.id, required this.lan, required this.lon})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? get heading => null;

  Future<Response> sendNotification(List<String> tokenIdList, String contents,
      String heading, String photo) async {
    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id":
            'fe28bc6d-c813-4e9b-8a69-c95c63638c32', //kAppId is the App Id that one get from the OneSignal When the application is registered.

        "include_player_ids":
            tokenIdList, //tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

        // android_accent_color reprsent the color of the heading text in the notifiction
        "android_accent_color": "FF9976D2",

        //"small_icon": photo,

        "large_icon": photo,
        //"big_picture":
        //   "http://res.cloudinary.com/dvhlfyvrr/image/upload/v1642347194/Pet%20Life/Posts/ngauljf4owaxk2ccwryn.jpg",

        "headings": {"en": heading},

        "contents": {"en": contents},
      }),
    );
  }

  final auth = FirebaseAuth.instance;
  String userphoto =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
  int selected = 0;
  String userphoto2 =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
  String? uid;
  String? useremail;

  final category_controller = GroupButtonController();
  int pageselected = 0;
  String username = "Username";
  String username2 = "Username";
  String tokenid = "";
  String bio = "";
  bool? verified = false;
  int limit = 3;
  List followers = [];
  List following = [];
  List chats = [];
  String status = '';

  final scroll_controller = ScrollController();

  Stream<QuerySnapshot<Object?>>? yourStream;
  Stream<QuerySnapshot<Object?>>? adoptStream;
  @override
  void initState() {
    userinfo() async {
      final user = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.id)
          .get()
          .then((value) {
        setState(() {
          userphoto = value.data()!['photo'];
          uid = value.data()!['uid'];
          username = value.data()!['name'];
          useremail = value.data()!['email'];
          bio = value.data()!['bio'];
          tokenid = value.data()!['tokenid'];
          verified = value.data()!['verified'];
          followers = value.data()!['followers'];
          following = value.data()!['following'];
          status = value.data()!['status'];
          chats = value.data()!['chats'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      final user2 = await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          username2 = value.data()!['name'];
          userphoto2 = value.data()!['photo'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    userinfo();
    yourStream = FirebaseFirestore.instance
        .collection('Posts')
        .where('uid', isEqualTo: widget.id)
        .snapshots();
    adoptStream = FirebaseFirestore.instance
        .collection('Adopt')
        .where('uid', isEqualTo: widget.id)
        .snapshots();
    scroll_controller.addListener(() {
      if (scroll_controller.position.atEdge) {
        bool isTop = scroll_controller.position.pixels == 0;
        if (isTop) {
          print('At the top');
        } else {
          setState(() {
            limit = limit + 3;
            //FirebaseFirestore.instance
            //    .collection('Posts')
            //    .where(
            //     'uid',
            //      isEqualTo: widget.id,
            //   )
            //   .snapshots();
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userinfo() async {
      final user = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.id)
          .get()
          .then((value) {
        setState(() {
          userphoto = value.data()!['photo'];
          uid = value.data()!['uid'];
          username = value.data()!['name'];
          bio = value.data()!['bio'];
          useremail = value.data()!['email'];
          tokenid = value.data()!['tokenid'];
          verified = value.data()!['verified'];
          followers = value.data()!['followers'];
          following = value.data()!['following'];

          chats = value.data()!['chats'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showMaterialModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    padding: EdgeInsets.all(15),
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Column(
                      children: [
                        ListTile(
                          trailing: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          title: Text(
                            'Report User',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GroupButton(
                            groupingType: GroupingType.wrap,
                            isRadio: true,
                            controller: category_controller,
                            mainGroupAlignment: MainGroupAlignment.spaceEvenly,
                            borderRadius: BorderRadius.circular(20),
                            unselectedTextStyle: TextStyle(color: Colors.grey),
                            selectedColor: Colors.grey,
                            selectedTextStyle: TextStyle(color: Colors.white),
                            unselectedBorderColor: Colors.grey,
                            spacing: 8,
                            onSelected: (index, isSelected) async {
                              final id = new DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              await FirebaseFirestore.instance
                                  .collection('Report')
                                  .doc(id.toString())
                                  .set({
                                'id': auth.currentUser!.uid.toString(),
                                'reportuser': widget.id,
                                'report': index.toString()
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text('Report Send !')));
                              Navigator.of(context).pop();
                            },
                            buttons: [
                              "It's spam",
                              "Nudity or sexual activity",
                              "Sale of illegal or regulated goods",
                              "Scam or fraud",
                              "I just don't like it",
                              'False information',
                              'Sexual content ',
                              'Harful or dangerous acts',
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              iconSize: 25,
              color: Color(0xffF75950),
              icon: Icon(Icons.report_gmailerrorred)),
        ],
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              username,
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Visibility(
                visible: verified!,
                child: Icon(
                  Icons.verified,
                  color: Colors.green, //Color(0xFFE25E31),
                  size: 20,
                )),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          controller: scroll_controller,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              children: [
                                AvatarGlow(
                                  glowColor: status == "Online"
                                      ? Colors.green
                                      : Colors.grey,
                                  endRadius: 60.0,
                                  duration: Duration(milliseconds: 2000),
                                  repeat: true,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(80),
                                      child: Hero(
                                        tag: widget.id,
                                        child: Image.network(
                                          userphoto,
                                          fit: BoxFit.cover,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                        ),
                                      )),
                                ),
                                Text(
                                  username.length > 12
                                      ? "${username.substring(0, 12)}.."
                                      : username,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xff3B3B3B),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width / 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                        context: context,
                                        builder: (context) => SpinKitCircle(
                                              color: Colors
                                                  .white, //Color(0xffE25E31),
                                              size: 50.0,
                                            ));
                                    if (followers
                                            .contains(auth.currentUser!.uid) ==
                                        true) {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(widget.id)
                                          .update({
                                        "followers": FieldValue.arrayRemove(
                                            [auth.currentUser!.uid])
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(auth.currentUser!.uid)
                                          .update({
                                        "following":
                                            FieldValue.arrayRemove([widget.id])
                                      });
                                      sendNotification(
                                          [tokenid],
                                          "Started following you",
                                          "$username",
                                          '');
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(widget.id)
                                          .update({
                                        "followers": FieldValue.arrayUnion(
                                            [auth.currentUser!.uid])
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(auth.currentUser!.uid)
                                          .update({
                                        "following":
                                            FieldValue.arrayUnion([widget.id])
                                      });
                                    }
                                    userinfo();
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFF58524),
                                            const Color(0xFFF92B7F),
                                          ],
                                          begin:
                                              const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(1.0, 0.0),
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            followers.contains(
                                                    auth.currentUser!.uid)
                                                ? "Following"
                                                : "Follow",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Icon(
                                              followers.contains(
                                                      auth.currentUser!.uid)
                                                  ? Icons.task_alt
                                                  : Icons.person_add,
                                              color: Colors.white)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                        context: context,
                                        builder: (context) => SpinKitCircle(
                                              color: Colors
                                                  .white, //Color(0xffE25E31),
                                              size: 50.0,
                                            ));

                                    final id = new DateTime.now()
                                        .millisecondsSinceEpoch;
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(widget.id)
                                        .collection("Chats")
                                        .doc(auth.currentUser!.uid)
                                        .set({
                                      'id': auth.currentUser!.uid.toString(),
                                      'name': username2,
                                      'photo': userphoto2,
                                      'msg': "",
                                      'seen': true,
                                      'email':
                                          auth.currentUser!.email.toString(),
                                      'time': id.toString(),
                                      'status': ''
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
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => Chats(
                                                  id: uid.toString(),
                                                  useremail: useremail!,
                                                  username: username,
                                                  userphoto: userphoto,
                                                )));
                                  },
                                  child: Container(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFF58524),
                                            const Color(0xFFF92B7F),
                                          ],
                                          begin:
                                              const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(1.0, 0.0),
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Chat",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Icon(Icons.chat_outlined,
                                              color: Colors.white)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Text(
                      "'${bio.toString()}'",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Follow(
                                        users: following,
                                        follow: 'Following',
                                      )));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  following.length.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xffF75950),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Following",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "0",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xffF75950),
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "Pet's",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Follow(
                                        users: followers,
                                        follow: 'Followers',
                                      )));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  followers.length.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xffF75950),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Followers",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        pageselected = 0;
                      });
                    },
                    icon: Icon(
                      Icons.collections,
                      color:
                          pageselected == 0 ? Color(0xffF75950) : Colors.grey,
                    )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        pageselected = 1;
                      });
                    },
                    icon: Icon(
                      Icons.pets,
                      color:
                          pageselected == 1 ? Color(0xffF75950) : Colors.grey,
                    )),
              ]),
              Divider(),
              SizedBox(
                child: pageselected == 0 ? userpost() : useradopt(),
              ),
              /*  StreamBuilder(
                  stream: yourStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (_, i) {
                          final delay = (i * 300);
                          return Container();
                        },
                        itemCount: 2,
                        separatorBuilder: (_, __) => SizedBox(
                          height: 16,
                        ),
                      );
                    }

                    return GridView.count(
                      padding: EdgeInsets.all(5),
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      shrinkWrap: true,
                      controller: scroll_controller,
                      physics: BouncingScrollPhysics(),
                      children: snapshot.data!.docs.map((document) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Posts(id: widget.id)));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                document['post'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),*/
            ],
          ),
        ),
      ),
    );
  }

  SizedBox useradopt() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.8,
      child: StreamBuilder(
          stream: adoptStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: ListView.separated(
                  itemBuilder: (_, i) {
                    final delay = (i * 300);
                    return Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        // margin: EdgeInsets.symmetric(horizontal: 16),
                        // padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FadeShimmer(
                                height: 100,
                                width: MediaQuery.of(context).size.width / 3,
                                radius: 12,
                                millisecondsDelay: delay,
                                highlightColor: Colors.grey[200],
                                baseColor: Colors.grey[500]),
                            SizedBox(
                              height: 100,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  FadeShimmer(
                                      height: 10,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      radius: 12,
                                      millisecondsDelay: delay,
                                      highlightColor: Colors.grey[200],
                                      baseColor: Colors.grey[500]),
                                  FadeShimmer(
                                      height: 10,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      radius: 12,
                                      millisecondsDelay: delay,
                                      highlightColor: Colors.grey[200],
                                      baseColor: Colors.grey[500]),
                                  FadeShimmer(
                                      height: 10,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      radius: 12,
                                      millisecondsDelay: delay,
                                      highlightColor: Colors.grey[200],
                                      baseColor: Colors.grey[500]),
                                ],
                              ),
                            )
                          ],
                        ));
                  },
                  itemCount: 6,
                  separatorBuilder: (_, __) => SizedBox(
                    height: 16,
                  ),
                ),
              );
            }

            return ListView(
              physics: BouncingScrollPhysics(),
              children: snapshot.data!.docs.map((document) {
                final Distance distance = new Distance();

                return Visibility(
                  visible: true,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Adopt(
                                age: document['age'],
                                id: document['id'],
                                lan: document['lan'],
                                lon: document['lon'],
                                more: document['text'],
                                photo: document['photo'],
                                sex: document['sex'],
                                uid: document['uid'],
                                name: document['name'],
                                price: document['price'],
                              )));
                    },
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(2),
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                    color: Colors.grey)
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Hero(
                                  tag: document['photo'],
                                  child: Image.network(
                                    document['photo'],
                                    fit: BoxFit.cover,
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    height:
                                        MediaQuery.of(context).size.width / 3,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.width / 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        document['name'].toString().length >= 14
                                            ? "${document['name'].toString().substring(0, 10)}..."
                                            : document['name'],
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xff3B3B3B),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.7,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffffe8ea),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8),
                                                child: Text(
                                                  document['sex'],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xffF75950),
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffcfd5e6),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    document['age'],
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xff1c3c87),
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.room,
                                              color: Colors.grey, size: 14),
                                          Text(
                                            document['location']
                                                        .toString()
                                                        .length >=
                                                    15
                                                ? "${document['location'].toString().substring(0, 12)}..."
                                                : "${document['location'].toString()}..",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "(${distance.as(LengthUnit.Kilometer, LatLng(double.parse(document['lan'].toString()), double.parse(document['lon'].toString())), LatLng(double.parse(widget.lan.toString()), double.parse(widget.lon.toString()))).toString()} km)",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            document['price'],
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff1c3c87),
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> userpost() {
    return StreamBuilder(
        stream: yourStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return ListView.separated(
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (_, i) {
                final delay = (i * 300);
                return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    // margin: EdgeInsets.symmetric(horizontal: 16),
                    // padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: FadeShimmer.round(
                              size: 40,
                              millisecondsDelay: delay,
                              highlightColor: Colors.grey[200],
                              baseColor: Colors.grey[500]),
                          subtitle: FadeShimmer(
                            height: 8,
                            millisecondsDelay: delay,
                            width: 30,
                            radius: 4,
                            highlightColor: Colors.grey[200],
                            baseColor: Colors.grey[500],
                          ),
                          title: FadeShimmer(
                              height: 8,
                              width: 150,
                              radius: 4,
                              millisecondsDelay: delay,
                              highlightColor: Colors.grey[200],
                              baseColor: Colors.grey[500]),
                          trailing: FadeShimmer.round(
                              size: 40,
                              millisecondsDelay: delay,
                              highlightColor: Colors.grey[200],
                              baseColor: Colors.grey[500]),
                        ),
                        FadeShimmer(
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                            radius: 4,
                            millisecondsDelay: delay,
                            highlightColor: Colors.grey[200],
                            baseColor: Colors.grey[500]),
                        SizedBox(
                          height: 30,
                        ),
                        FadeShimmer(
                            height: 10,
                            width: MediaQuery.of(context).size.width / 1.2,
                            radius: 4,
                            millisecondsDelay: delay,
                            highlightColor: Colors.grey[200],
                            baseColor: Colors.grey[500]),
                        SizedBox(
                          height: 10,
                        ),
                        FadeShimmer(
                            height: 10,
                            width: MediaQuery.of(context).size.width / 1.2,
                            radius: 4,
                            millisecondsDelay: delay,
                            highlightColor: Colors.grey[200],
                            baseColor: Colors.grey[500]),
                      ],
                    ));
              },
              itemCount: 2,
              separatorBuilder: (_, __) => SizedBox(
                height: 16,
              ),
            );
          }

          return ListView(
            shrinkWrap: true,
            reverse: true,
            physics: BouncingScrollPhysics(),
            children: snapshot.data!.docs.map((document) {
              List likelist = [];
              bool isliked;
              int likecount;
              likelist = (document['likes']);
              isliked = likelist.toList().contains(uid);
              likecount = likelist.length;
              String tokenid = "";
              bool verified = document['verified'];

              Future<bool> onLikeButtonTapped(bool isLiked) async {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(document['uid'].toString())
                    .get()
                    .then((value) {
                  setState(() {
                    tokenid = value.data()!['tokenid'];
                  });
                });
                if (likelist.length != 0) {
                  if (isliked == true) {
                    FirebaseFirestore.instance
                        .collection('Posts')
                        .doc(document['id'])
                        .update({
                      "likes": FieldValue.arrayRemove([uid])
                    });
                  } else {
                    FirebaseFirestore.instance
                        .collection('Posts')
                        .doc(document['id'])
                        .update({
                      "likes": FieldValue.arrayUnion([uid])
                    });

                    sendNotification([tokenid], "$username  liked your post",
                        "Someone liked your post", document['post']);
                  }
                } else {
                  FirebaseFirestore.instance
                      .collection('Posts')
                      .doc(document['id'])
                      .update({
                    "likes": FieldValue.arrayUnion([uid])
                  });

                  sendNotification([tokenid], "$username  liked your post",
                      "Someone liked your post", document['post']);
                }
                return !isLiked;
              }

              return Container(
                  child: Column(
                children: [
                  ListTile(
                      leading: GestureDetector(
                        onTap: () {},
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
                              document['photo'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Text(
                              document['name'],
                              style: TextStyle(
                                  fontSize: 18,
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
                      subtitle: TimeStampTimeAgo(
                        textFontSize: 10,
                        textColor: Colors.grey,
                        timeStampData: DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['id'])),
                      ),
                      trailing: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xffffe8ea)),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: IconButton(
                            onPressed: () {
                              Share.share("https://petlify.page.link/p");
                            },
                            iconSize: 18,
                            color: Color(0xffF75950),
                            icon: Icon(Icons.reply),
                          ),
                        ),
                      )),
                  ConstrainedBox(
                    constraints: new BoxConstraints(
                      minHeight: 200.0,
                      // maxHeight: MediaQuery.of(context).size.height
                    ),
                    child: Container(
                      color: Colors.grey[200],
                      child: document['type'] == "image"
                          ? Image.network(
                              document['post'],
                              fit: BoxFit.cover,
                            )
                          : FlickVideoPlayer(
                              flickManager: FlickManager(
                                videoPlayerController:
                                    VideoPlayerController.network(
                                        document['post']),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            LikeButton(
                              onTap: onLikeButtonTapped,
                              size: 30,
                              circleColor: CircleColor(
                                  start: Color(0xFFF58524),
                                  end: Color(0xFFF92B7F)),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: Color(0xFFF58524),
                                dotSecondaryColor: Color(0xFFF92B7F),
                              ),
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  isliked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isliked
                                      ? Color(0xFFE25E31)
                                      : Color(0xFFE25E31),
                                  size: 28,
                                );
                              },
                              likeCount: likecount,
                              circleSize: 15,
                              countBuilder: (count, bool isLiked, String text) {
                                var color = isLiked ? Colors.grey : Colors.grey;
                                Widget result;
                                if (count == 0) {
                                  result = Text(
                                    "0",
                                    style: TextStyle(color: color),
                                  );
                                } else
                                  result = Text(
                                    text,
                                    style: TextStyle(color: color),
                                  );
                                return result;
                              },
                            ),
                            Text(
                              "  Likes",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Row(
                          children: [
                            LikeButton(
                              onTap: (isLiked) async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Snaps(
                                          id: document['id'],
                                          uid: document['uid'],
                                        )));
                              },
                              size: 30,
                              circleColor: CircleColor(
                                  start: Color(0xFFF58524),
                                  end: Color(0xFFF92B7F)),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: Color(0xFFF58524),
                                dotSecondaryColor: Color(0xFFF92B7F),
                              ),
                              likeBuilder: (bool isLiked) {
                                return Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Image.network(
                                    'https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641648989/Pet%20Life/Data/Group_33_mg2bfn.png',
                                    fit: BoxFit.contain,
                                    width: 10,
                                    height: 10,
                                  ),
                                );
                              },
                              likeCount: int.parse(document['snaps']),
                              circleSize: 15,
                              countBuilder: (count, bool isLiked, String text) {
                                var color = isLiked ? Colors.grey : Colors.grey;
                                Widget result;
                                if (count == 0) {
                                  result = Text(
                                    "0",
                                    style: TextStyle(color: color),
                                  );
                                } else
                                  result = Text(
                                    text,
                                    style: TextStyle(color: color),
                                  );
                                return result;
                              },
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "  Snaps",
                                style:
                                    TextStyle(fontSize: 15, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ReadMoreText(
                        document['text'],
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        lessStyle: TextStyle(
                            color: Color(0xffF75950),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                        colorClickableText: Colors.pink,
                        trimCollapsedText: 'Show more',
                        trimExpandedText: 'Show less',
                        moreStyle: TextStyle(
                            color: Color(0xffF75950),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ));
            }).toList(),
          );
        });
  }
}
