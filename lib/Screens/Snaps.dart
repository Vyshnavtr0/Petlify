import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petlify/Models/SnapsModel.dart';
import 'package:petlify/Screens/Account.dart';
import 'package:petlify/Screens/MyProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'dart:math' as math;
import 'package:readmore/readmore.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:timestamp_time_ago/timestamp_time_ago.dart';

class Snaps extends StatefulWidget {
  final String id;
  final String uid;
  const Snaps({Key? key, required this.id, required this.uid})
      : super(key: key);

  @override
  _SnapsState createState() => _SnapsState();
}

class _SnapsState extends State<Snaps> {
  final snap_controller = TextEditingController();
  final snap_edit_controller = TextEditingController();
  final auth = FirebaseAuth.instance;
  String userphoto =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
  String username = "username";
  String? snapcount;
  int limit = 10;
  String lan = "";
  String lon = "";
  bool scroll_loading = false;
  String tokenid = "";
  final scroll_controller = ScrollController();
  Stream<QuerySnapshot<Object?>>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.id)
        .collection("Snaps")
        .limit(limit)
        .orderBy('id', descending: true)
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
          lan = value.data()!['lan'];
          lon = value.data()!['lon'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      final owner = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .get()
          .then((value) {
        setState(() {
          tokenid = value.data()!['tokenid'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      final snapscount = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.id)
          .get()
          .then((value) {
        setState(() {
          snapcount = value.data()!['snaps'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    loading() async {
      if (scroll_loading == true) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          scroll_loading = false;
        });
      }
    }

    scroll_controller.addListener(() {
      if (scroll_controller.position.atEdge) {
        bool isTop = scroll_controller.position.pixels == 0;
        if (isTop) {
          print('At the top');
        } else {
          setState(() {
            scroll_loading = true;
            limit = limit + 8;
            yourStream = FirebaseFirestore.instance
                .collection('Posts')
                .doc(widget.id)
                .collection("Snaps")
                .limit(limit)
                .orderBy('id', descending: true)
                .snapshots();
            loading();
          });
        }
      }
    });
    userinfo();
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        actions: [],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
        title: Text(
          "Snaps",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          reverse: false,
          child: Container(
            child: Column(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height / 1.25,
                    child: StreamBuilder(
                        stream: yourStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapcount == "0") {
                            return Center(
                              child: Text(
                                "No Snaps !",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xff3B3B3B),
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          }
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

                          return Stack(
                            children: [
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
                              ListView(
                                  controller: scroll_controller,
                                  physics: BouncingScrollPhysics(),
                                  children: snapshot.data!.docs.map((document) {
                                    Map<String, dynamic> data = document.data()!
                                        as Map<String, dynamic>;

                                    return ListTile(
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                        child: Text(
                                          document['name'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xff3B3B3B),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TimeStampTimeAgo(
                                            textFontSize: 10,
                                            textColor: Colors.grey,
                                            timeStampData: DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    int.parse(document['id'])),
                                          ),
                                          Visibility(
                                            visible: document['uid'] ==
                                                    auth.currentUser!.uid
                                                ? true
                                                : false,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Color(0xffffe8ea)),
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    snap_edit_controller.text =
                                                        document['snap'];
                                                  });

                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder:
                                                          (context) =>
                                                              AlertDialog(
                                                                actions: [
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        1.1,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                MediaQuery.of(context).size.width / 3.2,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.black),
                                                                              borderRadius: BorderRadius.circular(7),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    "Cancel",
                                                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff3B3B3B)),
                                                                                  ),
                                                                                  Icon(Icons.close, color: Color(0xff3B3B3B))
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            FirebaseFirestore
                                                                                firebaseFirestore =
                                                                                FirebaseFirestore.instance;
                                                                            firebaseFirestore.collection('Posts').doc(widget.id).collection('Snaps').doc(document['id'].toString()).update({
                                                                              'snap': snap_edit_controller.text
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                backgroundColor: Colors.green,
                                                                                content: Text("Snap edited ")));
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                MediaQuery.of(context).size.width / 3.2,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(7),
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
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    "Update",
                                                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                  ),
                                                                                  Icon(Icons.update, color: Colors.white)
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                                title: ListTile(
                                                                  trailing:
                                                                      Container(
                                                                    width: 35,
                                                                    height: 35,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                20),
                                                                        color: Color(
                                                                            0xffffe8ea)),
                                                                    child:
                                                                        IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (context) =>
                                                                                AlertDialog(
                                                                                  title: Text('Do you want to delete the snap ?'),
                                                                                  content: Text('Are you sure you want to completely delete your snap ? Tis action canot be undone.', style: TextStyle(color: Colors.grey)),
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
                                                                                          Navigator.of(context).pop();
                                                                                          FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
                                                                                          firebaseFirestore.collection('Posts').doc(widget.id).collection('Snaps').doc(document['id'].toString()).delete();
                                                                                          setState(() {
                                                                                            int count = int.parse(snapcount!);
                                                                                            count--;
                                                                                            snapcount = count.toString();
                                                                                          });
                                                                                          FirebaseFirestore.instance.collection('Posts').doc(widget.id).update({
                                                                                            'snaps': snapcount
                                                                                          });

                                                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Snap deleted ")));
                                                                                        },
                                                                                        child: Text(
                                                                                          'Yes',
                                                                                          style: TextStyle(color: Color(0xff075E54)),
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ));
                                                                      },
                                                                      iconSize:
                                                                          18,
                                                                      color: Color(
                                                                          0xffF75950),
                                                                      icon: Icon(
                                                                          Icons
                                                                              .delete),
                                                                    ),
                                                                  ),
                                                                  title: Text(
                                                                    "Edit Snap",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Color(
                                                                            0xff3B3B3B),
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20.0))),
                                                                content:
                                                                    TextFormField(
                                                                  autofocus:
                                                                      true,
                                                                  scrollPhysics:
                                                                      BouncingScrollPhysics(),
                                                                  cursorColor:
                                                                      Color(
                                                                          0xff707070),
                                                                  maxLines: 5,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .multiline,
                                                                  minLines: 1,
                                                                  controller:
                                                                      snap_edit_controller,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18.0,
                                                                      color: Colors
                                                                          .black),
                                                                  textInputAction:
                                                                      TextInputAction
                                                                          .newline,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    focusColor:
                                                                        Color(
                                                                            0xffE25E31),
                                                                    enabledBorder:
                                                                        UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.white),
                                                                    ),
                                                                    focusedBorder:
                                                                        UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.white),
                                                                    ),
                                                                    hintText:
                                                                        "Snap something here...",
                                                                  ),
                                                                ),
                                                              ));
                                                },
                                                iconSize: 15,
                                                color: Color(0xffF75950),
                                                icon: Icon(Icons.edit),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: ReadMoreText(
                                        document['snap'],
                                        trimLines: 2,
                                        trimMode: TrimMode.Line,
                                        lessStyle: TextStyle(
                                            color: Color(0xffF75950),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                        colorClickableText: Colors.pink,
                                        trimCollapsedText: 'Show more',
                                        trimExpandedText: 'Show less',
                                        moreStyle: TextStyle(
                                            color: Color(0xffF75950),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  }).toList()),
                            ],
                          );
                        })),
                Container(
                  padding: EdgeInsets.all(9),
                  child: TextFormField(
                    scrollPhysics: BouncingScrollPhysics(),
                    cursorColor: Color(0xff707070),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    controller: snap_controller,
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.network(
                          "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641732448/Pet%20Life/Data/Group_33_wbwp2s.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                      focusColor: Color(0xffE25E31),
                      suffixIcon: Transform.rotate(
                        angle: 110 * math.pi / 60,
                        child: IconButton(
                          onPressed: () async {
                            if (snap_controller.text.isNotEmpty) {
                              FirebaseFirestore firebaseFirestore =
                                  FirebaseFirestore.instance;

                              final id =
                                  new DateTime.now().millisecondsSinceEpoch;

                              SnapModel snapModel = SnapModel();
                              snapModel.id = id.toString();
                              snapModel.snap = snap_controller.text;
                              snapModel.name = username;
                              snapModel.photo = userphoto;
                              snapModel.uid = auth.currentUser!.uid;
                              snap_controller.clear();
                              await firebaseFirestore
                                  .collection('Posts')
                                  .doc(widget.id)
                                  .collection('Snaps')
                                  .doc(id.toString())
                                  .set(snapModel.toMap());

                              setState(() {
                                int count = int.parse(snapcount!);
                                count++;
                                snapcount = count.toString();
                              });

                              FirebaseFirestore.instance
                                  .collection('Posts')
                                  .doc(widget.id)
                                  .update({'snaps': snapcount});

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text("Snap added ")));
                              sendNotification(
                                  [tokenid],
                                  snapModel.snap.toString(),
                                  "$username snapped on your post.",
                                  "");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration: Duration(milliseconds: 300),
                                      backgroundColor: Colors.red,
                                      content: Text("Please Snap Somthing !")));
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Color(0xffE25E31),
                          ),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintText: "Snap something here...",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
