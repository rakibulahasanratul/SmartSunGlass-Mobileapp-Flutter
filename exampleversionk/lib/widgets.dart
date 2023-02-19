import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'battery_charge_painter.dart';
import 'db/model/master_table_model.dart'; //master database model initialize
import 'db/model/slave_table_model.dart'; //slave database model initialize
import 'db/service/database_service.dart';
import 'details.dart'; //database service initilize include
//import 'package:battery_plus/battery_plus.dart'; //Battey widget package

//modificationg
class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() {
    return _DeviceScreenPageState();
  }
}

class _DeviceScreenPageState extends State<DeviceScreen> {
  double _glassSliderValue = 0; //for Glass Controller, default is 0
  double masterBatterypercentage =
      0; // Initializing masterbattery percentage value
  double slaveBatterypercentage =
      0; //Initializing slavebattery percentage value
  var databaseService =
      DatabaseService.instance; //Database instance initialization
  bool isLoadingMaster = true; //Master data loader
  bool isLoadingSlave = true; //Slave data loader
  Timer? mastertimer; // Timer declaration for master voltage load
  Timer? slavetimer; // Timer declaration for slave voltage load

  List<MasterDBmodel> mastervoldataDateShow =
      []; //List declaration w.r.t master database model class
  List<SlaveDBmodel> slavevoldataDateShow =
      []; //List declaration w.r.t slave database model class

// Function for getting data from master table and view in the front end app.
  Future<void> getMasterFromDatabase() async {
    List<MasterDBmodel> masterFromDb = await databaseService
        .getLatestDataFromMasterTable(); //This line is loading the latest data from the master table. The row is configurable and changes is require in the database query
    setState(() {
      mastervoldataDateShow =
          masterFromDb; //loading the data in the declared list mastervoldataDateShow[]
      isLoadingMaster = false;
    });
  }

// Function for getting data from slave table and view in the front end app.
  Future<void> getSlaveFromDatabase() async {
    List<SlaveDBmodel> slaveFromDb = await databaseService
        .getLatestDataFromSlaveTable(); //This line is loading the latest data from the slave table. The row is configurable and changes is require in the database query
    setState(() {
      slavevoldataDateShow =
          slaveFromDb; //loading the data in the declared list slavevoldataDateShow[]
      isLoadingSlave = false;
    });
  }

//This function calculating the difference of master voltage to the previous voltage.Datasource master voltage table
  Future<double> getmasterDifferenceValue(double mastervoltage) async {
    double difference = 0.0;
    List<MasterDBmodel> masterFromDb = await databaseService
        .getAllDataFromMasterTable(); //This line loading all the master data in the list for difference calculation
    int index = masterFromDb.length - 1;
    if (masterFromDb.isEmpty) {
      difference = mastervoltage -
          mastervoltage; //data table 1st row diffence calculation
    } else {
      difference = mastervoltage -
          double.parse(masterFromDb[index]
              .MV); //data table all row's diffence calculation except 1st row
      //log(masterFromDb[index].MV);
    }
    return difference;
  }

//This function calculating the difference of slave voltage to the previous voltage. Datasource slave voltage table
  Future<double> getslaveDifferenceValue(double slavevoltage) async {
    double difference = 0.0;
    List<SlaveDBmodel> slaveFromDb = await databaseService
        .getAllDataFromSlaveTable(); //This line loading all the master data in the list for difference calculation
    int index = slaveFromDb.length - 1;
    if (slaveFromDb.isEmpty) {
      difference =
          slavevoltage - slavevoltage; //data table 1st row diffence calculation
    } else {
      difference = slavevoltage -
          double.parse(slaveFromDb[index]
              .SV); //data table all row's diffence calculation except 1st row
      log(slaveFromDb[index].SV);
    }
    return difference;
  }

  @override
  void initState() {
    getBatteryVoltage();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    mastertimer!.cancel(); //master timer cancellation once app not in use
    slavetimer!.cancel(); //slave timer cancellation once app not in use
  }

//This function
  List<DataRow> getMasterTableValues() {
    List<DataRow> rows = [];
    for (var i = 0; i < mastervoldataDateShow.length; i++) {
      rows.add(
        DataRow(
          cells: <DataCell>[
            /*DataCell(Text(
              mastervoldataDateShow[i].MV,
              textAlign: TextAlign.center,
            )),*/
            DataCell(Text(
              mastervoldataDateShow[i].TIME,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(mastervoldataDateShow[i].MVP).toString(),
              textAlign: TextAlign.center,
            )),
            /*DataCell(Text(
              double.parse(mastervoldataDateShow[i].MVD).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),*/
          ],
        ),
      );
    }
    return rows;
  }

