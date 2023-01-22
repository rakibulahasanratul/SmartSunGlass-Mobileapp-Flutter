import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_blue_example/SliderRange.dart';

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
  bool _lightSensorSwitch = false; //for Light Sensor Controller, default is OFF
  double _rangeSetterValue = 130; //for Range Setter Controller, default is 12.0
  // double _character4Value = 0;//for character4 Value, default is 0

  @override
  void initState() {
    super.initState();
  }

  String getCharacter4Value(List<BluetoothService> services) {
    print("😊services: ${services.toString()}");
    if (services.length >= 4) {
      BluetoothService service3 = services[3];
      print("😊service4 charaters: ${service3.characteristics}");
      if (service3.characteristics.isNotEmpty &&
          service3.characteristics.length >= 4) {
        BluetoothCharacteristic character4 = service3.characteristics[3];
        return character4.value.toString();
      }
    } else {
      return "⚠️service4 is empty!";
    }
    return "⚠️service4 - character4 is empty!";
  }

  // final List<BluetoothService> services;
  Widget _buildServiceTiles(List<BluetoothService> services) {
    return Column(
      children: [
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
          child:
              Text(" Light Sensor Controller", style: TextStyle(fontSize: 20)),
        ),
        Switch(
          value: _lightSensorSwitch,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              _lightSensorSwitch = value;
              print('Light Sensor Switch to: $value');
              if (services.length >= 4) {
                BluetoothService service3 = services[3];
                if (service3.characteristics.isNotEmpty) {
                  service3.characteristics[0]
                      .write([_lightSensorSwitch == true ? 128 : 129]);
                }
              }
            });
          },
        ),
        Container(
          child: Text(" Range Setter", style: TextStyle(fontSize: 20)),
        ),
        Slider(
            value: _rangeSetterValue,
            onChanged: (double value) {
              setState(() {
                _rangeSetterValue = value;
                print('Range Setter value changed: $value');
                if (services.length >= 4) {
                  BluetoothService service3 = services[3];
                  if (service3.characteristics.isNotEmpty) {
                    service3.characteristics[0].write([value.toInt()]);
                  }
                }
              });
            },
            min: 130,
            max: 132,
            divisions: 2,
            thumbColor: Colors.deepPurple,
            label: '$_rangeSetterValue'),
        // Container(
        //   height: 100,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     crossAxisAlignment: CrossAxisAlignment.stretch,
        //     children: [
        //     Text(" Character4 Value",
        //         style: TextStyle(fontSize: 20),
        //         textAlign: TextAlign.center),
        //     Text(getCharacter4Value(services),
        //         style: TextStyle(color: Colors.blueAccent, fontSize: 20),
        //         textAlign: TextAlign.center)
        //   ],
        //   ),
        // ),
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
                      TextButton(
                        child: Text("Show Services"),
                        onPressed: () => widget.device.discoverServices(),
                      ),
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
