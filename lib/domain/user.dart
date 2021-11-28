class User {
  String? id;
  String? displayName;

  User({this.id, this.displayName});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayName = json['displayName'];
  }
}
