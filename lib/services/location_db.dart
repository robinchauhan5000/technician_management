import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:technician_time_app/models/location_model.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper

  static Database _database; // Singleton Database

  String locationTable = 'location_table';

  String colId = 'id';

  String colLat = 'lat';
  String colLong = 'long';

  DatabaseHelper._createInstance();
  static final DatabaseHelper instance = DatabaseHelper
      ._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object

    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.

    Directory directory = await getApplicationDocumentsDirectory();

    String path = directory.path + 'latLong.db';

    // Open/create the database at a given path

    var locationDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);

    return locationDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $locationTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colLat TEXT, '
        '$colLong TEXT)');
  }

  // Fetch Operation: Get all objects from database

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $locationTable order by $colPriority ASC');

    var result = await db.query(locationTable);

    return result;
  }

  // Insert Operation: Insert a Location object to database

  Future<int> insertLocationDatabase(LocationDBModel location) async {
    Database db = await this.database;

    var result = await db.insert(locationTable, location.toMap());

    return result;
  }

  // Get the number of Location object in database

  Future<int> getCount() async {
    Database db = await this.database;

    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $locationTable');

    int result = Sqflite.firstIntValue(x);

    return result;
  }

  Future deleteEnteries() async {
    Database db = await this.database;

    int count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $locationTable'));

    if (count < 10) {
      print('Database values' + count.toString());
    } else {
      String ALTER_TBL = "delete from " +
          locationTable +
          " where rowid IN (Select rowid from " +
          locationTable +
          " limit 1)";

      db.execute(ALTER_TBL);
      print('Database value' + count.toString());
    }
  }
}
