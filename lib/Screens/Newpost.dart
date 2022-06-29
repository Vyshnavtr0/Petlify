import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:petlify/Models/PostModel.dart';
import 'package:petlify/Screens/MyProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final auth = FirebaseAuth.instance;
  String username = "User name";
  String imageorvideo = "image";
  bool publish = true;
  bool publish2 = false;
  final post_text = TextEditingController();

  dynamic postimage;
  File? image;
  bool verified = false;
  final cloudinary =
      Cloudinary("366248915146297", "BIyUWoSbzvzjy2Xqx73JXnVnWzY", "dvhlfyvrr");
  String userphoto =
      "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
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
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                if (publish2 == true) {
                  if (post_text.text.isNotEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) => SpinKitChasingDots(
                              color: Colors.white, //Color(0xffE25E31),
                              size: 70.0,
                            ));
                    postDetailsToFirestore();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 300),
                        backgroundColor: Colors.red,
                        content: Text("Please Snap Somthing !")));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 300),
                      backgroundColor: Colors.red,
                      content: Text("Please select an image!")));
                }
              },
              child: Text(
                "Publish",
                style: TextStyle(fontSize: 16, color: Color(0xffF75950)),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
        title: Text(
          "New Post",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
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
                    child: Image.network(
                      userphoto,
                      fit: BoxFit.cover,
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
            Visibility(
              visible: publish,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(color: Color(0xffffe8ea)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Upload a photo or video',
                      style: TextStyle(fontSize: 18, color: Color(0xffE25E31)),
                    ),
                    GestureDetector(
                      onTap: () async {
                        showMaterialModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final getimage = await ImagePicker.platform
                                        .pickVideo(source: ImageSource.gallery);
                                    final crop = await ImageCropper.cropImage(
                                      sourcePath: getimage!.path,
                                    );
                                    final Directory dir =
                                        await getApplicationDocumentsDirectory();
                                    final String appDir = dir.path;
                                    final File imageFile =
                                        File(appDir + '/profile_picture.jpg');
                                    if (await imageFile.exists()) {
                                      imageFile.delete();
                                    }
                                    imageCache.clearLiveImages();
                                    imageCache.clear();
                                    final File copyimage = await crop!
                                        .copy('$appDir/profile_picture.jpg');
                                    setState(() {
                                      postimage = copyimage;
                                    });
                                    setState(() {
                                      image = crop;
                                      publish = false;
                                      publish2 = true;
                                      imageorvideo = 'image';
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
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
                                              "Image",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xff3B3B3B),
                                                  fontWeight: FontWeight.w500),
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
                                    final getimage = await ImagePicker.platform
                                        .pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 35);
                                    final crop = await ImageCropper.cropImage(
                                        sourcePath: getimage!.path,
                                        aspectRatio: CropAspectRatio(
                                            ratioX: 1, ratioY: 1));
                                    final Directory dir =
                                        await getApplicationDocumentsDirectory();
                                    final String appDir = dir.path;
                                    final File imageFile =
                                        File(appDir + '/profile_picture.jpg');
                                    if (await imageFile.exists()) {
                                      imageFile.delete();
                                    }
                                    imageCache.clearLiveImages();
                                    imageCache.clear();
                                    final File copyimage = await crop!
                                        .copy('$appDir/profile_picture.jpg');
                                    setState(() {
                                      postimage = copyimage;
                                    });
                                    setState(() {
                                      image = crop;
                                      publish = false;
                                      publish2 = true;
                                      imageorvideo = 'video';
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
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
                                              "Video",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xff3B3B3B),
                                                  fontWeight: FontWeight.w500),
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
                      child: Image.network(
                        "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641565767/Pet%20Life/Data/Path_94_oexycu.png",
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            image != null
                ? Visibility(
                    visible: publish2,
                    child: Stack(
                      children: [
                        ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 200.0,
                          ),
                          child: Image.file(
                            File(image!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white),
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      publish = true;
                                      publish2 = false;
                                    });
                                  },
                                  iconSize: 23,
                                  color: Color(0xffF75950),
                                  icon: Icon(Icons.close),
                                ),
                              ),
                            ))
                      ],
                    ),
                  )
                : SizedBox(),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(8),
              child: TextFormField(
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
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  postDetailsToFirestore() async {
    String post = "";
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    final response = await cloudinary.uploadFile(
      filePath: postimage.path,
      resourceType: CloudinaryResourceType.auto,
      folder: "Petlify/Posts",
    );

    if (response.isSuccessful) {
      setState(() {
        post = response.url!;
      });
    }
    final id = new DateTime.now().millisecondsSinceEpoch;
    postmodel postModel = postmodel();

    postModel.id = id.toString();
    postModel.name = username;
    postModel.photo = userphoto;
    postModel.text = post_text.text;
    postModel.post = post == "" ? response.url : post;
    postModel.snaps = "0";
    postModel.uid = auth.currentUser!.uid;
    postModel.likes = [];
    postModel.verified = verified;
    postModel.type = imageorvideo;

    await firebaseFirestore
        .collection("Posts")
        .doc(id.toString())
        .set(postModel.toMap());

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("Published")));
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyProfile()));
  }
}
