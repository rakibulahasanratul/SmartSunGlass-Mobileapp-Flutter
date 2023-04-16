// This dart file is the redirected page when user press the details button in the application page.

//************************Main Idea Start************************//
// This page uses the central and peripheral dbmodel and database_service
// to show last three central and peripheral voltage value.
//************************Main Idea End************************//

//************************Workflow w.r.t written methods************************//
// getCentralFromDatabase()--> getCentraldetails() --> isLoadingCentral --> Datatable -->getCentraldetails()
// getPeripheralFromDatabase()--> getPeripheraldetails() --> isLoadingPeripheral --> Datatable -->getPeripheraldetails()

import 'package:flutter/material.dart';
import 'data_encryption.dart';
import 'db/model/central_table_model.dart';
import 'db/model/peripheral_table_model.dart';
import 'db/service/database_service.dart';

class Detailspage extends StatefulWidget {
  const Detailspage({Key? key}) : super(key: key);

  @override
  State<Detailspage> createState() => _DetailspageState();
}

class _DetailspageState extends State<Detailspage> {
  List<CentralDBmodel> centraldetails = [];
  List<PeripheralDBmodel> peripheraldetails = [];
  var databaseService =
      DatabaseService.instance; //Database instance initialization
  bool isLoadingCentral = true;
  bool isLoadingPeripheral = true;
  DataEncryption encryptionController = DataEncryption.instance;

  Future<void> getCentralFromDatabase() async {
    List<CentralDBmodel> centralcrypt = [];
    List<CentralDBmodel> centralFromDb =
        await databaseService.getLatestDataFromCentralTable(limit: '3');
    //This line is loading the latest data from the master table. The row is configurable and changes is require in the database query
    for (var i = 0; i < centralFromDb.length; i++) {
      String cv = await encryptionController.dencryptData(
          textToDencrypt: centralFromDb[i].CV);
      String time = await encryptionController.dencryptData(
          textToDencrypt: centralFromDb[i].TIME);
      String cvp = await encryptionController.dencryptData(
          textToDencrypt: centralFromDb[i].CVP);
      String cvd = await encryptionController.dencryptData(
          textToDencrypt: centralFromDb[i].CVD);
      centralcrypt.add(CentralDBmodel(
          id: centralFromDb[i].id, CV: cv, TIME: time, CVP: cvp, CVD: cvd));
    }
    setState(() {
      centraldetails =
          centralcrypt; //loading the data in the declared list mastervoldataDateShow[]
      isLoadingCentral = false;
    });
  }

  Future<void> getPeripheralFromDatabase() async {
    List<PeripheralDBmodel> peripheralcrypt = [];
    List<PeripheralDBmodel> peripheralFromDb =
        await databaseService.getLatestDataFromPeripheralTable(
            limit:
                '3'); //This line is loading the latest data from the slave table. The row is configurable and changes is require in the database query
    for (var i = 0; i < peripheralFromDb.length; i++) {
      String pv = await encryptionController.dencryptData(
          textToDencrypt: peripheralFromDb[i].PV);
      String time = await encryptionController.dencryptData(
          textToDencrypt: peripheralFromDb[i].TIME);
      String pvp = await encryptionController.dencryptData(
          textToDencrypt: peripheralFromDb[i].PVP);
      String pvd = await encryptionController.dencryptData(
          textToDencrypt: peripheralFromDb[i].PVD);
      peripheralcrypt.add(PeripheralDBmodel(
          id: peripheralFromDb[i].id, PV: pv, TIME: time, PVP: pvp, PVD: pvd));
    }
    setState(() {
      peripheraldetails =
          peripheralcrypt; //loading the data in the declared list slavevoldataDateShow[]
      isLoadingPeripheral = false;
    });
  }

  //This function
  List<DataRow> getCentraldetails() {
    List<DataRow> rows = [];
    for (var i = 0; i < centraldetails.length; i++) {
      rows.add(
        DataRow(
          cells: <DataCell>[
            DataCell(Text(
              centraldetails[i].CV,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              centraldetails[i].TIME,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(centraldetails[i].CVP).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(centraldetails[i].CVD).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      );
    }
    return rows;
  }

  //Newly added
  List<DataRow> getPeripheraldetails() {
    List<DataRow> rows = [];
    for (var i = 0; i < peripheraldetails.length; i++) {
      rows.add(
        DataRow(
          cells: <DataCell>[
            DataCell(Text(
              peripheraldetails[i].PV,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              peripheraldetails[i].TIME,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(peripheraldetails[i].PVP).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(peripheraldetails[i].PVD).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      );
    }
    return rows;
  }

  @override
  void initState() {
    getCentralFromDatabase();
    getPeripheralFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details Voltage Data')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/AMIlogoWEBP.webp',
                height: 60,
                width: 60,
              ),
            ],
          ),
          ElevatedButton(onPressed: () {}, child: Text('LEFT')),
          isLoadingCentral
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : DataTable(
                  columnSpacing: 30,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Voltage',
                          style: TextStyle(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Time',
                          style: TextStyle(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Percentage',
                          style: TextStyle(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Difference',
                          style: TextStyle(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  rows: getCentraldetails(),
                ),
          ElevatedButton(onPressed: () {}, child: Text('RIGHT')),
          isLoadingPeripheral == true
              ? Container()
              : DataTable(
                  columnSpacing: 30,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Voltage',
                          style: TextStyle(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Time',
                          style: TextStyle(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Percentage',
                          style: TextStyle(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Difference',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ],
                  rows: getPeripheraldetails(),
                ),
        ],
      ),
      floatingActionButton: Image.asset(
        'assets/images/Miami_OH_JPG.jpg',
        height: 60,
        width: 60,
      ),
    );
  }
}
