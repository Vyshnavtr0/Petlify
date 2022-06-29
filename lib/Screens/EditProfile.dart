import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petlify/Screens/MyProfile.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

final email_controller = TextEditingController();
final name_controller = TextEditingController();
final bio_controller = TextEditingController();
final auth = FirebaseAuth.instance;
String bio = "";
bool loading = false;
final cloudinary =
    Cloudinary("366248915146297", "BIyUWoSbzvzjy2Xqx73JXnVnWzY", "dvhlfyvrr");
String userphoto =
    "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641310994/Pet%20Life/Data/profile_l447qx.png";
File? image;
List posts = [];

class _EditProfileState extends State<EditProfile> {
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

          name_controller.text = value.data()!['name'];
          bio_controller.text = value.data()!['bio'];
          email_controller.text = auth.currentUser!.email!;
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
      });
    }

    userinfo();
    super.initState();
  }

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

    final response = await cloudinary.uploadFile(
      filePath: copiedImage.path,
      resourceType: CloudinaryResourceType.image,
      folder: "Petlify/Profile",
    );

    if (response.isSuccessful) {
      setState(() {
        userphoto = response.url!;

        loading = false;
      });
    }

    //  Reference ref = FirebaseStorage.instance.ref().child("image");
    // ref.putFile(crop);
  }

  @override
  Widget build(BuildContext context) {
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
            "Edit Profile",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          actions: []),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Stack(
                  children: [
                    AvatarGlow(
                      glowColor: Colors.grey,
                      endRadius: 100.0,
                      duration: Duration(milliseconds: 2000),
                      repeat: true,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/profile.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Image.network(
                                userphoto,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.width / 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Visibility(
                          visible: loading,
                          child: SpinKitCircle(
                            color: Colors.white, //Color(0xffE25E31),
                            size: 40.0,
                          ),
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () async {
                          // final getimage = await ImagePicker.platform
                          //      .pickImage(source: ImageSource.gallery);
                          //  setState(() {
                          //    image = File(getimage!.path);
                          //  });
                          //   cropper();
                          showMaterialModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final getimage =
                                          await ImagePicker.platform.pickImage(
                                              source: ImageSource.gallery);
                                      setState(() {
                                        image = File(getimage!.path);
                                      });
                                      Navigator.of(context).pop();
                                      cropper();
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
                                                "Gallery",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Color(0xff3B3B3B),
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                      final getimage =
                                          await ImagePicker.platform.pickImage(
                                              source: ImageSource.camera);
                                      setState(() {
                                        image = File(getimage!.path);
                                      });
                                      Navigator.of(context).pop();
                                      cropper();
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
                                                "Camera",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Color(0xff3B3B3B),
                                                    fontWeight:
                                                        FontWeight.w500),
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
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              gradient: RadialGradient(
                                colors: const [
                                  Color(0xFFF58524),
                                  Color(0xFFF92B7F),
                                ],
                                // begin: const FractionalOffset(0.0, 0.0),
                                // end: const FractionalOffset(1.0, 0.0),
                                stops: const [0.0, 1.0],
                              ),
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.edit,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  cursorColor: Color(0xff707070),
                  controller: name_controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      labelText: "Name",
                      labelStyle: TextStyle(color: Color(0xff707070))),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  cursorColor: Color(0xff707070),
                  controller: bio_controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      labelText: "Bio",
                      labelStyle: TextStyle(color: Color(0xff707070))),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  readOnly: true,
                  cursorColor: Color(0xff707070),
                  controller: email_controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      labelText: "Email",
                      labelStyle: TextStyle(color: Color(0xff707070))),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              GestureDetector(
                onTap: () async {
                  if (name_controller.text.isNotEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) => SpinKitChasingDots(
                              color: Colors.white, //Color(0xffE25E31),
                              size: 70.0,
                            ));
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(auth.currentUser!.uid)
                        .update({
                      'name': name_controller.text,
                      'photo': userphoto,
                      'bio': bio_controller.text
                    });
                    var collection =
                        FirebaseFirestore.instance.collection('Posts');
                    var querySnapshots = await collection
                        .where('uid', isEqualTo: auth.currentUser!.uid)
                        .get();
                    for (var doc in querySnapshots.docs) {
                      await doc.reference.update(
                          {'name': name_controller.text, 'photo': userphoto});
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Updated")));
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyProfile()));
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
                          "Update",
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
      )),
    );
  }
}
