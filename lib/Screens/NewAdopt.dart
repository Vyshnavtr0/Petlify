import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:petlify/Models/AdoptModel.dart';
import 'package:petlify/Screens/EditProfile.dart';
import 'package:petlify/Screens/MyProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:group_button/group_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class NewAdopt extends StatefulWidget {
  const NewAdopt({Key? key}) : super(key: key);

  @override
  _NewAdoptState createState() => _NewAdoptState();
}

class _NewAdoptState extends State<NewAdopt> {
  bool publish = true;
  bool publish2 = false;
  final auth = FirebaseAuth.instance;
  dynamic postimage;
  File? image;
  String sex = "";
  String lan = "";
  String location = "";
  String lon = "";
  String category = '';
  final petname_controller = TextEditingController();
  final age_controller = TextEditingController();
  final price_controller = TextEditingController();
  final details_controller = TextEditingController();
  final sex_controller = GroupButtonController();
  final category_controller = GroupButtonController();
  final cloudinary =
      Cloudinary("366248915146297", "BIyUWoSbzvzjy2Xqx73JXnVnWzY", "dvhlfyvrr");
  @override
  void initState() {
    // TODO: implement initState
    final user = FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        lan = value.data()!['lan'];
        lon = value.data()!['lon'];
        location = value.data()!['location'];
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e!.message)));
    });
    super.initState();
  }

  Widget build(BuildContext context) {
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
                  if (petname_controller.text.isNotEmpty) {
                    if (age_controller.text.isNotEmpty) {
                      if (price_controller.text.isNotEmpty) {
                        if (details_controller.text.isNotEmpty) {
                          if (sex != "") {
                            if (category != "") {
                              showDialog(
                                  context: context,
                                  builder: (context) => SpinKitChasingDots(
                                        color:
                                            Colors.white, //Color(0xffE25E31),
                                        size: 70.0,
                                      ));
                              postadopt();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration: Duration(milliseconds: 300),
                                      backgroundColor: Colors.red,
                                      content:
                                          Text("Please select category !")));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: Duration(milliseconds: 300),
                                backgroundColor: Colors.red,
                                content: Text("Please select sex!")));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(milliseconds: 300),
                              backgroundColor: Colors.red,
                              content:
                                  Text("Please enter more details details !")));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(milliseconds: 300),
                            backgroundColor: Colors.red,
                            content: Text("Please enter price !")));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(milliseconds: 300),
                          backgroundColor: Colors.red,
                          content: Text("Please enter age !")));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 300),
                        backgroundColor: Colors.red,
                        content: Text("Please enter pet name !")));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 300),
                      backgroundColor: Colors.red,
                      content: Text("Please select an image  !")));
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
          "Sell a Pet",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: publish,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3.5,
                    decoration: BoxDecoration(
                        color: Color(0xffffe8ea),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Upload photo ',
                            style: TextStyle(
                                fontSize: 18, color: Color(0xffE25E31)),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final getimage = await ImagePicker.platform
                                  .pickImage(source: ImageSource.gallery);
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
                              });
                            },
                            child: Image.network(
                              "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1641565767/Pet%20Life/Data/Path_94_oexycu.png",
                              width: MediaQuery.of(context).size.width / 5,
                              height: MediaQuery.of(context).size.width / 5,
                            ),
                          ),
                        ]),
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(image!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
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
                    : SizedBox(
                        height: 0,
                      ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    cursorColor: Color(0xff707070),
                    keyboardType: TextInputType.text,
                    controller: petname_controller,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Color(0xff707070)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Color(0xff707070)),
                        ),
                        labelText: "Name of pet",
                        labelStyle: TextStyle(color: Color(0xff707070))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sex",
                        style:
                            TextStyle(fontSize: 18, color: Color(0xff707070)),
                      )
                    ],
                  ),
                ),
                GroupButton(
                  groupingType: GroupingType.row,
                  isRadio: true,
                  controller: sex_controller,
                  mainGroupAlignment: MainGroupAlignment.start,
                  borderRadius: BorderRadius.circular(20),
                  unselectedTextStyle: TextStyle(color: Color(0xffF75950)),
                  selectedColor: Color(0xffF75950),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  unselectedBorderColor: Color(0xffF75950),
                  spacing: 8,
                  onSelected: (index, isSelected) {
                    if (index == 0) {
                      setState(() {
                        sex = "Male";
                      });
                    } else {
                      setState(() {
                        sex = "Female";
                      });
                    }
                  },
                  buttons: [
                    " ♂️ Male",
                    " ♀️ Female",
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: TextField(
                        cursorColor: Color(0xff707070),
                        keyboardType: TextInputType.text,
                        controller: age_controller,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            labelText: "Age",
                            labelStyle: TextStyle(color: Color(0xff707070))),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: TextField(
                        cursorColor: Color(0xff707070),
                        keyboardType: TextInputType.text,
                        controller: price_controller,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            labelText: "Price",
                            labelStyle: TextStyle(color: Color(0xff707070))),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Category",
                        style:
                            TextStyle(fontSize: 18, color: Color(0xff707070)),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    children: [
                      GroupButton(
                        groupingType: GroupingType.row,
                        isRadio: true,
                        controller: category_controller,
                        mainGroupAlignment: MainGroupAlignment.spaceEvenly,
                        borderRadius: BorderRadius.circular(20),
                        unselectedTextStyle:
                            TextStyle(color: Color(0xffF75950)),
                        selectedColor: Color(0xffF75950),
                        selectedTextStyle: TextStyle(color: Colors.white),
                        unselectedBorderColor: Color(0xffF75950),
                        spacing: 8,
                        onSelected: (index, isSelected) {
                          if (index == 0) {
                            setState(() {
                              category = "Dog";
                            });
                          } else if (index == 1) {
                            setState(() {
                              category = "Cat";
                            });
                          } else if (index == 2) {
                            setState(() {
                              category = "Bird";
                            });
                          } else if (index == 3) {
                            setState(() {
                              category = "Fish";
                            });
                          } else if (index == 4) {
                            setState(() {
                              category == "Other";
                            });
                          }
                        },
                        buttons: [
                          "🐕 Dog",
                          "🐈 Cat",
                          "🦜 Bird",
                          "🐠 Fish",
                          "🐾 Other",
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(0),
                  child: TextFormField(
                    scrollPhysics: BouncingScrollPhysics(),
                    cursorColor: Color(0xff707070),
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    controller: details_controller,
                    // minLines: 1,
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Color(0xff707070)),
                      ),
                      hintText: "More Details...",
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

  postadopt() async {
    String post = "";
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    final response = await cloudinary.uploadFile(
      filePath: postimage.path,
      resourceType: CloudinaryResourceType.image,
      folder: "Petlify/Adopt",
    );

    if (response.isSuccessful) {
      setState(() {
        post = response.url!;
      });
    }
    final id = new DateTime.now().millisecondsSinceEpoch;
    adoptmodel AdoptModel = adoptmodel();
    AdoptModel.id = id.toString();
    AdoptModel.age = age_controller.text;
    AdoptModel.price = price_controller.text;
    AdoptModel.name = petname_controller.text;
    AdoptModel.uid = auth.currentUser!.uid;
    AdoptModel.text = details_controller.text;
    AdoptModel.category = category;
    AdoptModel.location = location;
    AdoptModel.lon = lon;
    AdoptModel.lan = lan;

    AdoptModel.sex = sex;
    AdoptModel.photo = post == "" ? response.url : post;

    await firebaseFirestore
        .collection("Adopt")
        .doc(id.toString())
        .set(AdoptModel.toMap());

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("Published")));
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyProfile()));
  }
}
