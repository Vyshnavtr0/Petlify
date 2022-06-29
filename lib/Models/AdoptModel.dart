import 'package:cloud_firestore/cloud_firestore.dart';

class adoptmodel {
  String? id;
  String? age;
  String? name;
  String? photo;
  String? text;
  String? sex;
  String? uid;
  String? location;
  String? category;
  String? price;
  String? lan;
  String? lon;

  adoptmodel(
      {this.id,
      this.name,
      this.age,
      this.photo,
      this.text,
      this.location,
      this.price,
      this.uid,
      this.lan,
      this.lon,
      this.sex,
      this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'age': age,
      'text': text,
      'name': name,
      'photo': photo,
      'location': location,
      'price': price,
      'uid': uid,
      'sex': sex,
      'lan': lan,
      'lon': lon,
      'category': category
    };
  }
}
