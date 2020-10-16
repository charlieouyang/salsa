import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:helistrong/authenticator.dart';
import 'package:helistrong/main/main_scaffold.dart';

class EditPurchases extends StatefulWidget {
  EditPurchases({@required this.buyer, @required this.purchaseID});
  final bool buyer;
  final String purchaseID;
  @override
  _EditPurchasesState createState() => _EditPurchasesState(
    buyer: buyer,
    purchaseID: purchaseID,
  );
}

class _EditPurchasesState extends State<EditPurchases> {
  _EditPurchasesState({this.purchaseID, this.buyer});
  final bool buyer;
  final String purchaseID;

  List<Color> activeColors = [
    Colors.white,
    Colors.green,
    Colors.white,
    Colors.red,
  ];

  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future purchase;

  Future putPurchase(var params) async {
    String url = "https://helistrong.com/api/v1/purchases/$purchaseID";
    print (jsonEncode(params));
    final http.Response response = await http.put(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}',
      },
      body: jsonEncode(params),
    );
    return response.statusCode;
  }

  Future getPurchase(String url) async {
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}',
      }
    );
    var purchaseInfo = jsonDecode(response.body);
    amountController.text = purchaseInfo['amount'].toString();
    notesController.text = purchaseInfo['notes'];
    if (buyer == true) {
      if (purchaseInfo["buyer_complete"] == true) {
        activeColors[0] = Colors.green;
        activeColors[1] = Colors.white;
      } else {
        activeColors[2] = Colors.red;
        activeColors[3] = Colors.white;
      }
    } else {
      if (purchaseInfo['seller_complete'] == true) {
        activeColors[0] = Colors.green;
        activeColors[1] = Colors.white;
      } else {
        activeColors[2] = Colors.red;
        activeColors[3] = Colors.white;
      }
    }
    return purchaseInfo;
  }

  _body() {
    return FutureBuilder(
      future: purchase,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          bool editable;
          if (snapshot.data['buyer_complete'] == true || snapshot.data['seller_complete'] == true) {
            editable = false;
          } else {
            editable = true;
          }
          if (buyer) {
            return Padding(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 0.0),
              child: Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        "Status:",
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (activeColors[0] == Colors.white) {
                                setState(() {
                                  activeColors[0] = Colors.green;
                                  activeColors[1] = Colors.white;
                                  activeColors[2] = Colors.white;
                                  activeColors[3] = Colors.red;
                                });
                              }
                            },
                            child: Container(
                              height: 50.0,
                              width: 150.0,
                              child: Center(
                                child: Text(
                                  "COMPLETED",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                    color: activeColors[1],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: activeColors[0],
                                  borderRadius: BorderRadius.circular(13.0),
                                  border: Border.all(
                                    color: activeColors[1],
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
                          GestureDetector(
                            onTap: () {
                              if (activeColors[2] == Colors.white) {
                                setState(() {
                                  activeColors[2] = Colors.red;
                                  activeColors[3] = Colors.white;
                                  activeColors[0] = Colors.white;
                                  activeColors[1] = Colors.green;
                                });
                              }
                            },
                            child: Container(
                              height: 50.0,
                              width: 150.0,
                              child: Center(
                                child: Text(
                                  "PENDING",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                    color: activeColors[3],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: activeColors[2],
                                  borderRadius: BorderRadius.circular(13.0),
                                  border: Border.all(
                                    color: activeColors[3],
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
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          Text(
                            "Amount:",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Container(
                            height: 40.0,
                            width: 150.0,
                            child: TextField(
                              enabled: editable,
                              keyboardType: TextInputType.number,
                              controller: amountController,
                              decoration: InputDecoration(
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
                        ],
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        "Notes:",
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 150.0,
                        width: 250.0,
                        child: TextField(
                          enabled: editable,
                          controller: notesController,
                          decoration: InputDecoration(
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
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 22.0, horizontal: 75.0),
                          child: GestureDetector(
                            onTap: () async {
                              var params = {};
                              if(activeColors[0] == Colors.green) {
                                params['buyer_complete'] = true;
                              } else {
                                params['buyer_complete'] = false;
                              }
                              params['amount'] = double.parse(amountController.text);
                              params['notes'] = notesController.text;
                              var response = await putPurchase(params);
                              print(response);
                              if (response == 200) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                              }
                            },
                            child: Container(
                              height: 50.0,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  "SAVE",
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(13.0),
                                  border: Border.all(
                                    color: Colors.blue,
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
                      ),
                    ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 0.0),
              child: Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        "Status:",
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (activeColors[0] == Colors.white) {
                                setState(() {
                                  activeColors[0] = Colors.green;
                                  activeColors[1] = Colors.white;
                                  activeColors[2] = Colors.white;
                                  activeColors[3] = Colors.red;
                                });
                              }
                            },
                            child: Container(
                              height: 70.0,
                              width: 150.0,
                              child: Center(
                                child: Text(
                                  "COMPLETED",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                    color: activeColors[1],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: activeColors[0],
                                  borderRadius: BorderRadius.circular(13.0),
                                  border: Border.all(
                                    color: activeColors[1],
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
                          GestureDetector(
                            onTap: () {
                              if (activeColors[2] == Colors.white) {
                                setState(() {
                                  activeColors[2] = Colors.red;
                                  activeColors[3] = Colors.white;
                                  activeColors[0] = Colors.white;
                                  activeColors[1] = Colors.green;
                                });
                              }
                            },
                            child: Container(
                              height: 70.0,
                              width: 150.0,
                              child: Center(
                                child: Text(
                                  "PENDING",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                    color: activeColors[3],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: activeColors[2],
                                  borderRadius: BorderRadius.circular(13.0),
                                  border: Border.all(
                                    color: activeColors[3],
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
                        ],
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        children: [
                          Text(
                            "Amount: ",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 40.0,
                          ),
                          Container(
                            height: 60.0,
                            width: 150.0,
                            child: TextField(
                              enabled: false,
                              keyboardType: TextInputType.number,
                              controller: amountController,
                              decoration: InputDecoration(
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
                        ],
                      ),
                      SizedBox(
                        height: 35.0,
                      ),
                      Text(
                        "Notes: ",
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 150.0,
                        width: 250.0,
                        child: TextField(
                          enabled: false,
                          controller: notesController,
                          decoration: InputDecoration(
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
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 22.0, horizontal: 75.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50.0,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "CANCEL",
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13.0),
                                border: Border.all(
                                  color: Colors.grey,
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
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 22.0, horizontal: 75.0),
                          child: GestureDetector(
                            onTap: () async {
                              var params = {};
                              if(activeColors[0] == Colors.green) {
                                params['seller_complete'] = true;
                              } else {
                                params['seller_complete'] = false;
                              }
                              var response = await putPurchase(params);
                              if (response == 200) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                              }
                            },
                            child: Container(
                              height: 50.0,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  "SAVE",
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(13.0),
                                  border: Border.all(
                                    color: Colors.blue,
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
                      ),
                    ),
                ],
              ),
            );
          }
        } else {
          return Text("loading...");
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    purchase = getPurchase("http://helistrong.com/api/v1/purchases/$purchaseID");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }
}






