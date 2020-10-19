import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/utils.dart';

class CreateUserForm extends StatefulWidget {
  @override
  CreateUserFormState createState() {
    return CreateUserFormState();
  }
}

class CreateUserFormState extends State<CreateUserForm> {

  final _formKey = GlobalKey<FormState>();
  Future<String> _futureUserCreateStatus;

  //Default user_role_id for user
  final String user_role_id = "51484d2c-7a3d-4fe9-b10d-52d6e7408031";
  String name;
  String email;
  String extradata = "{}";
  String password;


  Future<String> _makeUser() async {
    Map userData = {
      "user_role_id": user_role_id,
      "name": name,
      "email": email,
      "extradata": extradata,
      "password": password,
    };
    String body = json.encode(userData);

    var headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    http.Response response = await http.post(
      'https://helistrong.com/api/v1/user_accounts_no_auth',
      headers: headers,
      body: body,
    );

    print('Response');
    print(response.statusCode);
    var userCreateResponse_ = json.decode(response.body);
    print(userCreateResponse_);

    if (response.statusCode == 201) {
      return "Success";
    } else {
      return userCreateResponse_['title'];
    }
  }

  @override
  Widget build(BuildContext context) {

    // Build a Form widget using the _formKey created above.
    return Container(
        child: (_futureUserCreateStatus == null) ? Scaffold(
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
              "New Account",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Name',
                    ),
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a name';
                      }
                      name = value;
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter email',
                    ),
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                    validator: (value) {
                      if (!isEmailValid(value)) {
                        return 'Please enter a valid e-mail';
                      }
                      email = value;
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Password',
                        icon: const Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: const Icon(Icons.lock))),
                    validator: (val) {
                      if (val.length < 6) {
                        return 'Please enter a longer password';
                      }
                      password = val;
                      return null;
                    },
                    obscureText: true,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Retype your password',
                        icon: const Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: const Icon(Icons.lock))),
                    validator: (val) {
                      if (val != password) {
                        return "Passwords don't match.";
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  FlatButton(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600,),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        // Process data.
                        this.setState(() {
                          _futureUserCreateStatus = _makeUser();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ) : FutureBuilder<String>(
            future: _futureUserCreateStatus,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
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
                      "New Account",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  body: AlertDialog(
                    title: Text(
                      snapshot.data == "Success" ? 'Successfully signed up!' : snapshot.data,
                      style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600,),
                    ),
                    actions: [
                      FlatButton(
                        child: Text(
                          'OK',
                          style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w400,),
                        ),
                        textColor: Colors.grey,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );

              } else if (snapshot.hasError) {
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
                      "New Account",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  body: AlertDialog(
                    title: Text(
                      'Uh oh... Something went wrong',
                      style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600,),
                    ),
                    actions: [
                      FlatButton(
                        child: Text(
                          'OK',
                          style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w400,),
                        ),
                        textColor: Colors.grey,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              }

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
                    "New Account",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                body: AlertDialog(
                  content: SingleChildScrollView(
                    child: Container(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );

            }
        )
    );

  }
}