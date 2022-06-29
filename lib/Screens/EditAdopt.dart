import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:group_button/group_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petlify/Models/AdoptModel.dart';
import 'package:petlify/Screens/MyProfile.dart';

class EditAdopt extends StatefulWidget {
  final String id;
  final String photo;
  final String? lon;
  final String? lan;
  final String? sex;
  final String? age;
  final String? uid;
  final String? more;
  final String? name;
  final String? price;
  final String? category;
  final String? location;
  const EditAdopt({
    Key? key,
    required this.id,
    required this.age,
    required this.lan,
    required this.lon,
    required this.more,
    required this.photo,
    required this.sex,
    required this.name,
    required this.uid,
    required this.price,
    required this.category,
    required this.location,
  }) : super(key: key);

  @override
  _EditAdoptState createState() => _EditAdoptState();
}

class _EditAdoptState extends State<EditAdopt> {
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
  var petname_controller = TextEditingController();
  final age_controller = TextEditingController();
  final price_controller = TextEditingController();
  final details_controller = TextEditingController();
  final sex_controller = GroupButtonController();
  final category_controller = GroupButtonController();
  @override
  void initState() {
    // TODO: implement initState
    petname_controller.text = widget.name.toString();
    age_controller.text = widget.age.toString();
    price_controller.text = widget.price.toString();
    details_controller.text = widget.more.toString();
    postimage = widget.photo.toString();
    if (widget.sex == "Male") {
      setState(() {
        sex_controller.selectIndex(0);
        sex = "Male";
      });
    } else {
      setState(() {
        sex_controller.selectIndex(1);
        sex = "Female";
      });
    }
    if (widget.category == "Dog") {
      setState(() {
        category_controller.selectIndex(0);
        category = "Dog";
      });
    } else if (widget.category == "Cat") {
      setState(() {
        category_controller.selectIndex(1);
        category = "Cat";
      });
    } else if (widget.category == "Bird") {
      setState(() {
        category_controller.selectIndex(2);
        category = "Bird";
      });
    } else if (widget.category == "Fish") {
      setState(() {
        category_controller.selectIndex(3);
        category = "Fish";
      });
    } else {
      setState(() {
        category_controller.selectIndex(4);
        category = "Fish";
      });
    }
    super.initState();
  }

  @override
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
                if (petname_controller.text.isNotEmpty) {
                  if (age_controller.text.isNotEmpty) {
                    if (price_controller.text.isNotEmpty) {
                      if (details_controller.text.isNotEmpty) {
                        if (sex != "") {
                          if (category != "") {
                            showDialog(
                                context: context,
                                builder: (context) => SpinKitChasingDots(
                                      color: Colors.white, //Color(0xffE25E31),
                                      size: 70.0,
                                    ));
                            postadopt();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: Duration(milliseconds: 300),
                                backgroundColor: Colors.red,
                                content: Text("Please select category !")));
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
        ],
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
        title: Text(
          "Edit Adopt",
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
                  visible: true,
                  child: Stack(
                    children: [
                      ConstrainedBox(
                        constraints: new BoxConstraints(
                          minHeight: 200.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            postimage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          } else if (index == 1) {
                            setState(() {
                              category = "Bird";
                            });
                          } else if (index == 2) {
                            setState(() {
                              category = "Fish";
                            });
                          } else {
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
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final id = widget.id.toString();
    adoptmodel AdoptModel = adoptmodel();
    AdoptModel.id = id.toString();
    AdoptModel.age = age_controller.text;
    AdoptModel.price = price_controller.text;
    AdoptModel.name = petname_controller.text;
    AdoptModel.uid = auth.currentUser!.uid;
    AdoptModel.text = details_controller.text;
    AdoptModel.category = category;
    AdoptModel.lon = widget.lon;
    AdoptModel.lan = widget.lan;
    AdoptModel.location = widget.location;
    AdoptModel.sex = sex;
    AdoptModel.photo = widget.photo;

    await firebaseFirestore
        .collection("Adopt")
        .doc(id.toString())
        .update(AdoptModel.toMap());

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("Update")));
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyProfile()));
  }
}
