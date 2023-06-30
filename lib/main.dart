import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geoservice/geo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GeoScreen(),
    );
  }
}
