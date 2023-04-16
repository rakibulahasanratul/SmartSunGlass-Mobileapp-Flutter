// This dart file contains the database service details which used in widgets.dart, details.dart file

//************************Main Idea Start************************//

// This page creates the local database voltageData.db with two table centralvoltageData and
// peripheralvoltageData. Each table has 5 column and rows as long as the session run.

//**central*//                  methods         //**peripheral*//
// addToCentralDatabase()                       // addToPeripheralDatabase()
// getAllDataFromCentralTable()                 // getAllDataFromPeripheralTable()
// getLatestDataFromCentralTable()              // getLatestDataFromPeripheralable()
// deleteCentralVoltageData()                   // deletePeripheralVoltageData()
//************************Main Idea End************************//

import 'dart:io'; //provides APIs to deal with files, directories, processes, sockets, WebSockets, and HTTP clients and servers
import 'package:sqflite/sqflite.dart'; // package to store data in the local database
import 'package:path_provider/path_provider.dart'; //plugin for finding commonly used location of the file system.
import 'package:path/path.dart'; // path library is designed to import with a prefix
import '../../data_encryption.dart';
import '../model/central_table_model.dart'; //Central table model. Any new column is require to expose in the central table model
import '../model/peripheral_table_model.dart'; //Peripheral table model. Any new column is require to expose in the peripheral table model

//DatabaseService class initialization. This is required to init() in the main.dart
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();
  static Database? _database;
  DataEncryption encryptionController = DataEncryption.instance;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<dynamic> initDB() async {
    //Directory directory = await getApplicationDocumentsDirectory();
    Directory directory = await getVoltageDataDirectory();
    final path = join(directory.path, 'voltageData.db'); //Main database name
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      //Table creation for central voltage data. This table has 5 column.
      await db.execute('CREATE TABLE centralvoltageData('
          'id INTEGER PRIMARY KEY AUTOINCREMENT ,'
          'TIME TEXT DEFAULT "0",'
          'CV TEXT DEFAULT "0",' //CV=Central Voltage
          'CVP TEXT DEFAULT "0",' //CVP=Central Voltage Percentage
          'CVD TEXT DEFAULT "0"' //CVD=Central Voltage Difference
          ')');
      //Table creation for peripheral voltage data. This table has 4 column.
      await db.execute('CREATE TABLE peripheralvoltageData('
          'id INTEGER PRIMARY KEY AUTOINCREMENT ,'
          'TIME TEXT DEFAULT "0",'
          'PV TEXT DEFAULT "0",' //PV=Peripheral Voltage
          'PVP TEXT DEFAULT "0",' //PVP=Peripheral Voltage Percentage
          'PVD TEXT DEFAULT "0"' //PVD=Peripheral Voltage Difference
          ')');
    });
  }

  //::::::::::::::::::::: Insert data into "centralvoltageData" table ::::::::::::::::::::
  Future<void> addToCentralDatabase(
      String CV, String TIME, String CVP, String CVD) async {
    String cv = await encryptionController.encryptData(textToEncrypt: CV);
    String time = await encryptionController.encryptData(textToEncrypt: TIME);
    String cvp = await encryptionController.encryptData(textToEncrypt: CVP);
    String cvd = await encryptionController.encryptData(textToEncrypt: CVD);
    final db = await database;
    await db!.rawQuery(
      "INSERT INTO centralvoltageData(CV,TIME, CVP, CVD) VALUES(?, ?, ?, ?)",
      [cv, time, cvp, cvd],
    );
  }

//::::::::::::::::::::: Insert data into "peripheralvoltageData" table ::::::::::::::::::::
  Future<void> addToPeripheralDatabase(
      String PV, String TIME, String PVP, String PVD) async {
    String pv = await encryptionController.encryptData(textToEncrypt: PV);
    String time = await encryptionController.encryptData(textToEncrypt: TIME);
    String pvp = await encryptionController.encryptData(textToEncrypt: PVP);
    String pvd = await encryptionController.encryptData(textToEncrypt: PVD);
    final db = await database;
    await db!.rawQuery(
      "INSERT INTO peripheralvoltageData(PV,TIME, PVP, PVD) VALUES(?, ?, ?, ?)",
      [pv, time, pvp, pvd],
    );
  }

  //::::::::::::::::::::::: Get all data from "centralvoltageData" table ::::::::::::::::::::::
  Future<List<CentralDBmodel>> getAllDataFromCentralTable() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM centralvoltageData");

    List<CentralDBmodel> list = res.isNotEmpty
        ? res.map((c) => CentralDBmodel.fromJson(c)).toList()
        : [];
    return list;
  }

  //::::::::::::::::::::::: Get latest data from "centralvoltageData" table ::::::::::::::::::::::
  Future<List<CentralDBmodel>> getLatestDataFromCentralTable(
      {String limit = "1"}) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT * FROM centralvoltageData ORDER BY id DESC LIMIT $limit");

    List<CentralDBmodel> list = res.isNotEmpty
        ? res.map((c) => CentralDBmodel.fromJson(c)).toList()
        : [];
    return list;
  }

//::::::::::::::::::::::: Get all data from "peripheralvoltageData" table ::::::::::::::::::::::
  Future<List<PeripheralDBmodel>> getAllDataFromPeripheralTable() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM peripheralvoltageData");

    List<PeripheralDBmodel> list = res.isNotEmpty
        ? res.map((c) => PeripheralDBmodel.fromJson(c)).toList()
        : [];
    return list;
  }

//::::::::::::::::::::::: Get latest data from "peripheralvoltageData" table ::::::::::::::::::::::
  Future<List<PeripheralDBmodel>> getLatestDataFromPeripheralTable(
      {String limit = "1"}) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT * FROM peripheralvoltageData ORDER BY id DESC LIMIT $limit");

    List<PeripheralDBmodel> list = res.isNotEmpty
        ? res.map((c) => PeripheralDBmodel.fromJson(c)).toList()
        : [];
    return list;
  }

  //:::::::::::::::::::::: Delete data from "centralvoltageData" table ::::::::::::::::::::
  Future<void> deleteCentralVoltageData() async {
    final db = await database;
    await db!.rawQuery("DELETE FROM centralvoltageData");
  }

//:::::::::::::::::::::: Delete data from "peripheralvoltageData`" table ::::::::::::::::::::
  Future<void> deletePeripheralVoltageData() async {
    final db = await database;
    await db!.rawQuery("DELETE FROM peripheralvoltageData");
  }
}
