import 'dart:convert';
import 'dart:io';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chatbar/chatbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:group_button/group_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_text/link_text.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petlify/Models/ChatModel.dart';
import 'package:petlify/Models/SnapsModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_chat_bar/flutter_chat_bar.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:timestamp_time_ago/timestamp_time_ago.dart';
import 'package:validated/validated.dart' as validator;

class Chats extends StatefulWidget {
  final String id;
  final String userphoto;
  final String? username;
  final String? useremail;

  const Chats({
    Key? key,
    required this.id,
    required this.useremail,
    required this.username,
    required this.userphoto,
  }) : super(key: key);

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final chat_controller = TextEditingController();
  final auth = FirebaseAuth.instance;
  final cloudinary =
      Cloudinary("366248915146297", "BIyUWoSbzvzjy2Xqx73JXnVnWzY", "dvhlfyvrr");
  String userphoto =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
  String username = "username";
  String? snapcount;
  File? image;
  int limit = 10;
  bool verified = false;
  bool upload = false;
  String status = "Online";
  String status2 = "Online";
  String useremail = "";
  String tokenid = "";
  bool reply = false;
  bool sender = false;
  String reply_msg = "";
  final id = new DateTime.now().millisecondsSinceEpoch.toString();
  final focus = FocusNode();
  final scroll_controller = ScrollController();
  bool loading = false;
  Stream<QuerySnapshot<Object?>>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .collection(widget.useremail!)
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
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      final user2 = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.id)
          .get()
          .then((value) {
        setState(() {
          useremail = value.data()!['email'];
          status = value.data()!['status'];
          verified = value.data()!['verified'];
          tokenid = value.data()!['tokenid'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      final statususer = await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .collection("Chats")
          .doc(widget.id)
          .get()
          .then((value) {
        setState(() {
          status2 = value.data()!['status'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    userinfo();
    super.initState();
  }

  @override
  void dispose() {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.id)
        .collection("Chats")
        .doc(auth.currentUser!.uid)
        .update({"status": ""});
    super.dispose();
  }

  @override
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
    showDialog(
        context: context,
        builder: (context) => SpinKitCircle(
              color: Colors.white, //Color(0xffE25E31),
              size: 50.0,
            ));
    final response = await cloudinary.uploadFile(
      filePath: copiedImage.path,
      resourceType: CloudinaryResourceType.image,
      folder: "Petlify/Chat",
    );

    if (response.isSuccessful) {
      setState(() {
        userphoto = response.url!;

        loading = false;
      });
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      final id = new DateTime.now().millisecondsSinceEpoch;

      ChatModel chatModel = ChatModel();
      chatModel.id = id.toString();
      chatModel.chat = userphoto.toString();
      chatModel.sender = true;
      chatModel.type = 'image';
      chatModel.seen = false;
      chatModel.reply = reply;
      chatModel.reply_msg = reply_msg;
      chatModel.reply_to = sender;

      setState(() {
        reply = false;
      });
      await firebaseFirestore
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .collection(widget.useremail!)
          .doc(id.toString())
          .set(chatModel.toMap());
      chatModel.sender = false;
      await firebaseFirestore
          .collection('Users')
          .doc(widget.id)
          .collection(auth.currentUser!.email.toString())
          .doc(id.toString())
          .set(chatModel.toMap());

      if (status != "Online") {
        sendNotification([tokenid], "Image...", "$username", "");
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.id)
            .collection("Chats")
            .doc(auth.currentUser!.uid)
            .update({
          "msg": "Image...",
          'time': id.toString(),
          'seen': false,
        });
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .collection("Chats")
            .doc(widget.id)
            .update({
          "msg": "Image..",
          'time': id.toString(),
          'seen': true,
        });
      }

      //  Reference ref = FirebaseStorage.instance.ref().child("image");
      // ref.putFile(crop);
      Navigator.of(context).pop();
    }
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
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
      final user2 = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.id)
          .get()
          .then((value) {
        setState(() {
          status = value.data()!['status'];
          verified = value.data()!['verified'];
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    CollectionReference reference =
        FirebaseFirestore.instance.collection('Users');
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        userinfo();
        // Do something with change
      });
    });
    typing() async {
      await Future.delayed(Duration(seconds: 1));
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.id)
          .collection("Chats")
          .doc(auth.currentUser!.uid)
          .update({"status": ""});
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatBar(
        height: 55,
        profilePic: Image.network(
          widget.userphoto,
          height: 40,
          width: 40,
          fit: BoxFit.contain,
        ),
        username: widget.username!.length > 12
            ? "${widget.username!.substring(0, 12)}.."
            : widget.username,
        usernamestyle: TextStyle(fontSize: 18, color: Colors.black),
        status: Text(
          status2 != ""
              ? status2
              : status == "Online"
                  ? status
                  : "Seen ${GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch((int.parse(status))))}",
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
        color: Colors.white,
        backbuttoncolor: Colors.white,
        backbutton: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            enabled: true,
            onSelected: (str) async {
              if (str == 'Report') {
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
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(auth.currentUser!.uid)
                                  .collection("Chats")
                                  .doc(widget.id)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text('Report Send !')));
                              Navigator.of(context).pop();
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
              } else {
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(auth.currentUser!.uid)
                    .collection("Chats")
                    .doc(widget.id)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('User Blocked !')));
                Navigator.of(context).pop();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: 'Block',
                child: Text('Block'),
              ),
              const PopupMenuItem<String>(
                value: 'Report',
                child: Text('Report'),
              ),
            ],
          )
        ],
      ),
      /*AppBar(
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
        title: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: Image.network(
                  widget.userphoto,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width / 10,
                  height: MediaQuery.of(context).size.width / 10,
                )),
            SizedBox(
              width: 5,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.username.length > 12
                      ? "${widget.username.substring(0, 12)}.."
                      : widget.username,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  status,
                  style: TextStyle(
                      fontSize: 10,
                      color: status == "Online" ? Colors.green : Colors.red),
                ),
              ],
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
      ),*/
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          reverse: true,
          padding: EdgeInsets.all(10),
          child: Container(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1.25,
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
                        padding: EdgeInsets.all(10),
                        reverse: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          /* Future<void> seen() async {
                            if (document['sender'] == true) {
                              if (document['seen'] == false) {
                                FirebaseFirestore firebaseFirestore =
                                    FirebaseFirestore.instance;
                                await firebaseFirestore
                                    .collection('Users')
                                    .doc(widget.id)
                                    .collection(
                                        auth.currentUser!.email.toString())
                                    .doc(document['id'].toString())
                                    .update({"seen": true});
                              }
                            }
                          }

                          seen();*/
                          return SwipeTo(
                            onRightSwipe: () {
                              focus.requestFocus();

                              setState(() {
                                reply = true;
                                reply_msg = document['type'] == 'text'
                                    ? document['chat']
                                    : 'Image...';
                                sender = document['sender'];
                              });
                            },
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    ChatBubble(
                                      elevation: 15,
                                      clipper: ChatBubbleClipper5(
                                          type: document['sender']
                                              ? BubbleType.sendBubble
                                              : BubbleType.receiverBubble),
                                      alignment: document['sender']
                                          ? Alignment.topRight
                                          : Alignment.topLeft,
                                      margin: EdgeInsets.only(top: 10),
                                      backGroundColor: document['sender']
                                          ? Color(
                                              0xff075E54) //Color(0xff006ab0) //Colors.grey[300]
                                          : Colors.white,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                        ),
                                        child: Stack(
                                          children: [
                                            Column(
                                              children: [
                                                Visibility(
                                                  visible: document['reply'],
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                          color: Colors.blueGrey
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          12),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          12))),
                                                      child: IntrinsicHeight(
                                                        child: Row(
                                                          children: [
                                                            Visibility(
                                                              visible: document[
                                                                          'sender'] ==
                                                                      true
                                                                  ? true
                                                                  : false,
                                                              child: Container(
                                                                width: 4,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  child: Text(
                                                                    document['reply_to'] ==
                                                                            true
                                                                        ? "You"
                                                                        : widget
                                                                            .username
                                                                            .toString(),
                                                                    style: TextStyle(
                                                                        color: document['sender']
                                                                            ? Colors
                                                                                .white
                                                                            : Colors
                                                                                .black87,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                SizedBox(
                                                                  child: Text(
                                                                    document['reply_msg'].length >
                                                                            20
                                                                        ? "${document['reply_msg'].substring(0, 20)}..."
                                                                        : document[
                                                                            'reply_msg'],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: TextStyle(
                                                                        color: document['sender']
                                                                            ? Colors
                                                                                .white60
                                                                            : Colors
                                                                                .black54,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Spacer(),
                                                            Visibility(
                                                              visible: document[
                                                                          'sender'] ==
                                                                      true
                                                                  ? false
                                                                  : true,
                                                              child: Container(
                                                                width: 4,
                                                                color: Colors
                                                                    .blueGrey,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                        minWidth: 70),
                                                    child: document['type'] ==
                                                            "text"
                                                        ? LinkText(
                                                            document['chat'],
                                                            textStyle: TextStyle(
                                                                color: document[
                                                                        'sender']
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                fontSize: 16),
                                                          )
                                                        : SizedBox(
                                                            height: 300,
                                                            width: 300,
                                                            child:
                                                                InteractiveViewer(
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Image.network(
                                                                    document[
                                                                        'chat'],
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                          )),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: TimeStampTimeAgo(
                                                textFontSize: 8,
                                                textColor: document['sender']
                                                    ? Colors.white60
                                                    : Colors.black54,
                                                timeStampData: DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        int.parse(
                                                            document['id'])),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    /* SizedBox(
                                      height: 10,
                                    ),*/
                                  ],
                                ),
                                /* Visibility(
                                  visible: document['sender'],
                                  child: Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Text(
                                      document['seen'] ? "Seen " : "",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                    ),
                                  ),
                                )*/
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: reply,
                      child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.25,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            sender == true
                                                ? "You"
                                                : widget.username.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                focus.unfocus();
                                                setState(() {
                                                  reply = false;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                size: 15,
                                              ))
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.25,
                                      child: Text(
                                        reply_msg.length > 30
                                            ? "${reply_msg.substring(0, 30)}..."
                                            : reply_msg,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 52),
                      child: FlutterChatBar(
                        // height: 52.0,
                        addIconSize: 30,
                        avatarRadius: 20,

                        width: MediaQuery.of(context).size.width / 1.01,
                        color: Colors.white,

                        addIconColor: Colors.black54, //Colors.grey[400],
                        firstChild: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.4,
                              child: TextFormField(
                                  focusNode: focus,
                                  scrollPhysics: BouncingScrollPhysics(),
                                  cursorColor: Colors.grey,
                                  maxLines: 5,
                                  autofocus: false,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  controller: chat_controller,
                                  style: TextStyle(
                                      fontSize: 23.0, color: Colors.black54),
                                  textInputAction: TextInputAction.newline,
                                  onChanged: (chat) async {
                                    if (chat == "") {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(auth.currentUser!.uid)
                                          .update({"status": "Online"});
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(widget.id)
                                          .collection("Chats")
                                          .doc(auth.currentUser!.uid)
                                          .update({"status": "typing...."});
                                      typing();
                                    }
                                    if (chat_controller.text == "") {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(auth.currentUser!.uid)
                                          .update({"status": "Online"});
                                    }
                                  },
                                  decoration: InputDecoration(
                                    focusColor: Color(0xffE25E31),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    hintText: "Your message ...",
                                    hintStyle: TextStyle(
                                        fontSize: 20.0, color: Colors.black54),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                              child: CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Colors.black38,
                                child: Transform.rotate(
                                  angle: 110 * math.pi / 60,
                                  child: upload == false
                                      ? IconButton(
                                          onPressed: () async {
                                            if (chat_controller
                                                .text.isNotEmpty) {
                                              setState(() {
                                                upload = true;
                                              });
                                              FirebaseFirestore
                                                  firebaseFirestore =
                                                  FirebaseFirestore.instance;

                                              final id = new DateTime.now()
                                                  .millisecondsSinceEpoch;

                                              ChatModel chatModel = ChatModel();
                                              chatModel.id = id.toString();
                                              chatModel.chat =
                                                  chat_controller.text;
                                              chatModel.sender = true;
                                              chatModel.type = 'text';
                                              chatModel.seen = false;
                                              chatModel.reply = reply;
                                              chatModel.reply_msg = reply_msg;
                                              chatModel.reply_to = sender;

                                              chat_controller.clear();
                                              setState(() {
                                                reply = false;
                                                upload = false;
                                              });

                                              await firebaseFirestore
                                                  .collection('Users')
                                                  .doc(auth.currentUser!.uid)
                                                  .collection(widget.useremail!)
                                                  .doc(id.toString())
                                                  .set(chatModel.toMap());
                                              chatModel.sender = false;

                                              await firebaseFirestore
                                                  .collection('Users')
                                                  .doc(widget.id)
                                                  .collection(auth
                                                      .currentUser!.email
                                                      .toString())
                                                  .doc(id.toString())
                                                  .set(chatModel.toMap());

                                              if (status != "Online") {
                                                sendNotification(
                                                    [tokenid],
                                                    "${chatModel.chat}",
                                                    "$username",
                                                    "");
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(widget.id)
                                                    .collection("Chats")
                                                    .doc(auth.currentUser!.uid)
                                                    .update({
                                                  "msg": chatModel.chat,
                                                  'time': id.toString(),
                                                  'seen': false,
                                                });
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(auth.currentUser!.uid)
                                                    .collection("Chats")
                                                    .doc(widget.id)
                                                    .update({
                                                  "msg": chatModel.chat,
                                                  'time': id.toString(),
                                                  'seen': true,
                                                });
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please enter message !")));
                                            }
                                          },
                                          icon: Icon(
                                            Icons.send,
                                            color: Colors.white,
                                          ),
                                        )
                                      : SpinKitCircle(
                                          color:
                                              Colors.white, //Color(0xffE25E31),
                                          size: 20.0,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        secondChild: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                final getimage = await ImagePicker.platform
                                    .pickImage(source: ImageSource.camera);
                                setState(() {
                                  image = File(getimage!.path);
                                });

                                cropper();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0,
                                    right: 12.0,
                                    top: 4.0,
                                    bottom: 4.0),
                                child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors.black38,
                                  child: Icon(
                                    Icons.camera,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final getimage = await ImagePicker.platform
                                    .pickImage(source: ImageSource.gallery);
                                setState(() {
                                  image = File(getimage!.path);
                                });

                                cropper();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0,
                                    right: 12.0,
                                    top: 4.0,
                                    bottom: 4.0),
                                child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors.black38,
                                  child: Icon(
                                    Icons.photo_size_select_actual,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            /* Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0,
                                  right: 12.0,
                                  top: 4.0,
                                  bottom: 4.0),
                              child: CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Colors.black38,
                                child: Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                /*Container(
                  padding: EdgeInsets.all(9),
                  child: TextFormField(
                    scrollPhysics: BouncingScrollPhysics(),
                    cursorColor: Color(0xff707070),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    controller: chat_controller,
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
                      suffixIcon: IconButton(
                        onPressed: () async {
                          if (chat_controller.text.isNotEmpty) {
                            FirebaseFirestore firebaseFirestore =
                                FirebaseFirestore.instance;

                            final id =
                                new DateTime.now().millisecondsSinceEpoch;

                            ChatModel chatModel = ChatModel();
                            chatModel.id = id.toString();
                            chatModel.chat = chat_controller.text;
                            chatModel.sender = true;
                            chat_controller.clear();
                            await firebaseFirestore
                                .collection('Users')
                                .doc(widget.id)
                                .collection('Chats')
                                .doc(id.toString())
                                .set(chatModel.toMap());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: Duration(milliseconds: 300),
                                backgroundColor: Colors.red,
                                content: Text("Please enter message !")));
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: Color(0xffE25E31),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintText: "Your message ...",
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
