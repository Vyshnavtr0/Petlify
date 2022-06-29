import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_latlong/flutter_latlong.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:link_text/link_text.dart';
import 'package:petlify/Screens/Account.dart';
import 'package:petlify/Screens/Adopt.dart';
import 'package:petlify/Screens/Chats.dart';
import 'package:petlify/Screens/EditProfile.dart';
import 'package:petlify/Screens/Login.dart';
import 'package:petlify/Screens/MyProfile.dart';
import 'package:petlify/Screens/NewAdopt.dart';
import 'package:petlify/Screens/Newpost.dart';
import 'package:petlify/Screens/Password.dart';
import 'package:petlify/Screens/Search.dart';
import 'package:petlify/Screens/Snaps.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:group_button/group_button.dart';
import 'package:http/http.dart';
import 'dart:math' as math;
import "dart:math";
import 'package:petlify/Screens/Location.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:share/share.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:timestamp_time_ago/timestamp_time_ago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'Location.dart';

class Home extends StatefulWidget {
  final String random;
  const Home({Key? key, required this.random}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
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
  String username = "";
  String lan = "";
  String location = "";
  String lon = "";
  int selectedindex = 0;
  String category = "All";
  String? uid;
  String? userdelete;
  int limit = 5;
  int adoptlimit = 8;
  bool scroll_loading = false;
  bool scroll_loading2 = false;
  final search_controller = TextEditingController();
  final search_controller2 = TextEditingController();
  int current_index = 0;
  final scroll_controller = ScrollController();
  final adopt_scroll_controller = ScrollController();

  Stream<QuerySnapshot<Object?>>? yourStream;
  Stream<QuerySnapshot<Object?>>? chatStream;
  Stream<QuerySnapshot<Object?>>? adoptStream;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    yourStream = FirebaseFirestore.instance
        .collection('Posts')
        .limit(limit)
        .orderBy(widget.random, descending: true)
        .snapshots();

    chatStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .collection("Chats")
        .orderBy('time', descending: true)
        .snapshots();
    userinfo() async {
      final user = await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          userphoto = value.data()!['photo'];
          username = value.data()!['name'];
          uid = value.data()!['uid'];
          lan = value.data()!['lan'];
          lon = value.data()!['lon'];
          location = value.data()!['location'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      final online = await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .update({"status": "Online"});
    }

    userinfo();
    adoptStream = FirebaseFirestore.instance
        .collection('Adopt')
        .limit(adoptlimit)
        .orderBy("location", descending: true)
        .where("location", isGreaterThanOrEqualTo: location.toString())
        .snapshots();
    loading() async {
      if (scroll_loading == true) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          scroll_loading = false;
        });
      }
    }

    scroll_controller.addListener(() async {
      if (scroll_controller.position.atEdge) {
        bool isTop = scroll_controller.position.pixels == 0;

        if (isTop) {
          print('At the top');
        } else {
          setState(() {
            scroll_loading = true;

            limit = limit + 6;
            yourStream = FirebaseFirestore.instance
                .collection('Posts')
                .limit(limit)
                .orderBy(widget.random, descending: false)
                .snapshots();
            loading();
          });
        }
      }
    });
    loading2() async {
      print("object");
      if (scroll_loading2 == true) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          scroll_loading2 = false;
        });
      }
    }

    adopt_scroll_controller.addListener(() async {
      if (adopt_scroll_controller.position.atEdge) {
        bool isTop = adopt_scroll_controller.position.pixels == 0;

        if (isTop) {
          print('At the top');
        } else {
          setState(() {
            scroll_loading2 = true;
            adoptlimit = adoptlimit + 6;
            adoptStream = FirebaseFirestore.instance
                .collection('Adopt')
                .limit(adoptlimit)
                .orderBy("location", descending: true)
                .where("location", isGreaterThanOrEqualTo: location.toString())
                .snapshots();
            loading2();
          });
        }
      }
    });

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final id = new DateTime.now().millisecondsSinceEpoch.toString();
    if (state == AppLifecycleState.resumed) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .update({"status": "Online"});
    } else {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .update({"status": id.toString()});
    }
    //TODO: set status to offline here in firestore
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      uid = auth.currentUser!.uid.toString();
    });

    return WillPopScope(
      onWillPop: () async {
        bool close = false;
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Exit !"),
                  content: Text('Do you want to close the app ?',
                      style: TextStyle(color: Colors.grey)),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'No',
                          style: TextStyle(color: Color(0xff075E54)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextButton(
                        onPressed: () {
                          SystemNavigator.pop();
                          setState(() {
                            close = true;
                          });
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(color: Color(0xff075E54)),
                        ),
                      ),
                    )
                  ],
                ));
        return close;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: current_index == 0 || current_index == 1
              ? FloatingActionButton.small(
                  onPressed: () {
                    if (current_index == 0) {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => NewPost()));
                    } else {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => NewAdopt()));
                    }
                  },
                  backgroundColor: Colors.white,
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Icon(
                      current_index == 0 ? Icons.add : Icons.pets,
                      size: 30,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
                  ),
                )
              : null,
          bottomNavigationBar: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 10,
            activeColor: Color(0xffF75950),
            iconSize: 24,

            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 200),
            // tabBackgroundColor: Colors.grey[100]!,
            color: Colors.black,
            tabs: const [
              GButton(
                icon: Icons.roofing_outlined,
                text: 'Home',
                iconColor: Colors.grey,
              ),
              GButton(
                icon: Icons.pets_outlined,
                text: 'Adopt',
                iconColor: Colors.grey,
              ),
              GButton(
                icon: Icons.chat_bubble_outline,
                text: 'Chats',
                iconColor: Colors.grey,
              ),
              GButton(
                icon: Icons.settings_outlined,
                text: 'Settings',
                iconColor: Colors.grey,
              ),
            ],
            selectedIndex: 0,
            onTabChange: (index) {
              setState(() {
                current_index = index;
              });
              if (index == 1) {
                if (lan == "") {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => userLocation()));
                }
              }
            },
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.2,
            centerTitle: current_index == 2 ? false : true,
            title: current_index == 0
                ? Image.asset(
                    "assets/images/logoname.png",
                    width: MediaQuery.of(context).size.width / 4,
                    height: MediaQuery.of(context).size.width / 4,
                  )
                : Text(
                    current_index == 2
                        ? "Conversations"
                        : current_index == 1
                            ? "Adopt"
                            : "Settings",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
            leading: current_index == 0 || current_index == 1
                ? GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MyProfile()));
                    },
                    child: AvatarGlow(
                      glowColor: Colors.grey,
                      endRadius: 30.0,
                      duration: Duration(milliseconds: 2000),
                      repeat: true,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
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
                            child: Hero(
                              tag: "profile",
                              child: Image.network(
                                userphoto,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
            actions: [
              Visibility(
                visible: current_index == 0 ? true : false,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Search()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      "assets/images/search.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: current_index == 2 ? true : false,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Search()));
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
                    child: Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 2),
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xffffe8ea),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.add,
                              color: Color(0xffF75950),
                              size: 18,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Add New",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          body: current_index == 0
              ? Home(context)
              : current_index == 1
                  ? Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              "Find a pet to be your friends",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: 16, left: 4, right: 4),
                            child: TextField(
                              cursorColor: Color(0xff707070),
                              controller: search_controller2,
                              onChanged: (search) async {
                                //print(search);

                                if (search == "") {
                                  adoptStream = FirebaseFirestore.instance
                                      .collection('Adopt')
                                      .limit(limit)
                                      .orderBy("location", descending: true)
                                      .where("location",
                                          isGreaterThanOrEqualTo:
                                              location.toString())
                                      .snapshots();
                                } else {
                                  adoptStream = FirebaseFirestore.instance
                                      .collection('Adopt')
                                      .limit(limit)
                                      .orderBy("name", descending: false)
                                      .where("name",
                                          isGreaterThanOrEqualTo: search)
                                      .snapshots();
                                }
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                suffix: GestureDetector(
                                  onTap: () {
                                    search_controller2.clear();
                                    adoptStream = FirebaseFirestore.instance
                                        .collection('Adopt')
                                        .limit(limit)
                                        .orderBy("location", descending: true)
                                        .where("location",
                                            isGreaterThanOrEqualTo:
                                                location.toString())
                                        .snapshots();
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 17,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                hintText: "Search...",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade600),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade100)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade100)),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50,
                            color: Color(0xffffffff),
                            width: MediaQuery.of(context).size.width,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              children: [
                                GroupButton(
                                  groupingType: GroupingType.row,
                                  isRadio: true,
                                  controller: GroupButtonController(
                                      selectedIndex: selectedindex),
                                  mainGroupAlignment:
                                      MainGroupAlignment.spaceEvenly,
                                  borderRadius: BorderRadius.circular(20),
                                  unselectedTextStyle:
                                      TextStyle(color: Color(0xffF75950)),
                                  selectedColor: Color(0xffF75950),
                                  selectedTextStyle:
                                      TextStyle(color: Colors.white),
                                  unselectedBorderColor: Color(0xffF75950),
                                  spacing: 8,
                                  onSelected: (index, isSelected) {
                                    setState(() {
                                      selectedindex = index;
                                    });
                                    if (index == 0) {
                                      setState(() {
                                        category = "All";
                                      });
                                    } else if (index == 1) {
                                      setState(() {
                                        category = "Dog";
                                      });
                                    } else if (index == 2) {
                                      setState(() {
                                        category = "Cat";
                                      });
                                    } else if (index == 3) {
                                      setState(() {
                                        category = "Bird";
                                      });
                                    } else if (index == 4) {
                                      setState(() {
                                        category = "Fish";
                                      });
                                    } else if (index == 5) {
                                      setState(() {
                                        category == "Other";
                                      });
                                    }
                                  },
                                  buttons: [
                                    "🐾 All",
                                    "🐕 Dog",
                                    "🐈 Cat",
                                    "🦜 Bird",
                                    "🐠 Fish",
                                    "🐰 Other",
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 1.8,
                            child: StreamBuilder(
                                stream: adoptStream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container(
                                      child: ListView.separated(
                                        itemBuilder: (_, i) {
                                          final delay = (i * 300);
                                          return Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              // margin: EdgeInsets.symmetric(horizontal: 16),
                                              // padding: EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  FadeShimmer(
                                                      height: 100,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                      radius: 12,
                                                      millisecondsDelay: delay,
                                                      highlightColor:
                                                          Colors.grey[200],
                                                      baseColor:
                                                          Colors.grey[500]),
                                                  SizedBox(
                                                    height: 100,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        FadeShimmer(
                                                            height: 10,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            radius: 12,
                                                            millisecondsDelay:
                                                                delay,
                                                            highlightColor:
                                                                Colors
                                                                    .grey[200],
                                                            baseColor: Colors
                                                                .grey[500]),
                                                        FadeShimmer(
                                                            height: 10,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            radius: 12,
                                                            millisecondsDelay:
                                                                delay,
                                                            highlightColor:
                                                                Colors
                                                                    .grey[200],
                                                            baseColor: Colors
                                                                .grey[500]),
                                                        FadeShimmer(
                                                            height: 10,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            radius: 12,
                                                            millisecondsDelay:
                                                                delay,
                                                            highlightColor:
                                                                Colors
                                                                    .grey[200],
                                                            baseColor: Colors
                                                                .grey[500]),
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

                                  return Stack(
                                    children: [
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        left: 0,
                                        child: Visibility(
                                          visible: true,
                                          child: SpinKitCircle(
                                            color: Color(0xffE25E31),
                                            size: 30.0,
                                          ),
                                        ),
                                      ),
                                      ListView(
                                        physics: BouncingScrollPhysics(),
                                        controller: adopt_scroll_controller,
                                        children:
                                            snapshot.data!.docs.map((document) {
                                          scroll_loading2 = false;
                                          final Distance distance =
                                              new Distance();

                                          return Visibility(
                                            visible: category == "All"
                                                ? true
                                                : category ==
                                                        document['category']
                                                            .toString()
                                                    ? true
                                                    : false,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Adopt(
                                                              age: document[
                                                                  'age'],
                                                              id: document[
                                                                  'id'],
                                                              lan: document[
                                                                  'lan'],
                                                              lon: document[
                                                                  'lon'],
                                                              more: document[
                                                                  'text'],
                                                              photo: document[
                                                                  'photo'],
                                                              sex: document[
                                                                  'sex'],
                                                              uid: document[
                                                                  'uid'],
                                                              name: document[
                                                                  'name'],
                                                              price: document[
                                                                  'price'],
                                                            )));
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    padding: EdgeInsets.all(2),
                                                    margin: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              blurRadius: 5,
                                                              spreadRadius: 1,
                                                              color:
                                                                  Colors.grey)
                                                        ]),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            child: Hero(
                                                              tag: document[
                                                                  'photo'],
                                                              child:
                                                                  Image.network(
                                                                document[
                                                                    'photo'],
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2.5,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                3,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                Text(
                                                                  document['name']
                                                                              .toString()
                                                                              .length >=
                                                                          14
                                                                      ? "${document['name'].toString().substring(0, 10)}..."
                                                                      : document[
                                                                          'name'],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Color(
                                                                          0xff3B3B3B),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.7,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            30,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Color(0xffffe8ea),
                                                                            borderRadius: BorderRadius.circular(20)),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 8),
                                                                          child:
                                                                              Text(
                                                                            document['sex'],
                                                                            style: TextStyle(
                                                                                fontSize: 14,
                                                                                color: Color(0xffF75950),
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            30,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Color(0xffcfd5e6),
                                                                            borderRadius: BorderRadius.circular(20)),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              document['age'],
                                                                              style: TextStyle(fontSize: 14, color: Color(0xff1c3c87), fontWeight: FontWeight.w500),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .room,
                                                                        color: Colors
                                                                            .grey,
                                                                        size:
                                                                            14),
                                                                    Text(
                                                                      document['location'].toString().length >=
                                                                              15
                                                                          ? "${document['location'].toString().substring(0, 12)}..."
                                                                          : "${document['location'].toString()}..",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    Text(
                                                                      "(${distance.as(LengthUnit.Kilometer, LatLng(double.parse(document['lan'].toString()), double.parse(document['lon'].toString())), LatLng(double.parse(lan.toString()), double.parse(lon.toString()))).toString()} km)",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.5,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      document[
                                                                          'price'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color: Color(
                                                                              0xff1c3c87),
                                                                          fontWeight:
                                                                              FontWeight.w500),
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
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ],
                      ),
                    )
                  : current_index == 2
                      ? Chat()
                      : Settings()),
    );
  }

  SafeArea Settings() => SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
            title: Text(
              "Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => EditProfile()));
            },
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Password()));
            },
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text(
              "Change Password",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Other",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              launch(
                  'https://www.freeprivacypolicy.com/live/e5f55e44-63ff-416c-910e-8058204d1bbf');
            },
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () {},
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () {},
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text(
              "About App",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () async {
              final id = new DateTime.now().millisecondsSinceEpoch.toString();
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(auth.currentUser!.uid)
                  .update({"status": id.toString()});
              auth.signOut();

              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Login()));
            },
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text(
              "Logout",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ));

  SafeArea Chat() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: TextField(
              cursorColor: Color(0xff707070),
              controller: search_controller,
              onChanged: (search) async {
                //print(search);

                if (search == "") {
                  chatStream = FirebaseFirestore.instance
                      .collection('Users')
                      .doc(auth.currentUser!.uid)
                      .collection("Chats")
                      .orderBy('time', descending: true)
                      .snapshots();
                } else {
                  chatStream = await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(auth.currentUser!.uid)
                      .collection("Chats")
                      .orderBy('name', descending: false)
                      .startAt([search]).endAt([search + '\uf8ff']).snapshots();
                }
                setState(() {});
              },
              decoration: InputDecoration(
                suffix: GestureDetector(
                  onTap: () {
                    search_controller.clear();
                    chatStream = FirebaseFirestore.instance
                        .collection('Users')
                        .doc(auth.currentUser!.uid)
                        .collection("Chats")
                        .orderBy('time', descending: true)
                        .snapshots();
                    setState(() {});
                  },
                  child: Icon(
                    Icons.close,
                    size: 17,
                    color: Colors.grey.shade600,
                  ),
                ),
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade100)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade100)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.all(8),
              ),
            ),
          ),
          SizedBox(
            height: 1.5,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.37,
            child: StreamBuilder(
              stream: chatStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          child: ListTile(
                            leading: FadeShimmer.round(
                                size: 40,
                                millisecondsDelay: delay,
                                highlightColor: Colors.grey[200],
                                baseColor: Colors.grey[500]),
                            subtitle: FadeShimmer(
                              height: 8,
                              millisecondsDelay: delay,
                              width: 50,
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
                            trailing: FadeShimmer(
                                height: 8,
                                width: 4,
                                radius: 4,
                                millisecondsDelay: delay,
                                highlightColor: Colors.grey[200],
                                baseColor: Colors.grey[500]),
                          ),
                        );
                      },
                      itemCount: 10,
                      separatorBuilder: (_, __) => SizedBox(
                        height: 16,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Something Went Wrong",
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff3B3B3B),
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return ListView(
                  // controller: scroll_controller,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                    return SwipeTo(
                      iconColor: Colors.red,
                      iconOnLeftSwipe: Icons.delete,
                      onLeftSwipe: () {
                        setState(() {
                          userdelete = document['id'];
                        });
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('Delete !'),
                                  content: Text(
                                      'Do you want to delete the user ?',
                                      style: TextStyle(color: Colors.grey)),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              color: Color(0xff075E54)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(auth.currentUser!.uid)
                                              .collection("Chats")
                                              .doc(userdelete)
                                              .delete();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(" Deleted ")));
                                        },
                                        child: Text(
                                          'Yes',
                                          style: TextStyle(
                                              color: Color(0xff075E54)),
                                        ),
                                      ),
                                    )
                                  ],
                                ));
                      },
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Chats(
                                        id: document['id'],
                                        useremail: document['email'],
                                        username: document['name'],
                                        userphoto: document['photo'],
                                      )));
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(auth.currentUser!.uid)
                                  .collection("Chats")
                                  .doc(document['id'])
                                  .update({
                                'seen': true,
                              });
                            },
                            leading: GestureDetector(
                              onTap: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Chats(
                                          id: document['id'],
                                          useremail: document['email'],
                                          username: document['name'],
                                          userphoto: document['photo'],
                                        )));
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(auth.currentUser!.uid)
                                    .collection("Chats")
                                    .doc(document['id'])
                                    .update({
                                  'seen': true,
                                });
                              },
                              child: Container(
                                width: 50,
                                height: 50,
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
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    document['photo'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Chats(
                                          id: document['id'],
                                          useremail: document['email'],
                                          username: document['name'],
                                          userphoto: document['photo'],
                                        )));
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(auth.currentUser!.uid)
                                    .collection("Chats")
                                    .doc(document['id'])
                                    .update({
                                  'seen': true,
                                });
                              },
                              child: Text(
                                document['name'].length > 16
                                    ? "${document['name'].substring(0, 16)}..."
                                    : document['name'],
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xff3B3B3B),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TimeStampTimeAgo(
                                  textFontSize: 10,
                                  textColor: Colors.grey,
                                  timeStampData:
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(document['time'])),
                                ),
                                Visibility(
                                  visible: document['seen'] ? false : true,
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Lottie.asset(
                                      'assets/images/noti.json',
                                      fit: BoxFit.cover,
                                      animate: true,
                                      repeat: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              document['msg'].length > 30
                                  ? "${document['msg'].substring(0, 30)}..."
                                  : document['msg'],
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 1,
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width,
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget Home(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: StreamBuilder(
                stream: yourStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                      width: MediaQuery.of(context).size.width /
                                          1.2,
                                      radius: 4,
                                      millisecondsDelay: delay,
                                      highlightColor: Colors.grey[200],
                                      baseColor: Colors.grey[500]),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FadeShimmer(
                                      height: 10,
                                      width: MediaQuery.of(context).size.width /
                                          1.2,
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
                      ),
                    );
                  }

                  return ListView(
                    controller: scroll_controller,
                    physics: BouncingScrollPhysics(),
                    children: snapshot.data!.docs.map((document) {
                      scroll_loading = false;
                      List likelist = [];
                      bool isliked;
                      int likecount;
                      likelist = (document['likes']);
                      isliked = likelist.toList().contains(uid);
                      likecount = likelist.length;
                      String tokenid = "";
                      bool verified = document['verified'];

                      Future<bool> onLikeButtonTapped(bool isLiked) async {
                        await FirebaseFirestore.instance
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

                            sendNotification(
                                [tokenid],
                                "$username  liked your post",
                                "Someone liked your post",
                                document['post']);
                          }
                        } else {
                          FirebaseFirestore.instance
                              .collection('Posts')
                              .doc(document['id'])
                              .update({
                            "likes": FieldValue.arrayUnion([uid])
                          });

                          sendNotification(
                              [tokenid],
                              "$username  liked your post",
                              "Someone liked your post",
                              document['post']);
                        }
                        return !isLiked;
                      }

                      return Container(
                          child: Column(
                        children: [
                          ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  if (document['uid'] ==
                                      auth.currentUser!.uid) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => MyProfile(),
                                    ));
                                  } else {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => Profile(
                                        id: document['uid'].toString(),
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
                                      document['photo'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              title: GestureDetector(
                                onTap: () {
                                  if (document['uid'] ==
                                      auth.currentUser!.uid) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => MyProfile(),
                                    ));
                                  } else {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => Profile(
                                        id: document['uid'].toString(),
                                        lan: lan,
                                        lon: lon,
                                      ),
                                    ));
                                  }
                                },
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
                                          color:
                                              Colors.green, //Color(0xFFE25E31),
                                          size: 20,
                                        )),
                                  ],
                                ),
                              ),
                              subtitle: TimeStampTimeAgo(
                                textFontSize: 10,
                                textColor: Colors.grey,
                                timeStampData:
                                    DateTime.fromMillisecondsSinceEpoch(
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
                                      Share.share(
                                          "https://petlify.page.link/p");
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
                            child: InteractiveViewer(
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
                                          color: Color(0xFFE25E31),
                                          size: 28,
                                        );
                                      },
                                      likeCount: likecount,
                                      circleSize: 15,
                                      countBuilder:
                                          (count, bool isLiked, String text) {
                                        var color =
                                            isLiked ? Colors.grey : Colors.grey;
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
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey),
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
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
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
                                      countBuilder:
                                          (count, bool isLiked, String text) {
                                        var color =
                                            isLiked ? Colors.grey : Colors.grey;
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
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey),
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
                }),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Visibility(
              visible: scroll_loading,
              child: SpinKitCircle(
                color: Color(0xffE25E31),
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
