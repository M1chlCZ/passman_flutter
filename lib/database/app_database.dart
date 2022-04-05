import 'dart:io' show Directory;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passman/interfaces/db_interface.dart';
import 'package:passman/model/password_item.dart';
import 'package:passman/support/utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';
import 'package:sprintf/sprintf.dart';

import 'package:passman/support/global_variables.dart' as globals;

const dbVersion = 1;

class AppDatabase implements DatabaseInterface {
  final _storage = const FlutterSecureStorage();

  final String passTable = sprintf(
      'CREATE TABLE IF NOT EXISTS %s (%s INTEGER PRIMARY KEY, %s STRING, %s STRING, %s STRING)',
      [
        globals.tablePass,
        globals.id,
        globals.url,
        globals.username,
        globals.pass,
      ]);

  static Database? _db;
  static final AppDatabase _instance = AppDatabase.internal();

  factory AppDatabase() => _instance;
  List<String> tablesSql = [];

  AppDatabase.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'maindb.db');
    var db = await openDatabase(path,
        version: dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return db;
  }

  Future<Database> get db async {
    tablesSql.add(passTable);

    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  @override
  Future<bool> addPasswordEntry(
      {required String url,
      required String username,
      required String password}) async {
    try {
      final dbClient = await db;
      String _key = genKey();
     await dbClient.insert(globals.tablePass,
          PasswordItem(url: url, username: username, password: _key).toMap());
      await _storage.write(key: _key, value: password);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<List<PasswordItem>> getPasswords() async {
    final dbClient = await db;
    var res = await dbClient.query(globals.tablePass);
    return List.generate(res.length, (i) {
      return PasswordItem(
        id: res[i][globals.id] as int,
        url: res[i][globals.url] as String,
        username: res[i][globals.username] as String,
        password: res[i][globals.pass] as String,
      );
    });
  }

  @override
  Future<PasswordItem> getPassword(int id) async {
    final dbClient = await db;
    var res = await dbClient.query(globals.tablePass, where: globals.id + "=?", whereArgs: [id]);
    return PasswordItem(
      id: res.first[globals.id] as int,
      url: res.first[globals.url] as String,
      username: res.first[globals.username] as String,
      password: res.first[globals.pass] as String,
    );
  }

  @override
  Future<bool> updatePassword(
      {required int id,
      required String url,
      required String username,
      required String password}) async {
    try {
      final dbClient = await db;
      String _key = genKey();
      Map<String, dynamic> row = {
        globals.url: url,
        globals.username: username,
        globals.pass: _key,
      };

      await dbClient.update(globals.tablePass, row,
          where: globals.id.toString() + '= ?', whereArgs: [id]);
      await _storage.write(key: _key, value: password);

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<void> deletePass({required int id}) async {
    final dbClient = await db;
    await dbClient.delete(globals.tablePass, where: globals.id + "=?", whereArgs: [id]);
  }

  @override
  Future<List<PasswordItem>> searchPassword(String searchQuery) async {
    var d = await db;
    var res = await d.rawQuery("SELECT * FROM " + globals.tablePass + " WHERE " + globals.url + " LIKE " + "'%" + searchQuery + "%' COLLATE NOCASE");
    return List.generate(res.length, (i) {
      return PasswordItem(
        id: res[i][globals.id] as int,
        url: res[i][globals.url] as String,
        username: res[i][globals.username] as String,
        password: res[i][globals.pass] as String,
      );
    });
  }

  void _onCreate(Database db, int version) async {
    for (var element in tablesSql) {
      db.execute(element);
    }
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // switch (oldVersion) {
    //   case 1:
    //     try {
    //       await db.execute(table);
    //     } catch (e) {
    //       print(e);
    //     }
    //     break;
    // }
  }

  String genKey() {
    return Utils.getRandString(6);
  }
}
