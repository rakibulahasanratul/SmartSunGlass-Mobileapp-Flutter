// This contain the operating propertise of the entire mobile app.
// Basic skeleton is

//AMI LOGO                 Peripheral(Char2) and Central(Char3) battery icon
//Device connection status
//                 **     PWM      **  Once press it send 0x01 to Char4.
//                 ** Glass Slider **  Once change it gives the PWM duty cycle value to char1.
//                 ** LIGHT SENSOR **  Once press it send the 0x02 to Char4.
//                 **Details Button**  Once press it will redirect to another page.

//**************characteristic service details start****************************
//char1_PWM:55441001-3322-1100-0000-000000000000
//char2_Peripheral_Voltage:55441002-3322-1100-0000-000000000000
//char3_Central_Voltage:55441003-3322-1100-0000-000000000000
//char4_Control_Code:55441004-3322-1100-0000-000000000000
//char5_Light_Sensor_Value:55441005-3322-1100-0000-000000000000
//**************characteristic service details end******************************

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'battery_charge_painter.dart';
import 'data_encryption.dart';
import 'db/model/central_table_model.dart'; //central database model initialize
import 'db/model/peripheral_table_model.dart'; //peripheral database model initialize
import 'db/service/database_service.dart'; // database serice with seperate sql query for different method
import 'details.dart'; //database service initilize include

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
  double centralBatterypercentage =
      0; // Initializing central battery percentage value
  double peripheralBatterypercentage =
      0; //Initializing peripheral battery percentage value
  var databaseService =
      DatabaseService.instance; //Database instance initialization
  bool isLoadingCentral = true; //Central data loader
  bool isLoadingPeripheral = true; //Peripheral data loader
  Timer? centraltimer; // Timer declaration for central voltage load
  Timer? peripheraltimer; // Timer declaration for peripheral voltage load
  DataEncryption encryptionController = DataEncryption.instance;

  List<CentralDBmodel> centralvoldataDateShow =
      []; //List declaration w.r.t central database model class
  List<PeripheralDBmodel> peripheralvoldataDateShow =
      []; //List declaration w.r.t peripheral database model class

// Function for getting data from central table and view in the front end app.
  Future<void> getCentralFromDatabase() async {
    List<CentralDBmodel> centralcrypt = [];
    List<CentralDBmodel> centralFromDb =
        await databaseService.getLatestDataFromCentralTable();
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
    } //This line is loading the latest data from the central table. The row is configurable and changes is require in the database query
    setState(() {
      centralvoldataDateShow =
          centralcrypt; //loading the data in the declared list centralvoldataDateShow[]
      isLoadingCentral = false;
    });
  }

// Function for getting data from peripheral table and view in the front end app.
  Future<void> getPeripheralFromDatabase() async {
    List<PeripheralDBmodel> peripheralcrypt = [];
    List<PeripheralDBmodel> peripheralFromDb = await databaseService
        .getLatestDataFromPeripheralTable(); //This line is loading the latest data from the peripheral table. The row is configurable and changes is require in the database query
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
      peripheralvoldataDateShow =
          peripheralcrypt; //loading the data in the declared list peripheralvoldataDateShow[]
      isLoadingPeripheral = false;
    });
  }

//This function calculating the difference of central voltage to the previous voltage.Datasource central voltage table
  Future<double> getcentralDifferenceValue(double centralvoltage) async {
    double difference = 0.0;
    List<CentralDBmodel> centralFromDb = await databaseService
        .getAllDataFromCentralTable(); //This line loading all the central data in the list for difference calculation
    int index = centralFromDb.length - 1;
    if (centralFromDb.isEmpty) {
      difference = centralvoltage -
          centralvoltage; //data table 1st row diffence calculation
    } else {
      String cv = await encryptionController.dencryptData(
          textToDencrypt: centralFromDb[index].CV);
      difference = centralvoltage -
          double.parse(
              cv); //data table all row's diffence calculation except 1st row
    }
    return difference;
  }

//This function calculating the difference of peripheral voltage to the previous voltage. Datasource peripheral voltage table
  Future<double> getPeripheralDifferenceValue(double peripheralvoltage) async {
    double difference = 0.0;
    List<PeripheralDBmodel> peripheralFromDb = await databaseService
        .getAllDataFromPeripheralTable(); //This line loading all the peripheral data in the list for difference calculation
    int index = peripheralFromDb.length - 1;
    if (peripheralFromDb.isEmpty) {
      difference = peripheralvoltage -
          peripheralvoltage; //data table 1st row diffence calculation
    } else {
      String pv = await encryptionController.dencryptData(
          textToDencrypt: peripheralFromDb[index].PV);
      difference = peripheralvoltage -
          double.parse(
              pv); //data table all row's diffence calculation except 1st row
      log(peripheralFromDb[index].PV);
    }
    return difference;
  }

//battery voltage initiation in the inistate so that voltage update happen instantly when page load
  @override
  void initState() {
    getBatteryVoltage();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    centraltimer!.cancel(); //central timer cancellation once app not in use
    peripheraltimer!
        .cancel(); //peripheral timer cancellation once app not in use
  }

