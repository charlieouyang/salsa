import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'recent_activity.dart';
import 'package:helistrong/listings/search.dart';
import 'general_page.dart';
import 'package:helistrong/account/view_account_page.dart';
import 'package:helistrong/seller/view_listings.dart';
import 'package:helistrong/seller/view_products.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => new CupertinoAlertDialog(
        title: Text("Confirm Logout?"),
        content: Text("This will remove the current user from the session and return you to the login screen."),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Center(child:
              Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              logout();
            },
            child: Center(child:
              Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  void logout() async {
    SharedPreferences currentSession = await SharedPreferences.getInstance();
    currentSession.setString("email", null);
    currentSession.setString("password", null);
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  Widget _createDrawerItem(IconData icon, String text, GestureTapCallback onTap) {
    return ListTile(
      leading: Icon(
        icon
      ),
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget _createExpansionTile(List<Widget> children, IconData icon, String title) {
    return ExpansionTile(
      title: Text(title),
      leading: Icon(
        icon,
      ),
      children: children,
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image:  NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRvnPlmeOT4Q2DeTRj51h6Mh_OV4XJWaCS4pQ&usqp=CAU"))),
                child: Stack(children: <Widget>[
                  Positioned(
                      bottom: 12.0,
                      left: 16.0,
                      child: Text("Menu",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500))),
                ])),
            _createDrawerItem(Icons.account_circle, "Account", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMyAccount()));
            }),
            _createExpansionTile([
              _createDrawerItem(Icons.menu, "Listings", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewListingsPage()));
              }),
              _createDrawerItem(Icons.menu, "Products", () {
                Navigator.pushNamed(context, '/ViewProducts');
              }),
            ], Icons.shop, "Seller"),
            _createDrawerItem(Icons.arrow_back_ios, "Log Out", () {
              //TODO ADD LOGOUT
            }),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Helistrong"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.home,
              ),
              title: Text("Home")
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu,
            ),
              title: Text("Orders")
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.search,
            ),
            title: Text("Listings")
          ),
        ]
      ),
      body: _children[_currentIndex],
    );
  }
}

