import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
  bool ctrlmanual =
      false; //Manual PWM, operate with the value stored in characteristic 1
  bool ctrllight = false; //Light sensor mode, PWM control by light sensor.
  double masterBatterypercentage = 0;
  double slaveBatterypercentage = 0;
  @override
  void initState() {
    super.initState();
  }

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

      // this for-loop obtains the value of each characteristic and puts it into a list called value
      if (isReading == false) {
        for (BluetoothCharacteristic c in service4Characteristics) {
          if (c.properties.read) {
            isReading = true;
            List<int> value = await c.read(); // adds the c value to the list
            print('service4Characteristic: ${value.toList()}');
            service4ListIntermediate.add(
                value); // adds the 'value' list to the temporary placeholder

            print('service4ListIntermediate: ${service4ListIntermediate}');
          }
        }
      }

      // at this point, there is likely at least two lists in service4ListIntermediate, one of which does not have all the data we need
      service4List = service4ListIntermediate.elementAt(
          1); // obtains the first list from the list of lists. This list has all the data we need
      //service4List = ["A1", 05, 6, 2];
      service4Characteristic1 = service4List.elementAt(2) +
          (service4List.elementAt(3) *
              256); // obtains the elements from the service 4 characteristics list. They is already in base 10. THe second element in the list is multiplied by 256 to give its true ADC measured value
      print('service4Characteristic1: ${service4Characteristic1}');

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

      // this for-loop obtains the value of each characteristic and puts it into a list called value
      if (isReading == false) {
        for (BluetoothCharacteristic c in service4Characteristics) {
          if (c.properties.read) {
            isReading = true;
            List<int> value = await c.read(); // adds the c value to the list
            print('service4Characteristic: ${value.toList()}');
            service4ListIntermediate.add(
                value); // adds the 'value' list to the temporary placeholder

            print('service4ListIntermediate: ${service4ListIntermediate}');
          }
        }
      }

      // at this point, there is likely at least two lists in service4ListIntermediate, one of which does not have all the data we need
      service4List = service4ListIntermediate.elementAt(
          1); // obtains the first list from the list of lists. This list has all the data we need
      //service4List = ["A1", 05, 6, 2];
      service4Characteristic1 = service4List.elementAt(0) +
          (service4List.elementAt(1) *
              256); // obtains the elements from the service 4 characteristics list. They is already in base 10. THe second element in the list is multiplied by 256 to give its true ADC measured value
      print('service4Characteristic1: ${service4Characteristic1}');

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
      print('_mvcharacter2Value = ${_mvcharacter2Value + 100}');
      var mvcv = _mvcharacter2Value / 1000;
      print('mvcv = ${mvcv}');
      var mvmax = 4.4;
      var mvmin = 3;
      masterBatterypercentage = ((mvcv - mvmin) / (mvmax - mvmin)) * 100;
      print('Master Battery Percentage: $masterBatterypercentage');
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
      print('_mvcharacter2Value = ${_pvcharacter2Value + 100}');
      var pvcv = _pvcharacter2Value /
          1000; // converts returned future hexadecimal data type method to a double
      print('mvcv = ${pvcv}');
      var pvmax = 4.4;
      var pvmin = 3;
      slaveBatterypercentage = ((pvcv - pvmin) / (pvmax - pvmin)) * 100;

      print('Saster Battery Percentage: $slaveBatterypercentage');
      return slaveBatterypercentage;
    } catch (err) {
      print('Caught Error: $err');
    }
  }

  Widget _buildServiceTiles(List<BluetoothService> services) {
    return Column(
      children: [
        Container(
          child: Text("PWM Control Code", style: TextStyle(fontSize: 20)),
        ),
        Switch(
          value: ctrlmanual,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              ctrlmanual = value;
              print('PWM control code sent as "0x01" to Char3: $value');
              if (services.length >= 4) {
                BluetoothService service3 = services[3];
                if (service3.characteristics.isNotEmpty) {
                  service3.characteristics[2]
                      .write([ctrlmanual == true ? 0 : 0x01]);
                }
              }
            });
          },
        ),
        Container(
          child: Text("Glass Controller", style: TextStyle(fontSize: 20)),
        ),
        Slider(
            value: _glassSliderValue,
            onChanged: (double value) {
              setState(() {
                _glassSliderValue = value;
                print('Glass Controller value changed: $value');
                if (services.length >= 4) {
                  BluetoothService service3 = services[3];
                  if (service3.characteristics.isNotEmpty) {
                    service3.characteristics[0].write([value.toInt()]);
                  }
                }
              });
            },
            min: 0,
            max: 128,
            divisions: 128,
            thumbColor: Colors.deepPurple,
            label: '$_glassSliderValue'),
        Container(
          child: Text("Light Control Code", style: TextStyle(fontSize: 20)),
        ),
        Switch(
          value: ctrllight,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              ctrllight = value;
              print('Light control code sent "0x02" to Char3: $value');
              if (services.length >= 4) {
                BluetoothService service3 = services[3];
                if (service3.characteristics.isNotEmpty) {
                  service3.characteristics[2]
                      .write([ctrllight == true ? 0 : 0x02]);
                }
              }
            });
          },
        ),
        TextButton(
          child: Text("Get master Voltage"),
          onPressed: () => getMasterVoltage(widget.device),
        ),
        Container(
          child: Text(
              "Master Battery Percentage: "
              '${masterBatterypercentage.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20)),
        ),
        TextButton(
          child: Text("Get Slave Voltage"),
          onPressed: () => getSlaveVoltage(widget.device),
        ),
        Container(
          child: Text(
              "Slave Battery Percentage: "
              '${slaveBatterypercentage.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20)),
        ),
        Container(
          // height: 155,
          height: 250,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 330,
            ),
            Image.asset(
              'assets/images/Miami_OH_JPG.jpg',
              height: 60,
              width: 60,
            ),
          ],
        ),
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/AMIlogoWEBP.webp',
                  height: 60,
                  width: 60,
                ),
                SizedBox(
                  width: 270,
                ),
                Image.asset(
                  'assets/images/Air_Force_Research_Laboratory_PNG.png',
                  height: 60,
                  width: 60,
                ),
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
                      /* TextButton(
                        child: Text("Show Services"),
                        onPressed: () => widget.device.discoverServices(),
                      ), */
                      /*TextButton(
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
    );
  }
}