//method to have central and peripheral table time
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

//Method to get central voltage parameter from the remote device

  Future<int> getcvcharacter2Value(List<BluetoothService> services) async {
    List service4ListIntermediate =
        []; // create list to temporarily hold service4List data
    List service4List =
        []; // creates list to hold the final values of the service 4 characteristics
    int service4Characteristic1 =
        -1; // initializes the value of characteristic 2 (central voltage) of service 4
    bool isReading = false;

    // this if statement checks if there are four services and executes the for-loop if there are
    if (services.length >= 4) {
      BluetoothService service4 = services[3]; // assigns service 4
      var service4Characteristics = service4
          .characteristics; // places all the characteristics of service 4 into a Characteristics list
      // this for-loop obtains the value of each characteristic and puts it into a list called value
      if (isReading == false) {
        for (BluetoothCharacteristic c in service4Characteristics) {
          if (c.properties.read &&
              c.uuid == Guid('55441003-3322-1100-0000-000000000000')) {
            isReading = true;
            List<int> value = await c.read(); // adds the c value to the list
            service4ListIntermediate.add(value);
          }
        }
      }
      // at this point, there is likely at least two lists in service4ListIntermediate, one of which does not have all the data we need
      service4List = service4ListIntermediate[
          0]; // obtains the first list from the list of lists. This list has all the data we need
      //service4List = ["A1", 05, 6, 2];
      log('central service4List: ${service4List}');
      service4Characteristic1 = service4List.elementAt(0) * 256 +
          (service4List.elementAt(
              1)); // obtains the elements from the service 4 characteristics list. They is already in base 10. THe second element in the list is multiplied by 256 to give its true ADC measured value
      log('central service4Characteristic1: ${service4Characteristic1}');

      // this if-statement checks if the service4Characteristic1 received a value or not, and returns the service4Characteristic1 value if it did
      if (service4Characteristic1 != -1) {
        return service4Characteristic1;
      }
    } else {
      return -1;
    }
    return -1;
  }

