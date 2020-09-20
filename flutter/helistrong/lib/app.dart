import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        barBackgroundColor: Colors.black,
      ),
      home: LoginPage(),
    );
  }
}

