import 'package:arduino_ble/joystick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import './bluetooth_services.dart';

class DeviceConnect extends StatefulWidget {
  const DeviceConnect({
    super.key,
    required this.device,
    required this.deviceName,
    required this.deviceType,
    required this.deviceId,
  });

  final BluetoothDevice device;
  final String deviceName;
  final String deviceType;
  final String deviceId;

  @override
  State<DeviceConnect> createState() => _DeviceConnectState();
}

class _DeviceConnectState extends State<DeviceConnect> {
  bool isConnected = false;

  Future<bool> askLeave(BuildContext context) async {
    bool result = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('블루투스 장치와 연결을 해제할까요?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              result = true;
              Navigator.of(context).pop();
            },
            child: const Text("Yes"),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No"),
          )
        ]
      ),
    );

    if (result) {
      widget.device.disconnect().then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('블루투스 기기와 연결이 해제되었습니다.'),
          ),
        );
      });
    }

    return result;
  }

  Future<BluetoothService?> getHM10Service() async {
    List<BluetoothService> services = await widget.device.discoverServices();

    for (var service in services) {
      String uuid = service.uuid.toString().substring(4, 8);

      if (uuid == "ffe0") {
        return service;
      }
    }

    return null;
  }

  Future<BluetoothService?> openController(BuildContext context) async {
    List<BluetoothService> services = await widget.device.discoverServices();
    List<String> serviceNames = [];
    int selectedService = -1;

    for (var service in services) {
      serviceNames.add(await bluetoothServiceToString(service.uuid.toString()));
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("블루투스 서비스를 선택하세요."),
        content: SizedBox(
          width: 300,
          height: 300,
          child: ListView.builder(
            itemCount: serviceNames.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  selectedService = index;
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceNames[index].isEmpty ? "No name" : serviceNames[index],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        services[index].uuid.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    return selectedService >= 0 ? services[selectedService] : null;
  }

  @override
  void initState() {
    super.initState();

    widget.device.connect().then((_) {
      setState(() {
        isConnected = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('블루투스 기기와 연결되었습니다'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return isConnected && await askLeave(context);
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              child: Text(
                widget.deviceName.isEmpty ? "NO NAME" : widget.deviceName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            Text(
              widget.deviceType,
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade500,
              ),
            ),
            Text(
              widget.deviceId,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            if (isConnected)
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(30, 20, 30, 20)),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Controller"),
                    onPressed: () {
                      getHM10Service().then((service) {
                        if (service == null) return; // TODO: 에러 메시지 출력.

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => Joystick(device: widget.device, service: service),
                        ));
                      });
                    },
                  ),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(30, 20, 30, 20)),
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    icon: const Icon(Icons.cancel),
                    label: const Text("Disconnect"),
                    onPressed: () async {
                      if (await askLeave(context)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ); 
  }
}
