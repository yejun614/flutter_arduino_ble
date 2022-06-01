import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';

String bluetoothNumbersPath = "assets/bluetooth_uuids/";

List<String> bluetoothNumbersDB = [
  "characteristic_uuids.json",
  "descriptor_uuids.json",
  "service_uuids.json",
];

Future<String> bluetoothServiceToString(String uuid) async {
  uuid = uuid.toString().substring(4, 8);
  String name = "";

  for (String path in bluetoothNumbersDB) {
    if (name.isNotEmpty) break;

    List<dynamic> data = json.decode(await rootBundle.loadString(bluetoothNumbersPath + path));

    for (var element in data) {
      if (element["uuid"] == uuid) {
        name = element["name"]!;
      }
    }
  }

  return name;
}
