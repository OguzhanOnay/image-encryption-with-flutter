import 'package:flutter/material.dart';
import 'package:ymgkproje/foto.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoCripto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FotoEkle(),
      debugShowCheckedModeBanner: false,
    );
  }
}
