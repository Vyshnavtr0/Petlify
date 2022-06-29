class SnapModel {
  String? id;
  String? uid;
  String? snap;
  String? name;
  String? photo;

  SnapModel({this.snap, this.name, this.id, this.photo, this.uid});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'snap': snap,
      'name': name,
      'photo': photo,
      'uid': uid,
    };
  }
}
