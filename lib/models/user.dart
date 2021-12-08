class User {
  int id;
  String username;

  User(this.id, this.username);

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username
  };

  factory User.fromJson(dynamic json) {
    return User(json['id'] as int, json['username'] as String);
  }
}
