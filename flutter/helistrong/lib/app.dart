import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helistrong/seller/view_products.dart';
import 'login_page.dart';
import 'package:helistrong/main/main_scaffold.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/ViewProducts': (context) => ViewProducts(),
        '/login': (context) => LoginPage(),
        '/HomePage': (context) => HomePage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        bottomAppBarColor: Colors.black,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
        ),
        primaryColor: Colors.black,
      ),
      home: LoginPage(),
    );
  }
}

