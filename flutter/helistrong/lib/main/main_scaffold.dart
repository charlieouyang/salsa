import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'recent_activity.dart';
import 'package:helistrong/listings/main_page.dart';
import 'general_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget>_children = [
    HomeScaffold(),
    RecentActivityPage(),
    MainListingsPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.menu,
              ),
              title: Text("Orders")
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.home,
            ),
            title: Text("Home")
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.search,
            ),
            title: Text("Listings")
          ),
        ]
      ),
      tabBuilder: (BuildContext context, int index) {
        return _children[_currentIndex];
      },
    );
  }
}

