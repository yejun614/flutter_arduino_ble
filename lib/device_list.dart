import 'package:arduino_ble/device_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

class DeviceList extends StatefulWidget {
  const DeviceList({ super.key });

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  Timer? autoCancel;

  String getDeviceType(BluetoothDeviceType type) {
    switch(type) {
      case BluetoothDeviceType.unknown:
        return "Unknown";

      case BluetoothDeviceType.classic:
        return "Classic";

      case BluetoothDeviceType.le:
        return "Bluetooth Low Energy";

      case BluetoothDeviceType.dual:
        return "Dual";
    }
  }

  @override
  void initState() {
    super.initState();

    scanResults.clear();

    flutterBlue.scanResults.listen((results) {
      setState(() {
        results.sort((a, b) {
          if (a.rssi == b.rssi) return 0;
          return a.rssi > b.rssi ? -1 : 1;
        });

        scanResults = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      title: "Arduino BLE",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Arduino BLE"),
          actions: [
            isScanning
            ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isScanning = false;
                });

                isScanning = false;
                flutterBlue.stopScan();

                autoCancel!.cancel();
              },
            )
            : IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  isScanning = true;
                });

                flutterBlue.startScan(timeout: const Duration(seconds: 10));

                autoCancel = Timer(const Duration(seconds: 10), () => setState(() {
                  isScanning = false;
                }));
              },
            ),
          ],
        ),
        body: scanResults.isEmpty
        ? Center(
          child: Text(
            "주변 장치들을 스캔해 보세요 --",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
        )
        : SizedBox(
          child: ListView.builder(
            itemCount: scanResults.length,
            itemBuilder: (BuildContext context, int index) {
              BluetoothDevice device = scanResults[index].device;
              String deviceName = device.name;
              String deviceType = getDeviceType(scanResults[index].device.type);
              String deviceId = device.id.toString();
              int rssi = scanResults[index].rssi;

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                    return DeviceConnect(
                      device: device,
                      deviceName: deviceName,
                      deviceType: deviceType,
                      deviceId: deviceId
                    );
                  }));
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceName.isEmpty ? "NO NAME" : deviceName,
                            style: const TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          Text(
                            deviceType,
                            style: TextStyle(
                              color: Colors.red.shade500,
                            ),
                          ),
                          Text(deviceId),
                        ],
                      ),
                      Text(
                        rssi.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              );
            },
          ),
        ),
      ),
    );
  }
}
