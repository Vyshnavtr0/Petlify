import 'package:cloud_firestore/cloud_firestore.dart';

class postmodel {
  String? id;
  String? post;
  String? name;
  String? photo;
  String? text;
  String? snaps;
  String? uid;
  List? likes;
  bool? verified;
  String? type;

  postmodel(
      {this.id,
      this.name,
      this.post,
      this.photo,
      this.text,
      this.likes,
      this.snaps,
      this.uid,
      this.verified,
      this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post': post,
      'text': text,
      'name': name,
      'photo': photo,
      'likes': likes,
      'snaps': snaps,
      'uid': uid,
      'verified': verified,
      'type': type
    };
  }
}
