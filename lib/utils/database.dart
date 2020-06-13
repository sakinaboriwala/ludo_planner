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

  newUser(User newUser) async {
    final db = await database;
    var user =
        await db.query("User", where: "name = ?", whereArgs: [newUser.name]);

    if (user.isEmpty) {
      var res = await db.insert("User", newUser.toMap());
      return res;
    } else {
      return user;
    }
  }

  deleteUser(int id) async {
    final db = await database;
    db.delete("User", where: "id = ?", whereArgs: [id]);
  }
}
