/// UserModel.dart
import 'dart:convert';

User clientFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromMap(jsonData);
}

String clientToJson(User data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class User {
  int id;
  String name;
  String color;
  int wins;
  int games;
  bool self;

  User({this.id, this.name, this.color, this.wins, this.games, this.self});

  factory User.fromMap(Map<String, dynamic> json) {
    print("JSON --------->>>>>>>>>>>>> $json");
    return new User(
        id: json["id"],
        name: json["name"],
        color: json["color"],
        wins: json["wins"],
        games: json["games"],
        self: json["self"] == 1);
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "color": color,
        "wins": wins,
        "games": games,
        "self": self
      };
}
