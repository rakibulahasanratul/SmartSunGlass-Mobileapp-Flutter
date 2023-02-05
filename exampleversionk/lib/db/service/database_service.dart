import 'dart:io'; //provides APIs to deal with files, directories, processes, sockets, WebSockets, and HTTP clients and servers

import 'package:sqflite/sqflite.dart'; // package to store data in the local database
import 'package:path_provider/path_provider.dart'; //plugin for finding commonly used location of the file system.
import 'package:path/path.dart'; // path library is designed to import with a prefix

import '../model/master_table_model.dart'; //Master table model. Any new column is require to expose in the master table model
import '../model/slave_table_model.dart'; //Slave table model. Any new column is require to expose in the slave table model

//DatabaseService class initialization. This is required to init() in the main.dart
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();
  static Database? _database;

  Future<Database?> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // / If database don't exists, create one
    _database = await initDB();
    return _database;
  }

  Future<dynamic> initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'voltageData.db'); //Main database name
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      //Table creation for master voltage data. This table has 4 column.
      await db.execute('CREATE TABLE mastervoltageData('
          'id INTEGER PRIMARY KEY AUTOINCREMENT ,'
          'TIME TEXT DEFAULT "0",'
          'MV TEXT DEFAULT "0",' //MV=Master Voltage
          'MVP TEXT DEFAULT "0",' //MVP=Master Voltage Percentage
          'MVD TEXT DEFAULT "0"' //MVD=Master Voltage Difference
          ')');
      //Table creation for slave voltage data. This table has 4 column.
      await db.execute('CREATE TABLE slavevoltageData('
          'id INTEGER PRIMARY KEY AUTOINCREMENT ,'
          'TIME TEXT DEFAULT "0",'
          'SV TEXT DEFAULT "0",' //SV=Slave Voltage
          'SVP TEXT DEFAULT "0",' //SVP=Slave Voltage Percentage
          'SVD TEXT DEFAULT "0"' //SVD=Slave Voltage Difference
          ')');
    });
  }

  //::::::::::::::::::::: Insert data into "mastervoltageData" table ::::::::::::::::::::
  Future<void> addToMasterDatabase(
      String MV, String TIME, String MVP, String MVD) async {
    final db = await database;
    await db!.rawQuery(
      "INSERT INTO mastervoltageData(MV,TIME, MVP, MVD) VALUES(?, ?, ?, ?)",
      [MV, TIME, MVP, MVD],
    );
  }

//::::::::::::::::::::: Insert data into "slavevoltageData" table ::::::::::::::::::::
  Future<void> addToSlaveDatabase(
      String SV, String TIME, String SVP, String SVD) async {
    final db = await database;
    await db!.rawQuery(
      "INSERT INTO slavevoltageData(SV,TIME, SVP, SVD) VALUES(?, ?, ?, ?)",
      [SV, TIME, SVP, SVD],
    );
  }

  //::::::::::::::::::::::: Get all data from "mastervoltageData" table ::::::::::::::::::::::
  Future<List<MasterDBmodel>> getAllDataFromMasterTable() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM mastervoltageData");

    List<MasterDBmodel> list = res.isNotEmpty
        ? res.map((c) => MasterDBmodel.fromJson(c)).toList()
        : [];
    return list;
  }

  //::::::::::::::::::::::: Get latest data from "mastervoltageData" table ::::::::::::::::::::::
  Future<List<MasterDBmodel>> getLatestDataFromMasterTable(
      {String limit = "1"}) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT * FROM mastervoltageData ORDER BY id DESC LIMIT $limit");

    List<MasterDBmodel> list = res.isNotEmpty
        ? res.map((c) => MasterDBmodel.fromJson(c)).toList()
        : [];
    return list;
  }

//::::::::::::::::::::::: Get all data from "slavevoltageData" table ::::::::::::::::::::::
  Future<List<SlaveDBmodel>> getAllDataFromSlaveTable() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM slavevoltageData");

    List<SlaveDBmodel> list =
        res.isNotEmpty ? res.map((c) => SlaveDBmodel.fromJson(c)).toList() : [];
    return list;
  }

//::::::::::::::::::::::: Get latest data from "slavevoltageData" table ::::::::::::::::::::::
  Future<List<SlaveDBmodel>> getLatestDataFromSlaveTable(
      {String limit = "1"}) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT * FROM slavevoltageData ORDER BY id DESC LIMIT $limit");

    List<SlaveDBmodel> list =
        res.isNotEmpty ? res.map((c) => SlaveDBmodel.fromJson(c)).toList() : [];
    return list;
  }

  //:::::::::::::::::::::: Delete data from "mastervoltageData" table ::::::::::::::::::::
  Future<void> deleteMasterVoltageData() async {
    final db = await database;
    await db!.rawQuery("DELETE FROM mastervoltageData");
  }

//:::::::::::::::::::::: Delete data from "slavevoltageData`" table ::::::::::::::::::::
  Future<void> deleteSlaveVoltageData() async {
    final db = await database;
    await db!.rawQuery("DELETE FROM slavevoltageData");
  }
}
