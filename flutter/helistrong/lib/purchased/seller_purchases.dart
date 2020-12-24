import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:helistrong/authenticator.dart';
import 'edit_purchase.dart';

class SellerPurchases extends StatefulWidget {
  @override
  _SellerPurchasesState createState() => _SellerPurchasesState();
}

class _SellerPurchasesState extends State<SellerPurchases> {

  Future purchases;

  Future getOrderSeller() async {
    String url = "https://helistrong.com/api/v1/purchases?user_as=seller&embed=listing";
    final http.Response response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${currentUser.userToken}',
        }
    );
    var order = jsonDecode(response.body);
    return order;
  }

  _convertPurchases(var purchases) {
    List<Widget> convertedPurchases = [];
    for(int x = 0; x < purchases.length; x++) {
      Color buyerComplete, sellerComplete;
      String buyerFinished, sellerFinished;
      if (purchases[x]["buyer_complete"] == true) {
        buyerComplete = Colors.green;
        buyerFinished = "Completed";
      } else {
        buyerComplete = Colors.red;
        buyerFinished = "Pending";
      }
      if (purchases[x]["seller_complete"] == true) {
        sellerComplete = Colors.green;
        sellerFinished = "Completed";
      } else {
        sellerComplete = Colors.red;
        sellerFinished = "Pending";
      }
      convertedPurchases.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditPurchases(buyer: false, purchaseID: purchases[x]['id'],)));
            },
            child: Container(
              height: 120,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 10.0, 2.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${purchases[x]['listing']['name']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            RichText(
                              text: TextSpan(
                                  text: "Buyer Complete: ",
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.black54,
                                  ),
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: buyerFinished,
                                      style: TextStyle(
                                        color: buyerComplete,
                                      ),
                                    )
                                  ]
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            RichText(
                              text: TextSpan(
                                  text: "Seller Complete: ",
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.black54,
                                  ),
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: sellerFinished,
                                      style: TextStyle(
                                        color: sellerComplete,
                                      ),
                                    )
                                  ]
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    '\$ ${purchases[x]['listing']['price']}',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Amount: ${purchases[x]['amount'].toInt()}',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      );
    }
    return convertedPurchases;
  }
  @override
  void initState() {
    super.initState();
    purchases = getOrderSeller();
  }
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: purchases,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView(
              shrinkWrap: true,
              children: _convertPurchases(snapshot.data)
          );
        } else {
          return Text("loading...");
        }
      },
    );
  }
}