  //Newly added
  List<DataRow> getSlaveTableValues() {
    List<DataRow> rows = [];
    for (var i = 0; i < slavevoldataDateShow.length; i++) {
      rows.add(
        DataRow(
          cells: <DataCell>[
            /*DataCell(Text(
              slavevoldataDateShow[i].SV,
              textAlign: TextAlign.center,
            )),*/
            DataCell(Text(
              slavevoldataDateShow[i].TIME,
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              double.parse(slavevoldataDateShow[i].SVP).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),
            /*DataCell(Text(
              double.parse(slavevoldataDateShow[i].SVD).toStringAsFixed(2),
              textAlign: TextAlign.center,
            )),*/
          ],
        ),
      );
    }
    return rows;
  }

  String getCurrentDateTime() {
    var now = DateTime.now();
    //var month = now.month.toString().padLeft(2, '0');
    // var day = now.day.toString().padLeft(2, '0');
    var hour = now.hour.toString().padLeft(2, '0');
    var minute = now.minute.toString().padLeft(2, '0');
    var seconds = now.second.toString().padLeft(2, '0');
    var formattedDate = '$hour:$minute:$seconds';
    return formattedDate;
  }

  String getCharacter4Value(List<BluetoothService> services) {
    print("😊services: ${services.toString()}");
    if (services.length >= 4) {
      BluetoothService service4 = services[3];
      print("😊service4 charaters: ${service4.characteristics}");
      if (service4.characteristics.isNotEmpty &&
          service4.characteristics.length >= 4) {
        BluetoothCharacteristic character4 = service4.characteristics[3];
        return character4.value.toString();
      }
    } else {
      return "⚠️service4 is empty!";
    }
    return "⚠️service4 - character4 is empty!";
  }

//Method to get master voltage parameter from the prototype

  Future<int> getmvcharacter2Value(List<BluetoothService> services) async {
    List service4ListIntermediate =
        []; // create list to temporarily hold service4List data
    List service4List =
        []; // creates list to hold the final values of the service 4 characteristics
    int service4Characteristic1 =
        -1; // initializes the value of characteristic 2 (master voltage) of service 4
    bool isReading = false;

    // this if statement checks if there are four services and executes the for-loop if there are
    if (services.length >= 4) {
      BluetoothService service4 = services[3]; // assigns service 4
      var service4Characteristics = service4
          .characteristics; // places all the characteristics of service 4 into a Characteristics list
      var character3uuid = service4Characteristics[1].uuid;
      //print('character 4 service uuid: $character3uuid');

      // this for-loop obtains the value of each characteristic and puts it into a list called value
      if (isReading == false) {
        for (BluetoothCharacteristic c in service4Characteristics) {
          if (c.properties.read && c.uuid == character3uuid)
          //Char3 is assigned for master voltage. Service id: 55441004-3322-1100-0000-000000000000
          /*(c.properties.read &&
                  c.uuid == Guid('55441003-3322-1100-0000-000000000000'))*/
          {
            isReading = true;
            List<int> value = await c.read(); // adds the c value to the list
            log('service4Characteristic: ${value}');
            service4ListIntermediate.add(value);
            log('master service4ListIntermediate list : ${service4ListIntermediate}');
          }
        }
      }
      // at this point, there is likely at least two lists in service4ListIntermediate, one of which does not have all the data we need
      service4List = service4ListIntermediate[
          0]; // obtains the first list from the list of lists. This list has all the data we need
      //service4List = ["A1", 05, 6, 2];
      print('master service4List: ${service4List}');
      service4Characteristic1 = service4List.elementAt(0) * 256 +
          (service4List.elementAt(
              1)); // obtains the elements from the service 4 characteristics list. They is already in base 10. THe second element in the list is multiplied by 256 to give its true ADC measured value
      print('master service4Characteristic1: ${service4Characteristic1}');

      // this if-statement checks if the service4Characteristic1 received a value or not, and returns the service4Characteristic1 value if it did
      if (service4Characteristic1 != -1) {
        return service4Characteristic1;
      }
    } else {
      return -1;
    }
    return -1;
  }

  Future<int> getpvcharacter2Value(List<BluetoothService> services) async {
    List service4ListIntermediate =
        []; // create list to temporarily hold service4List data

    List service4List = [];
    int service4Characteristic1 =
        -1; // initializes the value of characteristic 2 (master voltage) of service 4
    bool isReading = false;

    // this if statement checks if there are four services and executes the for-loop if there are
    if (services.length >= 4) {
      BluetoothService service4 = services[3]; // assigns service 4
      var service4Characteristics = service4
          .characteristics; // places all the characteristics of service 4 into a Characteristics list
      var character2uuid = service4Characteristics[1].uuid;
      print('character 2 service uuid: $character2uuid');
      // this for-loop obtains the value of each characteristic and puts it into a list called value
      if (isReading == false) {
        for (BluetoothCharacteristic c in service4Characteristics) {
          if (c.properties.read && c.uuid == character2uuid)
          //Char2 is assigned for peripheral voltage. Service id: 55441002-3322-1100-0000-000000000000
          // (c.properties.read &&
          //     c.uuid == Guid('55441002-3322-1100-0000-000000000000'))
          {
            //isReading = true;
            List<int> value = await c.read(); // adds the c value to the list
            log('service4Characteristic: ${value}');
            service4ListIntermediate.add(value);
            log('slave service4ListIntermediate list : ${service4ListIntermediate}');
          }
        }
      }

      service4List = service4ListIntermediate[0];
      service4Characteristic1 = service4List.elementAt(0) * 256 +
          (service4List.elementAt(
              1)); // obtains the elements from the service 4 characteristics list. They is already in base 10. THe second element in the list is multiplied by 256 to give its true ADC measured value
      log('service4Characteristic1: ${service4Characteristic1}');

      // this if-statement checks if the service4Characteristic1 received a value or not, and returns the service4Characteristic1 value if it did
      if (service4Characteristic1 != -1) {
        return service4Characteristic1;
      }
    } else {
      return -1;
    }
    return -1;
  }

  getMasterVoltage(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    try {
      int _mvcharacter2Value = await getmvcharacter2Value(
          services); // assigns the returned master voltage value to a variable
      //print('_mvcharacter2Value = ${_mvcharacter2Value + 100}');
      var mvcv = _mvcharacter2Value / 1000;
      print('mvcv = ${mvcv}');
      var mvmax = 4.4;
      var mvmin = 3;
      //var mvmax = 1.25;
      //var mvmin = 0.5;
      //setState use so that the value change after the initial value assignment
      setState(() {
        masterBatterypercentage = ((mvcv - mvmin) / (mvmax - mvmin)) * 100;
      });
      log('Master Battery Percentage: $masterBatterypercentage');
      double difference = await getmasterDifferenceValue(mvcv);
      await databaseService.addToMasterDatabase(
        mvcv.toString(),
        getCurrentDateTime(),
        masterBatterypercentage.toString(),
        difference.toString(),
      );
      await getMasterFromDatabase();
      print('Successfully master data loaded in the database');
      return masterBatterypercentage;
    } catch (err) {
      print('Caught Error: $err');
    }
  }

  getSlaveVoltage(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    try {
      int _pvcharacter2Value = await getpvcharacter2Value(
          services); // assigns the returned master voltage value to a variable
      print('_pvcharacter2Value = ${_pvcharacter2Value + 100}');
      var pvcv = (_pvcharacter2Value + 100) /
          1000; // converts returned future hexadecimal data type method to a double
      //var pvcv = _pvcharacter2Value;
      print('pvcv = ${pvcv}');
      var pvmax = 4.4;
      var pvmin = 3;
      //var pvmax = 1.25;
      // var pvmin = 0.5;
      setState(() {
        slaveBatterypercentage = ((pvcv - pvmin) / (pvmax - pvmin)) * 100;
      });
      log('Slave Battery Percentage: $slaveBatterypercentage');
      double difference = await getslaveDifferenceValue(pvcv);
      await databaseService.addToSlaveDatabase(
        pvcv.toStringAsFixed(2),
        getCurrentDateTime(),
        slaveBatterypercentage.toString(),
        difference.toString(),
      );
      await getSlaveFromDatabase();
      print('Successfully Slave data loaded in the database');
      return slaveBatterypercentage;
    } catch (err) {
      print('Caught Error: $err');
    }
  }

  getBatteryVoltage() {
    slavetimer = Timer.periodic(
        Duration(
          seconds: 5,
        ), (timer) {
      getSlaveVoltage(widget.device);
      log("Slave Timer Working");
      //return timer.cancel();
    });
    mastertimer = Timer.periodic(
        Duration(
          seconds: 10,
        ), (timer) {
      log("Master Timer Working");
      getMasterVoltage(widget.device);

      //return timer.cancel();
    });
  }

// Method to send hex value to Char3 for PWM or Light Sensor control
  void sendHexValue({
    required List<BluetoothService> services,
    required int hexValue,
  }) {
    setState(() {
      if (services.length >= 4) {
        BluetoothService service4 = services[3];
        if (service4.characteristics.isNotEmpty) {
          service4.characteristics[3].write([hexValue]);
        }
      }
    });
  }

  Widget _buildServiceTiles(List<BluetoothService> services) {
    return Column(
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(4.0),
              textStyle: const TextStyle(fontSize: 20),
              //backgroundColor: Colors.black,
            ),
            child: Text("PWM"),
            onPressed: () {
              sendHexValue(services: services, hexValue: 0x01);
              log('0x01 hex value successfully sent to master board');
            }),
        SizedBox(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(4.0),
              textStyle: const TextStyle(fontSize: 20),
              //backgroundColor: Colors.black,
            ),
            child: Text("LIGHT SENSOR"),
            onPressed: () {
              sendHexValue(services: services, hexValue: 0x02);
              log('0x02 hex value successfully sent to master board');
            }),
        SizedBox(height: 20),
        Container(
          child: Text("Glass Controller", style: TextStyle(fontSize: 20)),
        ),
        Slider(
            value: _glassSliderValue,
            onChanged: (double value) {
              setState(() {
                _glassSliderValue = value;
                log('Glass Controller value changed: $value');
                if (services.length >= 4) {
                  BluetoothService service4 = services[3];
                  if (service4.characteristics.isNotEmpty) {
                    service4.characteristics[0].write([value.toInt()]);
                  }
                }
              });
            },
            min: 0,
            max: 128,
            divisions: 128,
            thumbColor: Colors.deepPurple,
            label: '$_glassSliderValue'),
        // SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                /*ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF00425A),
                    padding: const EdgeInsets.all(4.0),
                    textStyle: const TextStyle(fontSize: 20),
                    //backgroundColor: Colors.black,
                  ),
                  child: Text("Battery"), //slave voltage start
                  onPressed: () {
                    slavetimer = Timer.periodic(
                        Duration(
                          seconds: 5,
                        ), (timer) {
                      getSlaveVoltage(widget.device);
                      log("Slave Timer Working");
                      //return timer.cancel();
                    });
                    mastertimer = Timer.periodic(
                        Duration(
                          seconds: 65,
                        ), (timer) {
                      log("Master Timer Working");
                      getMasterVoltage(widget.device);

                      //return timer.cancel();
                    });
                  },
                ),*/
                /* isLoadingSlave == true
                    ? Container()
                    : Column(
                        children: [
                          /*Container(
                            child: (Icon(Icons.battery_charging_full,
                                size: 150,
                                color:
                                    double.parse(slavevoldataDateShow[0].SVP) >
                                            20
                                        ? Colors.green
                                        : Colors.red)),
                          ),*/
                          RotatedBox(
                            quarterTurns: -1,
                            child: CustomPaint(
                              size: const Size(150, 150),
                              painter: CustomBatteryPainter(
                                charge:
                                    double.parse(slavevoldataDateShow[0].SVP) <
                                            0
                                        ? 0
                                        : double.parse(
                                                slavevoldataDateShow[0].SVP) +
                                            250,
                                batteryColor: Colors.green,
                              ),
                            ),
                          ),
                          Text(
                              "${double.parse(slavevoldataDateShow[0].SVP).toStringAsFixed(0)}" +
                                  "%"),
                        ],
                      ),*/
              ],
            ),
            /*Column(
              children: [
                /*ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF00425A),
                    padding: const EdgeInsets.all(4.0),
                    textStyle: const TextStyle(fontSize: 20),
                    //backgroundColor: Colors.black,
                  ),
                  child: Text("RIGHT"), //master voltage start
                  onPressed: () {
                    mastertimer = Timer.periodic(
                        Duration(
                          seconds: 5,
                        ), (timer) {
                      log("Timer Working");
                      getMasterVoltage(widget.device);

                      //return timer.cancel();
                    });
                  },
                ),*/
                /*isLoadingMaster == true
                    ? Container()
                    : Column(
                        children: [
                          Container(
                            // width: 150,
                            // height: 150,

                            // ignore: prefer_const_constructors
                            child: (Icon(Icons.battery_charging_full,
                                size: 150,
                                color:
                                    double.parse(mastervoldataDateShow[0].MVP) >
                                            20
                                        ? Colors.green
                                        : Colors.red)),
                          ),
                          Text(
                              "${double.parse(mastervoldataDateShow[0].MVP).toStringAsFixed(0)}" +
                                  "%"),
                        ],
                      ),*/
              ],
            ),*/
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Detailspage()));
            },
            child: Text('Details...')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => widget.device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => widget.device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.blue),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/AMIlogoWEBP.webp',
                  height: 60,
                  width: 60,
                ),
                //Spacer(),
                Row(
                  children: [
                    isLoadingSlave == true
                        ? Container()
                        : Column(
                            children: [
                              /*Container4
                            child: (Icon(Icons.battery_charging_full,
                                size: 150,
                                color:
                                    double.parse(slavevoldataDateShow[0].SVP) >
                                            20
                                        ? Colors.green
                                        : Colors.red)),
                          ),*/
                              Text(
                                "L",
                                style: TextStyle(
                                    fontSize: 6, fontWeight: FontWeight.bold),
                              ),
                              RotatedBox(
                                quarterTurns: -1,
                                child: CustomPaint(
                                  size: const Size(40, 40),
                                  painter: CustomBatteryPainter(
                                    charge: double.parse(
                                        slavevoldataDateShow[0].SVP),
                                    batteryColor: (double.parse(
                                                    slavevoldataDateShow[0]
                                                        .SVP) <
                                                20 &&
                                            double.parse(slavevoldataDateShow[0]
                                                    .SVP) >=
                                                0)
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                              Text(
                                  "${double.parse(slavevoldataDateShow[0].SVP).toStringAsFixed(0)}" +
                                      "%",
                                  style: TextStyle(fontSize: 6)),
                            ],
                          ),
                    isLoadingMaster == true
                        ? Container()
                        : Column(
                            children: [
                              /*Container(
                            child: (Icon(Icons.battery_charging_full,
                                size: 150,
                                color:
                                    double.parse(slavevoldataDateShow[0].SVP) >
                                            20
                                        ? Colors.green
                                        : Colors.red)),
                          ),*/
                              Text(
                                "R",
                                style: TextStyle(
                                    fontSize: 6, fontWeight: FontWeight.bold),
                              ),
                              RotatedBox(
                                quarterTurns: -1,
                                child: CustomPaint(
                                  size: const Size(40, 40),
                                  painter: CustomBatteryPainter(
                                    charge: double.parse(
                                        mastervoldataDateShow[0].MVP),
                                    batteryColor: (double.parse(
                                                    mastervoldataDateShow[0]
                                                        .MVP) <
                                                20 &&
                                            double.parse(
                                                    mastervoldataDateShow[0]
                                                        .MVP) >=
                                                0)
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                              Text(
                                  "${double.parse(mastervoldataDateShow[0].MVP).toStringAsFixed(0)}" +
                                      "%",
                                  style: TextStyle(fontSize: 6)),
                            ],
                          ),
                  ],
                )
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
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${widget.device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: widget.device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      /*TextButton(
                        child: Text("Show Services"),
                        onPressed: () => widget.device.discoverServices(),
                      ),
                      TextButton(
                        child: Text("Get Voltage"),
                        onPressed: () => getMasterVoltage(widget.device),
                      ),*/
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                return _buildServiceTiles(snapshot.data!);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Image.asset(
        'assets/images/Miami_OH_JPG.jpg',
        height: 60,
        width: 60,
      ),
    );
  }
}
