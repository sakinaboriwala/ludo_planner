import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:ludo_planner/models/user.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    print("DB NULL");

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE User ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "color TEXT,"
          "wins INTEGER,"
          "games INTEGER,"
          "self BIT"
          ")");
    });
  }

  getUsers() async {
    List<User> users = [];

    final db = await database;
    var res = await db.query("User", where: "self = ?", whereArgs: [0]);
    if (res.isEmpty) {
      print("NO USERS");
      return users;
    } else {
      res.asMap().forEach((key, value) {
        users.add(User.fromMap(value));
      });
      return users;
    }
    // return res.isNotEmpty ? User.fromMap(res.first) : null;
  }

  Future<User> getSelfUser() async {
    final db = await database;
    var res = await db.query("User", where: "self = ?", whereArgs: [1]);
    return res.isNotEmpty ? User.fromMap(res.first) : null;
  }

  updateSelfUser(User user) async {
    final db = await database;
    var res = await db
        .update("User", user.toMap(), where: "id = ?", whereArgs: [user.id]);
    return res;
  }

  newUser(User newUser, User selfUser, bool selfFirstGame) async {
    final db = await database;
    var user =
        await db.query("User", where: "name = ?", whereArgs: [newUser.name]);

    if (user.isEmpty) {
      var res = await db.insert("User", newUser.toMap());
      newUser.id = res;
      newUser.games = newUser.games + 1;
      await updateUser(newUser);
      if (selfUser != null && !selfFirstGame) {
        selfUser.games = selfUser.games + 1;
        await updateSelfUser(selfUser);
      }

      return newUser;
    } else {
      User tempUser = User.fromMap(user.first);
      tempUser.games = tempUser.games + 1;
      await updateUser(tempUser);
      if (selfUser != null) {
        selfUser.games = selfUser.games + 1;
        await updateSelfUser(selfUser);
      }
      return tempUser;
    }
  }

  updateUser(User user) async {
    final db = await database;
    var res = await db
        .update("User", user.toMap(), where: "id = ?", whereArgs: [user.id]);
    return res;
  }

  deleteUser(int id) async {
    final db = await database;
    db.delete("User", where: "id = ?", whereArgs: [id]);
  }
}
