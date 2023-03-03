// This dart file is the redirected page when user press the details button in the application page.

//************************Main Idea Start************************//
// Syntax understanding: master=left=central || slave=right=peripheral
// This page uses the central and peripheral dbmodel and database_service
// to show last three central and peripheral voltage value.
//************************Main Idea End************************//

//************************Workflow w.r.t written methods************************//
// getMasterFromDatabase()--> getMasterdetails() --> isLoadingMaster --> Datatable -->getMasterdetails()
// getSlaveFromDatabase()--> getSlavedetails() --> isLoadingSlave --> Datatable -->getSlavedetails()

import 'package:flutter/material.dart';
import 'db/model/central_table_model.dart';
import 'db/model/peripheral_table_model.dart';
import 'db/service/database_service.dart';

class Detailspage extends StatefulWidget {
  const Detailspage({Key? key}) : super(key: key);

  @override
  State<Detailspage> createState() => _DetailspageState();
}

class _DetailspageState extends State<Detailspage> {
  List<CentralDBmodel> masterdetails = [];
  List<PeripheralDBmodel> slavedetails = [];
  var databaseService =
      DatabaseService.instance; //Database instance initialization
  bool isLoadingMaster = true;
  bool isLoadingSlave = true;

  Future<void> getMasterFromDatabase() async {
    List<CentralDBmodel> masterFromDb =
        await databaseService.getLatestDataFromCentralTable(
            limit:
                '3'); //This line is loading the latest data from the master table. The row is configurable and changes is require in the database query
    setState(() {
      masterdetails =
          masterFromDb; //loading the data in the declared list mastervoldataDateShow[]
      isLoadingMaster = false;
    });
  }

  Future<void> getSlaveFromDatabase() async {
    List<PeripheralDBmodel> slaveFromDb =
        await databaseService.getLatestDataFromPeripheralTable(
            limit:
                '3'); //This line is loading the latest data from the slave table. The row is configurable and changes is require in the database query
    setState(() {
      slavedetails =
          slaveFromDb; //loading the data in the declared list slavevoldataDateShow[]
      isLoadingSlave = false;
    });
  }

  //This function
  List<DataRow> getMasterdetails() {
    List<DataRow> rows = [];
    for (var i = 0; i < masterdetails.length; i++) {
      rows.add(
        DataRow(
          cells: <DataCell>[
            DataCell(Text(
              masterdetails[i].CV,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              masterdetails[i].TIME,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(masterdetails[i].CVP).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(masterdetails[i].CVD).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      );
    }
    return rows;
  }

  //Newly added
  List<DataRow> getSlavedetails() {
    List<DataRow> rows = [];
    for (var i = 0; i < slavedetails.length; i++) {
      rows.add(
        DataRow(
          cells: <DataCell>[
            DataCell(Text(
              slavedetails[i].PV,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              slavedetails[i].TIME,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(slavedetails[i].PVP).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(slavedetails[i].PVD).toStringAsFixed(2),
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
    getMasterFromDatabase();
    getSlaveFromDatabase();
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
              /*SizedBox(
                width: 270,
              ),
              Image.asset(
                'assets/images/Air_Force_Research_Laboratory_PNG.png',
                height: 60,
                width: 60,
              ),*/
            ],
          ),
          ElevatedButton(onPressed: () {}, child: Text('LEFT')),
          isLoadingMaster
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
                  rows: getMasterdetails(),
                ),
          ElevatedButton(onPressed: () {}, child: Text('RIGHT')),
          isLoadingSlave == true
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
                  rows: getSlavedetails(),
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
