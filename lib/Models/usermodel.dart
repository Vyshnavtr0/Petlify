class usermodel {
  String? uid;
  String? email;
  String? name;
  String? photo;
  String? tokenid;
  String? status;
  String? lan;
  String? lon;
  String? location;
  String? phone;
  String? search;
  String? bio;
  List? followers;
  List? following;
  bool? verified;

  usermodel(
      {this.email,
      this.name,
      this.uid,
      this.photo,
      this.tokenid,
      this.followers,
      this.following,
      this.lan,
      this.lon,
      this.phone,
      this.bio,
      this.status,
      this.verified,
      this.location,
      this.search});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photo': photo,
      'tokenid': tokenid,
      'status': status,
      'lan': lan,
      'lon': lon,
      'phone': phone,
      'bio': bio,
      'followers': followers,
      'following': following,
      'verified': verified,
      'location': location,
      'search': search
    };
  }
}
