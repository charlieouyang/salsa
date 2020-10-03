import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:helistrong/authenticator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAccountPage extends StatefulWidget {
  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {

  Future accountInfoFuture;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordCheckController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  Color passwordVerification = Colors.white;
  String notVerified = "";

  _setControllerText(String email, String name, String password, String passwordCheck, String contact) {
    nameController.text = name;
    emailController.text = email;
    passwordController.text = password;
    passwordCheckController.text = passwordCheck;
    contactController.text = contact;
  }

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
    var userData = jsonDecode(response.body);
    _setControllerText(userData['email'], userData['name'], "*********", "*********", userData['extradata']);
    return jsonDecode(response.body);
  }

  Future editAccountInfo(var params) async {
    String url = "https://helistrong.com/api/v1/user_accounts/${currentUser.userRole}";
    final http.Response response = await http.put(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      },
      body: jsonEncode(params),
    );
    return response;
  }

  @override
  void initState() {
    super.initState();
    accountInfoFuture = getAccountInfo();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Edit your account info",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: accountInfoFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: Colors.blue,
                        size: 120.0,
                      ),
                      Text(
                        "Edit Information:",
                        style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5.0),
                        child: TextField(
                          controller: nameController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: "Display Name",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(0.0, 2.0),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5.0),
                        child: TextField(
                          controller: emailController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(0.0, 2.0),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5.0),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          maxLines: 1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "Enter your new password",
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(0.0, 2.0),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5.0),
                        child: TextField(
                          onChanged: (text) {
                            if (text == passwordController.text) {
                              passwordVerification = Colors.white;
                            } else {
                              passwordVerification = Colors.red;
                            }
                          },
                          controller: passwordCheckController,
                          obscureText: true,
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: "Re-Enter your new password",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                            border: Border.all(
                              color: passwordVerification,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(0.0, 2.0),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5.0),
                        child: TextField(
                          controller: contactController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: "Enter any preferred methods of contact",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(0.0, 2.0),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                    ],
                  ),
                );
              } else {
                return Text("Loading...");
              }
            },
          ),
          Text(
            notVerified,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
          GestureDetector(
            onTap: () async {
              var params = {};
              if (nameController.text == "" || nameController.text == " " || emailController.text == "" || emailController.text == " " || passwordController.text == "" || passwordController.text == "" || passwordVerification == Colors.red || contactController.text == "") {
                setState(() {
                  notVerified = "Please check all fields are filled properly";
                });
              } else {
                params['name'] = nameController.text;
                params['email'] = emailController.text;
                if (passwordController.text != "**********") {
                  params['password'] = passwordController.text;
                }
                params['extradata'] = jsonEncode(contactController.text);
                var response = await editAccountInfo(params);
                if (response.statusCode == 200) {
                  SharedPreferences currentSession = await SharedPreferences.getInstance();
                  currentSession.setString('email', emailController.text);
                  currentSession.setString('password', passwordController.text);
                  Navigator.pop(context);
                } else {
                  var detail = jsonDecode(response.body);
                  setState(() {
                    notVerified = detail['detail'];
                  });
                }
              }
            },
            child: Center(
              child: Container(
                height: 50.0,
                width: 250.0,
                child: Center(
                  child: Text(
                    "SAVE",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13.0),
                    border: Border.all(
                      color: Colors.red,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(0.0, 1.0),
                        blurRadius: 0.0,
                      ),
                    ]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
