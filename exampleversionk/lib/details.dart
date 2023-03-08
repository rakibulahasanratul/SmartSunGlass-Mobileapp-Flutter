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
  List<CentralDBmodel> centraldetails = [];
  List<PeripheralDBmodel> peripheraldetails = [];
  var databaseService =
      DatabaseService.instance; //Database instance initialization
  bool isLoadingCentral = true;
  bool isLoadingPeripheral = true;

  Future<void> getCentralFromDatabase() async {
    List<CentralDBmodel> centralFromDb =
        await databaseService.getLatestDataFromCentralTable(
            limit:
                '3'); //This line is loading the latest data from the master table. The row is configurable and changes is require in the database query
    setState(() {
      centraldetails =
          centralFromDb; //loading the data in the declared list mastervoldataDateShow[]
      isLoadingCentral = false;
    });
  }

  Future<void> getPeripheralFromDatabase() async {
    List<PeripheralDBmodel> peripheralFromDb =
        await databaseService.getLatestDataFromPeripheralTable(
            limit:
                '3'); //This line is loading the latest data from the slave table. The row is configurable and changes is require in the database query
    setState(() {
      peripheraldetails =
          peripheralFromDb; //loading the data in the declared list slavevoldataDateShow[]
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
