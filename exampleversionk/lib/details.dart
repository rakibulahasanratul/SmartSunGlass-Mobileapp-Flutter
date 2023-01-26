import 'package:flutter/material.dart';
import 'db/model/master_table_model.dart';
import 'db/model/slave_table_model.dart';
import 'db/service/database_service.dart';

class Detailspage extends StatefulWidget {
  const Detailspage({Key? key}) : super(key: key);

  @override
  State<Detailspage> createState() => _DetailspageState();
}

class _DetailspageState extends State<Detailspage> {
  List<MasterDBmodel> masterdetails = [];
  List<SlaveDBmodel> slavedetails = [];
  var databaseService =
      DatabaseService.instance; //Database instance initialization
  bool isLoadingMaster = true;
  bool isLoadingSlave = true;

  Future<void> getMasterFromDatabase() async {
    List<MasterDBmodel> masterFromDb =
        await databaseService.getLatestDataFromMasterTable(
            limit:
                '3'); //This line is loading the latest data from the master table. The row is configurable and changes is require in the database query
    setState(() {
      masterdetails =
          masterFromDb; //loading the data in the declared list mastervoldataDateShow[]
      isLoadingMaster = false;
    });
  }

  Future<void> getSlaveFromDatabase() async {
    List<SlaveDBmodel> slaveFromDb = await databaseService
        .getLatestDataFromSlaveTable(); //This line is loading the latest data from the slave table. The row is configurable and changes is require in the database query
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
              masterdetails[i].MV,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              masterdetails[i].TIME,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(masterdetails[i].MVP).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(masterdetails[i].MVD).toStringAsFixed(2),
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
              slavedetails[i].SV,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              slavedetails[i].TIME,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(slavedetails[i].SVP).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(slavedetails[i].SVD).toStringAsFixed(2),
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details Voltage Data')),
      body: Column(
        children: [
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
    );
  }
}
