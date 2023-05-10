//This dart file is the main entry point of the flutter project.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'data_encryption.dart';
import 'widgets.dart';
import 'db/service/database_service.dart'; //DB service package initialize
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatefulWidget {
  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

//Defining database service class for the entire app
class _FlutterBlueAppState extends State<FlutterBlueApp> {
  var databaseService = DatabaseService.instance;
  bool? _jailbroken;
  bool? _developerMode;
  DataEncryption encryptionController = DataEncryption.instance;

  Future<void> initPlatformState() async {
    bool jailbroken;
    bool developerMode;
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
      developerMode = await FlutterJailbreakDetection.developerMode;
    } on PlatformException {
      jailbroken = true;
      developerMode = true;
    }
    if (!mounted) return;

    setState(() {
      _jailbroken = jailbroken;
      _developerMode = developerMode;
    });
  }

  @override
  void initState() {
    encryptionController.writeValueToSecureStorage();
    initPlatformState();
    databaseService.initDB().then((value) {
      databaseService
          .deleteCentralVoltageData(); //central data table delete once app is close
      databaseService
          .deletePeripheralVoltageData(); //peripheral data table delete once app is close
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: _jailbroken == true
          ? Text("Not accessible")
          : StreamBuilder<BluetoothState>(
              stream: FlutterBlue.instance.state,
              initialData: BluetoothState.unknown,
              builder: (c, snapshot) {
                final state = snapshot.data;
                if (state == BluetoothState.on) {
                  return FindDevicesScreen();
                }
                return BluetoothOffScreen(state: state);
              }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override

  //Widget which check bluetooth adaptor is on or not in the mobile. If not on it send an error message
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.bluetooth_disabled,
            size: 200.0,
            color: Colors.white54,
          ),
          Text(
            'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
          ),
        ],
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: [],
              builder: (c, snapshot) => Column(
                children: snapshot.data!
                    .map((result) => ListTile(
                          title: Text(result.device.name == ""
                              ? "No Name "
                              : result.device.name),
                          subtitle: Text(result.device.id.toString()),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            result.device.connect();
                            return DeviceScreen(device: result.device);
                          })),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () async {
                  var scanStatus =
                      await Permission.bluetoothScan.request().isGranted;

                  var bluetoothConnectStatus =
                      await Permission.bluetoothConnect.request().isGranted;

                  if (scanStatus && bluetoothConnectStatus) {
                    FlutterBlue.instance
                        .startScan(timeout: Duration(seconds: 4));
                  }
                });
          }
        },
      ),
    );
  }
}
