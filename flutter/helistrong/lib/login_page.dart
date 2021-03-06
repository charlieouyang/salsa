import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helistrong/authenticator.dart';
import 'package:helistrong/main/main_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helistrong/account/new_account_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;




  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String notVerified = "";

  Future login(String email, String password) async {
    String url = "https://helistrong.com/api/v1/login";
    var params = {};
    params['email'] = email;
    params['password'] = password;
    final http.Response response = await http.post(
      url,
      body: jsonEncode(params),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }

  void autoLogin() async {
    SharedPreferences currentSession = await SharedPreferences.getInstance();
    if (currentSession.getString("email") != null) {
      loginEmailController.text = currentSession.getString("email");
      passwordController.text = currentSession.getString('password');
      var loginResult = await login(loginEmailController.text, passwordController.text);
      if (loginResult.statusCode == 200) {
        var loginBody = jsonDecode(loginResult.body);
        currentUser.userToken = loginBody['token'];
        currentUser.userRole = loginBody['user_account_id'];
        Navigator.pushNamed(context, '/HomePage');
      } else {
        var loginBody = jsonDecode(loginResult.body);
        setState(() {
          notVerified = loginBody['detail'];
        });
      }
    }
  }

  void setLogin(String email, String password) async {
    SharedPreferences currentSession = await SharedPreferences.getInstance();
    currentSession.setString("email", email);
    currentSession.setString("password", password);
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String detail) async {

  }

  Future onSelectNotification(String payload) async {
    if(payload != null) {
      debugPrint("notification payload: $payload");
    }
    await Navigator.pushNamed(context, "/login");
  }

   @override
  void initState() {
    super.initState();
    // initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    // initializationSettingsIOS = new IOSInitializationSettings(
    //   onDidReceiveLocalNotification: onDidReceiveLocalNotification
    // );
    // initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    // flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onSelectNotification: onSelectNotification,
    // );
    //
    autoLogin();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            notVerified,
            style: TextStyle(
              color: Colors.red,
              fontSize: 15.0,
            ),
          ),
          Container(
            height: 40.0,
            width: 250.0,
            child: TextField(
              controller: loginEmailController,
              decoration: InputDecoration(
                hintText: " Email",
                border: InputBorder.none,
              ),
            ),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            height: 40.0,
            width: 250.0,
            child: TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                hintText: " Password",
                border: InputBorder.none,
              ),
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                if (loginEmailController.text == "" || passwordController.text == "") {
                  setState(() {
                    notVerified = "Please check you have entered an email and a password";
                  });
                } else {
                  var loginResult = await login(loginEmailController.text, passwordController.text);
                  if (loginResult.statusCode == 200) {
                    var loginBody = jsonDecode(loginResult.body);
                    currentUser.userToken = loginBody['token'];
                    currentUser.userRole = loginBody['user_account_id'];
                    setLogin(loginEmailController.text, passwordController.text);
                    Navigator.pushNamed(context, '/HomePage');
                  } else {
                    print(loginResult.statusCode);
                    var loginBody = jsonDecode(loginResult.body);
                    setState(() {
                      notVerified = loginBody['detail'];
                    });
                  }
                }
              },
              child: Container(
                height: 50.0,
                width: 250.0,
                child: Center(
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(13.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(0.0, 2.0),
                        blurRadius: 1.0,
                      ),
                    ]
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => CreateUserForm()
                ));
              },
              child: Container(
                height: 50.0,
                width: 250.0,
                child: Center(
                  child: Text(
                    "SIGN UP",
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
