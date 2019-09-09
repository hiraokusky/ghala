import 'package:flutter/material.dart';
import 'package:ghala/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghala',
      theme: new ThemeData(
          // primaryColor: new Color(0xff075E54),
          accentColor: new Color(0xff25D366),
          primarySwatch: Colors.blue,
          primaryColor: Colors.white,
          primaryIconTheme: IconThemeData(color: Colors.blue),
          primaryTextTheme: TextTheme(
              title: TextStyle(color: Colors.black, fontFamily: "Aveny")),
          textTheme:
              TextTheme(title: TextStyle(color: Colors.black, fontSize: 16))),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
