import 'package:flutter/material.dart';
import './device_list.dart';

void main() => runApp(const ArduinoBLEApp());

class ArduinoBLEApp extends StatelessWidget {
  const ArduinoBLEApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return const DeviceList();
  }
}