//Method to get peripheral voltage parameter from the prototype
  Future<int> getpvcharacter2Value(List<BluetoothService> services) async {
    List service4ListIntermediate =
        []; // create list to temporarily hold service4List data

    List service4List = [];
    int service4Characteristic1 =
        -1; // initializes the value of characteristic 2 (central voltage) of service 4
    bool isReading = false;

    // this if statement checks if there are four services and executes the for-loop if there are
    if (services.length >= 4) {
      BluetoothService service4 = services[3]; // assigns service 4
      var service4Characteristics = service4
          .characteristics; // places all the characteristics of service 4 into a Characteristics list
      // this for-loop obtains the value of each characteristic and puts it into a list called value
      if (isReading == false) {
        for (BluetoothCharacteristic c in service4Characteristics) {
          if (c.properties.read &&
              c.uuid == Guid('55441002-3322-1100-0000-000000000000')) {
            List<int> value = await c.read(); // adds the c value to the list
            service4ListIntermediate.add(value);
          }
        }
      }
      service4List = service4ListIntermediate[0];
      log('peripheral service4List: ${service4List}');
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

  //Method to convert collected parament value into battery percentage and load percentage,time, voltage value to central table
  getCentralVoltage(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    try {
      int _cvcharacter2Value = await getcvcharacter2Value(
          services); // assigns the returned central voltage value to a variable
      var cv = (_cvcharacter2Value + 100) / 1000;
      print('mvcv = ${cv}');
      var cvmax = 4.4;
      var cvmin = 3;
      setState(() {
        centralBatterypercentage = ((cv - cvmin) / (cvmax - cvmin)) * 100;
      });
      log('central Battery Percentage: $centralBatterypercentage');
      double difference = await getcentralDifferenceValue(cv);
      await databaseService.addToCentralDatabase(
        cv.toString(),
        getCurrentDateTime(),
        centralBatterypercentage.toString(),
        difference.toString(),
      );
      await getCentralFromDatabase();
      print('Successfully central data loaded in the database');
      return centralBatterypercentage;
    } catch (err) {
      print('Caught Error: $err');
    }
  }

//Method to convert collected parament value into battery percentage and load percentage,time, voltage value to peripheral table
  getPeripheralVoltage(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    try {
      int _pvcharacter2Value = await getpvcharacter2Value(
          services); // assigns the returned peripheral voltage value to a variable
      print('_pvcharacter2Value = ${_pvcharacter2Value + 100}');
      var pv = (_pvcharacter2Value + 100) /
          1000; // converts returned future hexadecimal data type method to a double
      print('pvcv = ${pv}');
      var pvmax = 4.4;
      var pvmin = 3;
      setState(() {
        peripheralBatterypercentage = ((pv - pvmin) / (pvmax - pvmin)) * 100;
      });
      log('Peripheral Battery Percentage: $peripheralBatterypercentage');
      double difference = await getPeripheralDifferenceValue(pv);
      await databaseService.addToPeripheralDatabase(
        pv.toStringAsFixed(2),
        getCurrentDateTime(),
        peripheralBatterypercentage.toString(),
        difference.toString(),
      );
      await getPeripheralFromDatabase();
      print('Successfully peripheral data loaded in the database');
      return peripheralBatterypercentage;
    } catch (err) {
      print('Caught Error: $err');
    }
  }

//Method to iniitate timer for central and peripheral voltage data for this page loading.
  getBatteryVoltage() {
    peripheraltimer = Timer.periodic(
        Duration(
          seconds: 60,
        ), (timer) {
      getPeripheralVoltage(widget.device);
      log("peripheral Timer Working");
    });
    centraltimer = Timer.periodic(
        Duration(
          seconds: 65,
        ), (timer) {
      log("central Timer Working");
      getCentralVoltage(widget.device);
    });
  }

// Method to send hex value to Char3 for PWM or Light Sensor control
  void sendHexValue({
    required List<BluetoothService> services,
    required int hexValue,
  }) {
    if (services.length >= 4) {
      BluetoothService service4 = services[3];
      if (service4.characteristics.isNotEmpty) {
        service4.characteristics[2].write([hexValue]);
        //Service id for control code characteristic '55441004-3322-1100-0000-000000000000'
        //log('Cha4 service UUID: ${service4.characteristics[2].uuid}');
      }
    }
  }

  Widget _buildServiceTiles(List<BluetoothService> services) {
    return Column(
      children: [
        ElevatedButton(
          child: Text('PWM', style: TextStyle(fontSize: 20)),
          onPressed: () {
            sendHexValue(services: services, hexValue: 0x01);
            log('0x01 hex value successfully sent to central');
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) return Colors.green;
                return Colors.blue;
              },
            ),
          ),
        ),
        SizedBox(height: 30),
        Container(
          child: Text("Glass Controller", style: TextStyle(fontSize: 20)),
        ),
        Slider(
            value: _glassSliderValue,
            onChanged:
                (value) {}, //Not in use but its mandatory field of slider widget.
            onChangeEnd: (double value) {
              setState(() {
                _glassSliderValue = value;
                log('Glass Controller value changed: $value');
                if (services.length >= 4) {
                  BluetoothService service4 = services[3];
                  if (service4.characteristics.isNotEmpty) {
                    service4.characteristics[0].write([value.toInt()]);
                    //Service id for control code characteristic '55441001-3322-1100-0000-000000000000'
                    log('Char1 service UUID: ${service4.characteristics[0].uuid}');
                  }
                }
              });
            },
            min: 0,
            max: 128,
            divisions: 128,
            thumbColor: Colors.deepPurple,
            label: '$_glassSliderValue'),
        SizedBox(height: 30),
        ElevatedButton(
          child: Text('LIGHT SENSOR', style: TextStyle(fontSize: 20)),
          onPressed: () {
            sendHexValue(services: services, hexValue: 0x02);
            log('0x02 hex value successfully sent to central');
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) return Colors.green;
                return Colors.blue;
              },
            ),
          ),
        ),
        SizedBox(height: 100),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Detailspage()));
            },
            child: Text(
              'Details...',
              style: TextStyle(fontSize: 10),
            )),
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
                    isLoadingPeripheral == true
                        ? Container()
                        : Column(
                            children: [
                              Text(
                                "R",
                                style: TextStyle(
                                    fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                              RotatedBox(
                                quarterTurns: -1,
                                child: CustomPaint(
                                  size: const Size(40, 40),
                                  painter: CustomBatteryPainter(
                                    charge: double.parse(
                                                peripheralvoldataDateShow[0]
                                                    .PVP) <=
                                            0
                                        ? 0
                                        : double.parse(
                                            peripheralvoldataDateShow[0].PVP),
                                    batteryColor: (double.parse(
                                                    peripheralvoldataDateShow[0]
                                                        .PVP) <
                                                15 &&
                                            double.parse(
                                                    peripheralvoldataDateShow[0]
                                                        .PVP) >=
                                                0)
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                              Text(
                                  "${double.parse(peripheralvoldataDateShow[0].PVP).toStringAsFixed(0)}" +
                                      "%",
                                  style: TextStyle(fontSize: 6)),
                            ],
                          ),
                    isLoadingCentral == true
                        ? Container()
                        : Column(
                            children: [
                              Text(
                                "L",
                                style: TextStyle(
                                    fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                              RotatedBox(
                                quarterTurns: -1,
                                child: CustomPaint(
                                  size: const Size(40, 40),
                                  painter: CustomBatteryPainter(
                                    charge: double.parse(
                                                centralvoldataDateShow[0].CV) <=
                                            0
                                        ? 0
                                        : double.parse(
                                            centralvoldataDateShow[0].CVP),
                                    batteryColor: (double.parse(
                                                    centralvoldataDateShow[0]
                                                        .CVP) <
                                                15 &&
                                            double.parse(
                                                    centralvoldataDateShow[0]
                                                        .CVP) >=
                                                0)
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                              Text(
                                  "${double.parse(centralvoldataDateShow[0].CVP).toStringAsFixed(0)}" +
                                      "%",
                                  style: TextStyle(fontSize: 6)),
                            ],
                          ),
                  ],
                )
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
