import 'package:sqflite/sqflite.dart';

import '../services/database_service.dart';

String locationTable = 'location_table';

class LocationDBModel {
  int _id;
  String lat;
  String long;


  LocationDBModel({this.lat, this.long});
  int get id => _id;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }

    map['lat'] = lat;

    map['long'] = long;

    return map;
  }

  // Extract a object from a Map object

  LocationDBModel.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];

    this.lat = map['lat'];

    this.long = map['long'];
  }

  static Future<LocationDBModel> getMostRecent () async {
    final db = await DatabaseService.db.database;

    int count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $locationTable'));

    List<Map<String, Object>> dbResult = await db.query(
        "SELECT * from " +
        locationTable +
        "ORDER BY 'id' DESC " +
        "LIMIT 1"
    );

    print(dbResult.toString());
  }

}
