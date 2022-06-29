import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petlify/Screens/Account.dart';
import 'package:petlify/Screens/MyProfile.dart';

class Follow extends StatefulWidget {
  final List users;
  final String follow;
  const Follow({Key? key, required this.users, required this.follow})
      : super(key: key);

  @override
  _FollowState createState() => _FollowState();
}

class _FollowState extends State<Follow> {
  List<String> photos = [];
  List names = [];
  List<List> followers = [];
  int len = 0;
  String lan = "";
  String lon = "";
  final auth = FirebaseAuth.instance;
  bool load = false;
  users() async {
    for (int i = 0; len >= i; i++) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.users[i].toString())
          .get()
          .then((value) {
        setState(() {
          photos.add(value.data()!['photo'].toString());
          names.add(value.data()!['name'].toString());
          followers.add(value.data()!['followers']);
          lan = value.data()!['lan'];
          lon = value.data()!['lon'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      if (len == 1) {
        setState(() {
          load = true;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    users();
    setState(() {
      len = widget.users.length;
    });

    super.initState();
  }

  Widget build(BuildContext context) {
    // users();
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
          SizedBox(
            width: 10,
          )
        ],
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
        title: Text(
          widget.follow.toString(),
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      body: load == true
          ? ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: len,
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                //  users();

                if (index >= len) {
                  return const Offstage();
                } else {
                  return ListTile(
                    onTap: () {
                      if (widget.users[index] == auth.currentUser!.uid) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MyProfile(),
                        ));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Profile(
                            id: widget.users[index].toString(),
                            lan: lan,
                            lon: lon,
                          ),
                        ));
                      }
                    },
                    leading: GestureDetector(
                      onTap: () {
                        if (widget.users[index] == auth.currentUser!.uid) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyProfile(),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Profile(
                              id: widget.users[index].toString(),
                              lan: lan,
                              lon: lon,
                            ),
                          ));
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
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
                          child: Hero(
                            tag: widget.users[index],
                            child: Image.network(
                              photos[index].toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    title: GestureDetector(
                      onTap: () {
                        if (widget.users[index] == auth.currentUser!.uid) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyProfile(),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Profile(
                              id: widget.users[index].toString(),
                              lan: lan,
                              lon: lon,
                            ),
                          ));
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            names[index].toString(),
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff3B3B3B),
                                fontWeight: FontWeight.w500),
                          ),
                          Visibility(
                              visible: false,
                              child: Icon(
                                Icons.verified,
                                color: Colors.green, //Color(0xFFE25E31),
                                size: 20,
                              )),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      "${followers[index].length} Followers",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  );
                }
              }))
          : ListView.separated(
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
}
