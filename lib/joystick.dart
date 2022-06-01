import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class Joystick extends StatefulWidget {
  const Joystick({
    super.key,
    required this.device,
    required this.service
  });

  final BluetoothDevice device;
  final BluetoothService service;
  
  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  bool isSending = false;
  Duration duration = const Duration(microseconds: 100);

  Map<String, List<int>> writeMapping = {
    "up": [ 0x31 ], // TEST
    "down": [ 0x32 ],
    "left": [ 0x33 ],
    "right": [ 0x34 ],
    "a": [ 0x61 ],
    "b": [ 0x62 ],
    "c": [ 0x63 ],
    "d": [ 0x64 ],
  };

  void send(BluetoothCharacteristic char, String key) async {
    if (writeMapping.containsKey(key)) {
      await char.write(writeMapping[key]!, withoutResponse: true)
      .onError((error, stackTrace) {
        print("ERROR: $error");
        print("stackTrace: $stackTrace");
      });
    }

    if (isSending) {
      Timer(duration, () => send(char, key));
    }
  }

  BluetoothCharacteristic? getCharacteristic() {
    var characteristics = widget.service.characteristics;

    for (var characteristic in characteristics) {
      String uuid = characteristic.uuid.toString().substring(4, 8);

      if (uuid == "ffe1") {
        return characteristic;
      }
    }

    return null;
  }

  BluetoothDescriptor? getDescriptor(BluetoothCharacteristic char) {
    var descriptors = char.descriptors;

    for (var descriptor in descriptors) {
      String uuid = descriptor.uuid.toString().substring(4, 8);

      if (uuid == "2901") {
        return descriptor;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BluetoothCharacteristic? characteristic = getCharacteristic();
    if (characteristic == null) {
      Navigator.of(context).pop();
      return const Text("ERROR: characteristic");
    }

    BluetoothDescriptor? descriptor = getDescriptor(characteristic);
    if (descriptor == null) {
      Navigator.of(context).pop();
      return const Text("ERROR: descriptor");
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 250,
            left: 150,
            child: InkWell(
              onTapDown: (_){
                isSending = true;
                send(characteristic, "up");
              },
              onTapUp: (_) => { isSending = false },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: const Icon(Icons.expand_less),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 50,
            child: InkWell(
              onTapDown: (_){
                isSending = true;
                send(characteristic, "left");
              },
              onTapUp: (_) => { isSending = false },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: const Icon(Icons.chevron_left),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 250,
            child: InkWell(
              onTapDown: (_){
                isSending = true;
                send(characteristic, "right");
              },
              onTapUp: (_) => { isSending = false },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: const Icon(Icons.chevron_right),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 150,
            child: InkWell(
              onTapDown: (_){
                isSending = true;
                send(characteristic, "down");
              },
              onTapUp: (_) => { isSending = false },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: const Icon(Icons.expand_more),
              ),
            ),
          ),
          Positioned(
            bottom: 170,
            right: 170,
            child: InkWell(
              onTapDown: (_){
                isSending = true;
                send(characteristic, "a");
              },
              onTapUp: (_) => { isSending = false },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: const Center(
                  child: Text("A")
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 170,
            right: 50,
            child: InkWell(
              onTapDown: (_){
                isSending = true;
                send(characteristic, "b");
              },
              onTapUp: (_) => { isSending = false },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: const Center(
                  child: Text("B")
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 170,
            child: InkWell(
              onTapDown: (_){
                isSending = true;
                send(characteristic, "c");
              },
              onTapUp: (_) => { isSending = false },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: const Center(
                  child: Text("C")
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: InkWell(
              onTapDown: (_){
                isSending = true;
                send(characteristic, "d");
              },
              onTapUp: (_) => { isSending = false },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: const Center(
                  child: Text("D")
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
