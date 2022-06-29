import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditPost extends StatefulWidget {
  final id;
  final post;
  final text;
  const EditPost(
      {Key? key, required this.id, required this.post, required this.text})
      : super(key: key);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final auth = FirebaseAuth.instance;
  String username = "User name";
  final post_text = TextEditingController();
  bool verified = false;
  String userphoto =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
  @override
  void initState() {
    setState(() {
      post_text.text = widget.text;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userinfo() async {
      final user = await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          userphoto = value.data()!['photo'];
          username = value.data()!['name'];
          verified = value.data()!['verified'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    userinfo();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.5,
          title: Text(
            "Edit Post",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () async {
                  FirebaseFirestore firebaseFirestore =
                      FirebaseFirestore.instance;
                  await firebaseFirestore
                      .collection("Posts")
                      .doc(widget.id)
                      .update({'text': post_text.text});

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.green, content: Text("Updated")));
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Update",
                  style: TextStyle(fontSize: 16, color: Color(0xffF75950)),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            )
          ]),
      body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
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
                  child: Hero(
                    tag: widget.id,
                    child: Image.network(
                      userphoto,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  username,
                  style: TextStyle(fontSize: 20, color: Colors.black),
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
          SizedBox(
            height: 10,
          ),
          ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 200.0,
            ),
            child: Image.network(
              widget.post,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8),
            child: TextFormField(
              autofocus: true,
              scrollPhysics: BouncingScrollPhysics(),
              cursorColor: Color(0xff707070),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              controller: post_text,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
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
          SizedBox(
            height: 50,
          ),
        ],
      ))),
    );
  }
}
