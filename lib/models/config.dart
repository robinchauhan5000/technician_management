import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:technician_time_app/services/api_service.dart';
import 'package:technician_time_app/services/database_service.dart';

class Config {
  int id;
  String key;
  String type;
  String data;

  Config(this.id, {
    this.key,
    this.type,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'type': type,
    'data': data,
  };

  factory Config.fromJson(dynamic json) {
    return Config(
      json['id'] as int,
      key: json['key'] as String,
      type: json['type'] as String,
      data: jsonEncode(json['data']),
    );
  }

  static Future<String> fetchAppDownloadUrl() async {
    List<dynamic> urlConfig = await Config.fetchByKey('tech-app-url');
    return urlConfig[0];
  }

  static Future<String> fetchAppDownloadVersion() async {
    List<dynamic> urlConfig = await Config.fetchByKey('tech-app-url');
    return urlConfig[1];
  }

  static dynamic fetchByKey(String key) async {
    final db = await DatabaseService.db.database;
    var res = await db.query('Configs', where: 'key = ?', whereArgs: [key]);
    if (res.length == 0) {
      print('No Config found for $key');
    }
    var data = jsonDecode(res[0]['data']);


    return data;
  }

  static Future<void> fetchAndSave() async {
    await DatabaseService.db.database;
    dynamic configs = await ApiService.fetchConfigs();
    return configs.map((config) {
      Config obj = Config.fromJson(config);
      obj.syncDb();
      return obj;
    }).toList();
  }

  Future<bool> dbExists() async {
    final db = await DatabaseService.db.database;
    var res = await db.query('Configs', where: 'id = ?', whereArgs: [this.id]);
    return res.length > 0;
  }

  Future<Config> syncDb() async {
    print('[SYNC] Updating Configs');
    bool exists = await this.dbExists();
    //
    if (exists) {
        await this.dbUpdate();
    } else {
      await this.dbCreate();
    }
    return this;
  }

  Future<Config> dbCreate() async {
    final db = await DatabaseService.db.database;
    try {
      await db.insert('Configs', this.toJson(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (_) {
      // mute that error on new DB
    }
    return this;
  }

  Future<Config> dbUpdate() async {
    final db = await DatabaseService.db.database;
    try {
      await db.update('Configs', this.toJson(),
          where: 'id = ?', whereArgs: [this.id]);
    } catch (error) {
      throw(error);
    }
    return this;
  }

}
