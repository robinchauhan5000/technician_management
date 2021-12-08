import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Map tableCreateScripts = {
  'Workorders': """CREATE TABLE Workorders (
                  id INTEGER PRIMARY KEY,
                  number STRING,
                  internalNumber STRING,
                  address STRING,
                  addressTwo STRING,
                  city STRING,
                  state STRING,
                  postalCode STRING,
                  lat STRING,
                  lng STRING,
                  region STRING,
                  phoneNumbers STRING,
                  workRequired STRING,
                  freonDetails STRING,
                  StatusId INTEGER,
                  SiteId INTEGER,
                  technicianSummary STRING,
                  technicianStatus STRING,
                  needsSync INTEGER DEFAULT 0,
                  timeframe STRING,
                  position INTEGER,
                  createdAt STRING
                  );""",
  'WorkorderUploads': """CREATE TABLE WorkorderUploads(
                  id INTEGER PRIMARY KEY,
                  WorkorderId INTEGER,
                  url STRING,
                  thumbnailUrl STRING,
                  localUrl STRING,
                  localThumbnailUrl STRING,
                  type STRING,
                  caption STRING,
                  createdAt STRING,
                  lat STRING,
                  lon STRING,
                  needsSync INTEGER DEFAULT 0
                  );""",
  'Configs': """CREATE TABLE Configs(
                  id INTEGER PRIMARY KEY,
                  key STRING,
                  type STRING,
                  data STRING
                  );""",
  'FeatureFlags': """CREATE TABLE FeatureFlags(
                  id INTEGER PRIMARY KEY,
                  name STRING,
                  application STRING,
                  expiresAt STRING,
                  needsSync INTEGER DEFAULT 0
                  );""",
  'Sites': """CREATE TABLE Sites(
                  id INTEGER PRIMARY KEY,
                  accessNotes STRING,
                  type STRING,
                  numberOfSystems INT,
                  needsSync INTEGER DEFAULT 0
                  );""",
  'Systems': """CREATE TABLE Systems(
                  id INTEGER PRIMARY KEY,
                  SiteId INTEGER,
                  serviceArea STRING,
                  type STRING,
                  needsSync INTEGER DEFAULT 0,
                  syncType STRING
                  );""",
  'Components': """CREATE TABLE Components(
                  id INTEGER PRIMARY KEY,
                  SystemId INTEGER,
                  type STRING,
                  brand STRING,
                  modelNumber STRING,
                  serialNumber STRING,
                  needsSync INTEGER DEFAULT 0,
                  syncType STRING
                  );""",
  'Diagnoses': """CREATE TABLE Diagnoses(
                  id INTEGER PRIMARY KEY,
                  SystemId INTEGER,
                  ComponentId INTEGER,
                  SiteId INTEGER,
                  WorkorderId INTEGER,
                  CreatedById INTEGER,
                  notes STRING,
                  createdAt STRING,
                  needsSync INTEGER DEFAULT 0,
                  syncType STRING
                  );"""
};

class DatabaseService {
  DatabaseService._();
  static final DatabaseService db = DatabaseService._();
  Database _database;

  Future<Database> getNewDatabaseInstance() async {
    // await Sqflite.devSetDebugModeOn(true);
    await this.deleteDatabase();
    String directory = await getDatabasesPath();
    String path = join(directory, 'ems_technician_app.db');
    return await openDatabase(path, version: 4,
        onCreate: (Database db, int version) async {
          await db.execute(tableCreateScripts['Workorders']);
          await db.execute(tableCreateScripts['WorkorderUploads']);
          await db.execute(tableCreateScripts['Configs']);
          await db.execute(tableCreateScripts['Sites']);
          await db.execute(tableCreateScripts['Systems']);
          await db.execute(tableCreateScripts['Components']);
          await db.execute(tableCreateScripts['Diagnoses']);
          await db.execute(tableCreateScripts['FeatureFlags']);
        }
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getNewDatabaseInstance();
    return _database;
  }

  Future<void> deleteDatabase() async {
    String directory = await getDatabasesPath();
    String path = join(directory, 'ems_technician_app.db');
    return databaseFactory.deleteDatabase(path);
  }
}
