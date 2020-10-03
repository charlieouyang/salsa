import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:helistrong/authenticator.dart';
import 'edit_account_page.dart';

class ViewMyAccount extends StatefulWidget {
  @override
  _ViewMyAccountState createState() => _ViewMyAccountState();
}

class _ViewMyAccountState extends State<ViewMyAccount> {

  Future retrieveAccountInfo;

  Future getAccountInfo() async {
    String url = "https://helistrong.com/api/v1/user_accounts/${currentUser.userRole}";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      },
    );
    var accountInfo = jsonDecode(response.body);
    print(accountInfo);
    return accountInfo;
  }

  @override
  void initState() {
    super.initState();
    retrieveAccountInfo = getAccountInfo();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Account"),
      ),
      body: FutureBuilder(
        future: retrieveAccountInfo,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            String contactInfo = snapshot.data['extradata'];
            contactInfo.replaceAll("{", "");
            contactInfo.replaceAll("}", "");
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 150.0,
                        color: Colors.blue,
                      ),
                      Container(
                        height: 30.0,
                        width: 1.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            snapshot.data['name'],
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            snapshot.data['email'],
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      width: 200.0,
                      height: 1.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                        "Password: **********",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    width: double.infinity,
                    height: 150.0,
                    child: Text(
                      "Contact Info: " + contactInfo,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => EditAccountPage(),
                          transitionDuration: Duration(milliseconds: 400),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var begin = Offset(0.0, 1.0);
                            var end = Offset.zero;

                            var tween = Tween(begin: begin, end: end);
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 85.0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 20.0,
                              ),
                              Text(
                                "Edit Account Info",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              offset: Offset(0.0, 3.0),
                              blurRadius: 7.0,
                              spreadRadius: 5.0,
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Text("Loading...");
          }
        },
      )
    );
  }
}
