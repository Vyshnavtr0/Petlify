import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petlify/Screens/Account.dart';
import 'package:petlify/Screens/MyProfile.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final search_controller = TextEditingController();
  final auth = FirebaseAuth.instance;
  final scroll_controller = ScrollController();
  int limit = 10;
  Stream<QuerySnapshot<Object?>>? yourStream;
  String lan = "";
  String lon = "";
  @override
  void initState() {
    // TODO: implement initState

    yourStream = FirebaseFirestore.instance
        .collection('Users')
        .orderBy('followers', descending: true)
        .limit(limit)
        //.where("name", isGreaterThanOrEqualTo: search)
        //.where("name", isLessThan: search + 'z')
        .snapshots();
    final user = FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        lan = value.data()!['lan'];
        lon = value.data()!['lon'];
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: TextField(
          keyboardType: TextInputType.text,
          cursorColor: Colors.black,
          controller: search_controller,
          //autofocus: true,
          onChanged: (search) async {
            //print(search);

            yourStream = await FirebaseFirestore.instance
                .collection('Users')
                .orderBy('search')
                .startAt([search]).endAt([search + '\uf8ff'])
                //.where("name", isGreaterThanOrEqualTo: search)
                //.where("name", isLessThan: search + 'z')
                .snapshots();
            setState(() {});
          },
          onSubmitted: (search) {},
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            hintText: "Search",
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.grey),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              search_controller.clear();
            },
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Users(),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> Users() {
    return StreamBuilder(
      stream: yourStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          controller: scroll_controller,
          physics: BouncingScrollPhysics(),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return ListTile(
              onTap: () {
                if (document['uid'] == auth.currentUser!.uid) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MyProfile(),
                  ));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Profile(
                      id: document['uid'].toString(),
                      lan: lan,
                      lon: lon,
                    ),
                  ));
                }
              },
              leading: GestureDetector(
                onTap: () {
                  if (document['uid'] == auth.currentUser!.uid) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MyProfile(),
                    ));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Profile(
                        id: document['uid'].toString(),
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
                      tag: document['uid'],
                      child: Image.network(
                        document['photo'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              title: GestureDetector(
                onTap: () {
                  if (document['uid'] == auth.currentUser!.uid) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MyProfile(),
                    ));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
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
                        visible: document['verified'],
                        child: Icon(
                          Icons.verified,
                          color: Colors.green, //Color(0xFFE25E31),
                          size: 20,
                        )),
                  ],
                ),
              ),
              subtitle: Text(
                "${document['followers'].length} Followers",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
