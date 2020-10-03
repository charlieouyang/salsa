import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helistrong/models/listing.dart';
import 'package:helistrong/utils/utils.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:http/http.dart' as http;

import '../authenticator.dart';

class BuyDialog extends StatefulWidget {

  final Listing listing;

  const BuyDialog({Key key, @required this.listing}) : super(key: key);

  @override
  _BuyDialogState createState() => _BuyDialogState();
}

class _BuyDialogState extends State<BuyDialog> {
  final _formKey = GlobalKey<FormState>();
  List<Widget> dialogActions;
  SingleChildScrollView dialogContent;
  Text dialogTitle;
  Future<String> _futurePurchaseStatus;
  int purchaseAmount;
  String purchaseNotes;

  Future<String> _makePurchase() async {
    Map purchaseData = {
      "amount": purchaseAmount,
      "listing_id": widget.listing.id,
      "notes": purchaseNotes,
    };
    String body = json.encode(purchaseData);

    var headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${currentUser.userToken}'
    };
    http.Response response = await http.post(
      'https://helistrong.com/api/v1/purchases',
      headers: headers,
      body: body,
    );

    print('Response');
    print(response.statusCode);
    var purchaseResponse_ = json.decode(response.body);
    print(purchaseResponse_);

    if (response.statusCode == 201) {
      return "Success";
    } else {
      return "Failed";
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: (_futurePurchaseStatus == null) ?
      AlertDialog(
        title: Text(
          'Purchase ${widget.listing.name}',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600,),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter quantity',
                  ),
                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                  validator: (value) {
                    if (!isNumeric(value)) {
                      return 'Please enter a number';
                    }
                    purchaseAmount = int.parse(value);
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Describe pickup/drop off method',
                  ),
                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter information';
                    }
                    purchaseNotes = value;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Purchase',
              style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600,),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                // Process data.
                this.setState(() {
                  _futurePurchaseStatus = _makePurchase();
                });
              }
            },
          ),
          FlatButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w400,),
            ),
            textColor: Colors.grey,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ) :
      FutureBuilder<String>(
        future: _futurePurchaseStatus,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return AlertDialog(
                title: Text(
                  snapshot.data == "Success" ? 'Purchased successfully. Please go to your purchases to view more details'
                      : 'Error in purchasing',
                  style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600,),
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    height: 100.0,
                    child: Column(
                        children: [
                          Container(
                            child: Expanded(
                              child: Center(
                                child: snapshot.data == "Success" ? Icon(
                                  Icons.check,
                                  color: Colors.lightGreen,
                                  size: 60,
                                ) : Icon(
                                  Icons.block,
                                  color: Colors.red,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                ),
                actions: <Widget>[],
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                  title: Text(
                    'Uh oh! Something bad happened',
                    style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600,),
                  ),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      height: 100.0,
                      child: Column(
                          children: [
                            Container(
                              child: Expanded(
                                child: Center(
                                  child: Icon(
                                    Icons.stop,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
                  actions: <Widget>[]
              );
            }

            return AlertDialog(
                title: Text(
                  'Purchase ${widget.listing.name}',
                  style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600,),
                ),
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
                actions: <Widget>[]
            );
          }
      )
    );

  }

}




