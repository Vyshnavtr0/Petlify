import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:petlify/Screens/EditProfile.dart';
import 'package:petlify/Screens/Home.dart';

class userLocation extends StatefulWidget {
  const userLocation({Key? key}) : super(key: key);

  @override
  _userLocationState createState() => _userLocationState();
}

class _userLocationState extends State<userLocation> {
  var location1 = "";
  final auth = FirebaseAuth.instance;
  Future<dynamic> _determinePosition() async {
    showDialog(
        context: context,
        builder: (context) => SpinKitCircle(
              color: Colors.white, //Color(0xffE25E31),
              size: 50.0,
            ));
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {}
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {}
    }

    _locationData = await location.getLocation();
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(Coordinates(
      _locationData.latitude,
      _locationData.longitude,
    ));
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    await firebaseFirestore
        .collection("Users")
        .doc(auth.currentUser!.uid)
        .update({
      'lan': _locationData.latitude.toString(),
      'lon': _locationData.longitude.toString(),
      'location':
          "${addresses.first.countryName.toString()},${addresses.first.adminArea.toString()}"
    });
    setState(() {
      location1 = addresses.first.addressLine.toString();
    });
    Navigator.of(context).pop();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Home(
              random: "id",
            )));
    return;
  }

  @override
  void initState() {
    // TODO: implement initState
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Home(
                        random: "id",
                      )));
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.5,
          title: Text(
            "Location",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => Home(
                            random: "id",
                          )));
                },
                child: Text(
                  "Skip",
                  style: TextStyle(color: Colors.grey),
                ))
          ]),
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Center(
              child: Image.network(
                "https://res.cloudinary.com/dvhlfyvrr/image/upload/v1644154278/Petlify/AppData/Group_111_bq6nl3.png",
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Location",
              style: TextStyle(fontSize: 25, color: Color(0xff3B3B3B)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Please enable your location to get better search results in your location.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xff3B3B3B)),
              ),
            ),
            Text(
              location1.toString(),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            Spacer(),
            GestureDetector(
              onTap: () async {
                _determinePosition();
              },
              child: Container(
                height: 52,
                width: MediaQuery.of(context).size.width / 1.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
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
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Enable Location",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      )),
    );
  }
}
