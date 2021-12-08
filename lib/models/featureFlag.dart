import 'package:sqflite/sqflite.dart';

import '../services/api_service.dart';
import '../services/database_service.dart';

class FeatureFlag {
  int id;
  String name;
  String application;
  // int enabledAll;
  DateTime expiresAt;
  int needsSync;

  FeatureFlag(
    this.id, {
    this.name,
    this.application,
    // this.enabledAll,
    this.expiresAt,
    this.needsSync = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'application': application,
        // 'enabledAll': enabledAll,
        'expiresAt': expiresAt,
      };

  factory FeatureFlag.fromJson(dynamic json) {
    return FeatureFlag(
      json['id'] as int,
      name: json['name'] as String,
      application: json['application'] as String,
      // enabledAll: json['enabledAll'] as int,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Future<bool> dbExists() async {
    final db = await DatabaseService.db.database;
    var res =
        await db.query('FeatureFlags', where: 'id = ?', whereArgs: [this.id]);
    return res.length > 0;
  }

  Future<FeatureFlag> dbCreate() async {
    final db = await DatabaseService.db.database;
    try {
      await db.insert('FeatureFlags', this.toJson(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (_) {
      // mute that error on new DB
    }
    return this;
  }

  Future<FeatureFlag> dbUpdate() async {
    final db = await DatabaseService.db.database;
    try {
      await db.update('FeatureFlags', this.toJson(),
          where: 'id = ?', whereArgs: [this.id]);
    } catch (error) {
      throw (error);
    }
    return this;
  }

  bool get needsSyncBool {
    return this.needsSync != null && this.needsSync == true;
  }

  Future<FeatureFlag> syncDb() async {
    bool exists = await this.dbExists();
    //
    if (exists) {
      if (!this.needsSyncBool) {
        await this.dbUpdate();
      }
    } else {
      await this.dbCreate();
    }
    return this;
  }

  static Future<List<FeatureFlag>> dbFetchForTechnician() async {
    final db = await DatabaseService.db.database;
    final List<Map<String, dynamic>> records = await db.query('FeatureFlags');
    return records.map((featureFlag) {
      FeatureFlag obj = FeatureFlag.fromJson(featureFlag);
      return obj;
    }).toList();
  }

  static Future<List<FeatureFlag>> apiFetchForTechnician(
      {bool syncDb = true}) async {
    var apiFeatureFlags =
        await ApiService.fetchUserFeatureFlags() as List<dynamic>;
    if (apiFeatureFlags == null) {
      return [];
    }
    return apiFeatureFlags.map((workorder) {
      FeatureFlag obj = FeatureFlag.fromJson(workorder);
      if (syncDb) {
        obj.syncDb();
      }

      return obj;
    }).toList();
  }

  static Future<void> dbRemoveNotIn(List<int> ids) async {
    final db = await DatabaseService.db.database;
    return db.delete('FeatureFlags', where: 'id NOT IN (${ids.join(',')})');
  }

  static Future<List<dynamic>> fetchForTechnician({bool syncDb = true}) async {
    // Leave these here for cleaning up the DB during development:
    // final db = await DatabaseService.db.database;
    // await DatabaseService.db.deleteDatabase();
    // await db.delete('FeatureFlags');
    bool connected = await ApiService.isConnected();
    if (connected) {
      // Fetches from API and updates the DB
      List<FeatureFlag> featureFlags =
          await apiFetchForTechnician(syncDb: syncDb);
      if (syncDb) {
        print('[SYNC] Received ${featureFlags.length} FeatureFlags from API');
        List<int> featureFlagIds = featureFlags
            .map((FeatureFlag featureFlag) => featureFlag.id)
            .toList();
        await FeatureFlag.dbRemoveNotIn(featureFlagIds);
      }
    }
    return FeatureFlag.dbFetchForTechnician();
  }

  static Future<bool> enabled(String flagName) async {
    final db = await DatabaseService.db.database;
    var res = await db
        .query('FeatureFlags', where: 'name = ?', whereArgs: [flagName]);
    return res.length > 0;
  }
}
