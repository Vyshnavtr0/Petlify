import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_latlong/flutter_latlong.dart';
import 'package:petlify/Screens/Adopt.dart';
import 'package:petlify/Screens/EditAdopt.dart';
import 'package:petlify/Screens/EditPost.dart';
import 'package:petlify/Screens/EditProfile.dart';
import 'package:petlify/Screens/Follow.dart';
import 'package:petlify/Screens/NewAdopt.dart';
import 'package:petlify/Screens/Newpost.dart';
import 'package:petlify/Screens/Snaps.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:like_button/like_button.dart';
import 'package:readmore/readmore.dart';
import 'package:share/share.dart';
import 'dart:math' as math;
import 'package:video_player/video_player.dart';
import "dart:math";

import 'package:timestamp_time_ago/timestamp_time_ago.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final auth = FirebaseAuth.instance;
  String userphoto =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
  int selected = 0;
  String? uid;
  String username = "Username";
  String bio = "";
  bool? verified = false;
  List followers = [];
  List following = [];
  int pageselected = 0;
  String? postdelete;
  String? adoptdelete;
  int limit = 3;
  String lan = "";
  String lon = "";
  final scroll_controller = ScrollController();

  Stream<QuerySnapshot<Object?>>? yourStream;
  Stream<QuerySnapshot<Object?>>? adoptStream;
  @override
  void initState() {
    userinfo() async {
      final user = await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          userphoto = value.data()!['photo'];
          uid = value.data()!['uid'];
          username = value.data()!['name'];
          verified = value.data()!['verified'];
          bio = value.data()!['bio'];
          lan = value.data()!['lan'];
          lon = value.data()!['lon'];
          followers = value.data()!['followers'];
          following = value.data()!['following'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    userinfo();
    yourStream = FirebaseFirestore.instance
        .collection('Posts')
        .where(
          'uid',
          isEqualTo: auth.currentUser!.uid.toString(),
        )
        .snapshots();
    adoptStream = FirebaseFirestore.instance
        .collection('Adopt')
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .snapshots();
    scroll_controller.addListener(() {
      if (scroll_controller.position.atEdge) {
        bool isTop = scroll_controller.position.pixels == 0;
        if (isTop) {
          print('At the top');
        } else {
          setState(() {
            limit = limit + 3;
            yourStream = FirebaseFirestore.instance
                .collection('Posts')
                .where('uid', isEqualTo: auth.currentUser!.uid.toString())
                .snapshots();
          });
        }
      }
    });
    super.initState();
  }

  userinfo() async {
    final user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        userphoto = value.data()!['photo'];
        uid = value.data()!['uid'];
        username = value.data()!['name'];
        verified = value.data()!['verified'];
        followers = value.data()!['followers'];
        following = value.data()!['following'];
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          if (pageselected == 0) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => NewPost()));
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => NewAdopt()));
          }
        },
        backgroundColor: Colors.white,
        child: Container(
          height: 50,
          width: 50,
          child: Icon(
            pageselected == 0 ? Icons.add : Icons.pets,
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
      ),
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
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => EditProfile()));
            },
            iconSize: 25,
            color: Color(0xffF75950),
            icon: Icon(Icons.edit),
          ),
        ],
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
        title: Text(
          "My Profile",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          reverse: false,
          controller: scroll_controller,
          child: Container(
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width / 1.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AvatarGlow(
                            glowColor: Colors.grey,
                            endRadius: 40.0,
                            duration: Duration(milliseconds: 2000),
                            repeat: true,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child: Hero(
                                  tag: "profile",
                                  child: Image.network(
                                    userphoto,
                                    fit: BoxFit.cover,
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                    height:
                                        MediaQuery.of(context).size.width / 6,
                                  ),
                                )),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff3B3B3B),
                                  fontWeight: FontWeight.w500),
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
                        Text(
                          auth.currentUser!.email.toString(),
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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

                        /* Container(
                          padding: EdgeInsets.only(left: 10),
                          width: MediaQuery.of(context).size.width,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Pet Profiles",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white),
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {});
                                        },
                                        iconSize: 23,
                                        color: Color(0xffF75950),
                                        icon: Icon(Icons.add),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
                Divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              pageselected = 0;
                            });
                          },
                          icon: Icon(
                            Icons.collections,
                            color: pageselected == 0
                                ? Color(0xffF75950)
                                : Colors.grey,
                          )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              pageselected = 1;
                            });
                          },
                          icon: Icon(
                            Icons.pets,
                            color: pageselected == 1
                                ? Color(0xffF75950)
                                : Colors.grey,
                          )),
                    ]),
                Divider(),
                //Divider(),
                SizedBox(
                  child: pageselected == 0 ? userpost() : useradopt(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> userpost() {
    return StreamBuilder(
        stream: yourStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container(
              height: MediaQuery.of(context).size.height / 1.5,
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
                itemCount: 1,
                separatorBuilder: (_, __) => SizedBox(
                  height: 16,
                ),
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
              Future<bool> onLikeButtonTapped(bool isLiked) async {
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
                  }
                } else {
                  FirebaseFirestore.instance
                      .collection('Posts')
                      .doc(document['id'])
                      .update({
                    "likes": FieldValue.arrayUnion([uid])
                  });
                }
                return !isLiked;
              }

              return Container(
                  child: Column(
                children: [
                  ListTile(
                      leading: Container(
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
                      title: Text(
                        document['name'].toString().length >= 10
                            ? "${document['name'].toString().substring(0, 10)}..."
                            : document['name'],
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff3B3B3B),
                            fontWeight: FontWeight.w500),
                      ),
                      subtitle: TimeStampTimeAgo(
                        textFontSize: 10,
                        textColor: Colors.grey,
                        timeStampData: DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['id'])),
                      ),
                      trailing: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
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
                            ),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xffffe8ea)),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => EditPost(
                                            id: document['id'],
                                            post: document['post'],
                                            text: document['text'],
                                          )));
                                },
                                iconSize: 18,
                                color: Color(0xffF75950),
                                icon: Icon(Icons.edit),
                              ),
                            ),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xffffe8ea)),
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      postdelete = document['id'];
                                    });

                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text(
                                                  'Do you want to delete the post ?'),
                                              content: Text(
                                                  'Are you sure you want to completely delete your post ? This action canot be undone.',
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                              actions: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      'No',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xff075E54)),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('Posts')
                                                          .doc(postdelete)
                                                          .delete();

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              content: Text(
                                                                  " Deleted ")));
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xff075E54)),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ));
                                  },
                                  iconSize: 18,
                                  color: Color(0xffF75950),
                                  icon: Icon(Icons.delete)),
                            ),
                          ],
                        ),
                      )),
                  ConstrainedBox(
                    constraints: new BoxConstraints(
                      minHeight: 200.0,
                    ),
                    child: Hero(
                      tag: document['id'],
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
              reverse: true,
              children: snapshot.data!.docs.map((document) {
                final Distance distance = new Distance();

                return Visibility(
                  visible: true,
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
                            GestureDetector(
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
                              child: ClipRRect(
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  IgnorePointer(
                                    child: Container(
                                      color: Colors.black.withOpacity(
                                          0.0), // comment or change to transparent color
                                      height: 150.0,
                                      width: 150.0,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xffffe8ea)),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditAdopt(
                                                        age: document['age'],
                                                        id: document['id'],
                                                        lan: document['lan'],
                                                        lon: document['lon'],
                                                        more: document['text'],
                                                        location: document[
                                                            'location'],
                                                        photo:
                                                            document['photo'],
                                                        sex: document['sex'],
                                                        uid: document['uid'],
                                                        name: document['name'],
                                                        price:
                                                            document['price'],
                                                        category: document[
                                                            'category'],
                                                      )));
                                        },
                                        iconSize: 18,
                                        color: Color(0xffF75950),
                                        icon: Icon(Icons.edit),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 50,
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xffffe8ea)),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            adoptdelete = document['id'];
                                          });

                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title: Text(
                                                        'Do you want to delete this ?'),
                                                    content: Text(
                                                        'Are you sure you want to completely delete your adopt ? This action canot be undone.',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.grey)),
                                                    actions: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text(
                                                            'No',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff075E54)),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: TextButton(
                                                          onPressed: () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Adopt')
                                                                .doc(
                                                                    adoptdelete)
                                                                .delete();

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    content: Text(
                                                                        " Deleted ")));
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text(
                                                            'Yes',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff075E54)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ));
                                        },
                                        iconSize: 18,
                                        color: Color(0xffF75950),
                                        icon: Icon(Icons.delete),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width / 3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          document['name'].toString().length >=
                                                  14
                                              ? "${document['name'].toString().substring(0, 10)}..."
                                              : document['name'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Color(0xff3B3B3B),
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                                  child: Text(
                                                    document['sex'],
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xffF75950),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                              "(${distance.as(LengthUnit.Kilometer, LatLng(double.parse(document['lan'].toString()), double.parse(document['lon'].toString())), LatLng(double.parse(lan.toString()), double.parse(lon.toString()))).toString()} km)",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
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
                                ],
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
                );
              }).toList(),
            );
          }),
    );
  }
}
