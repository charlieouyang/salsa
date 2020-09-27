import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:helistrong/authenticator.dart';
import 'package:flutter/cupertino.dart';
import 'package:helistrong/authenticator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class HomeScaffold extends StatefulWidget {
  @override
  _HomeScaffoldState createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  Future randomListingFuture;
  Future recentOrderBuyerFuture;
  Future recentOrderSellerFuture;

  Future getListing() async {
    String url = "https://helistrong.com/api/v1/listings?embed=product";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      },
    );
    var listings = jsonDecode(response.body);
    return listings[0];
  }

  Future getOrderBuyer() async {
    String url = "https://helistrong.com/api/v1/purchases?user_as=buyer&embed=listing";
    print(currentUser.userToken);
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}',
      }
    );
    var order = jsonDecode(response.body);
    print(order);
    return order[0];
  }

  Future getOrderSeller() async {
    //TODO Add url
    String url = "https://helistrong.com/api/v1/purchases?user_as=seller&embed=listing";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}',
      },
    );
    var order = jsonDecode(response.body);
    print(order);
    return order[0];
  }
  @override
  void initState() {
    super.initState();
    randomListingFuture = getListing();
    recentOrderBuyerFuture = getOrderBuyer();
    recentOrderSellerFuture = getOrderSeller();
  }
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: ListView(
        children: [
          FutureBuilder(
            future: randomListingFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Container(
                    width: 250.0,
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Deal of the day",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            snapshot.data['name'],
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(snapshot.data['product']['image_urls'][0])
                            ),
                          ),
                        ),
                        Text(
                          "\$" + snapshot.data['price'].toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.orange,
                          ),
                        ),
                        //TODO Smooth star rating
                        SmoothStarRating(
                          size: 10.0,
                          isReadOnly: true,
                          starCount: 5,
                          rating: snapshot.data['product']['avg_numstars'],
                          allowHalfRating: true,
                          color: Colors.orange,
                          borderColor: Colors.orange,
                        ),
                        GestureDetector(
                            onTap: () {

                            },
                            child: Text(
                              "View this offer",
                              style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            )
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.black,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: Offset(0.0, 4.0),
                          blurRadius: 1.0,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Text("loading");
              }
            },
          ),
          Text(
            "Most Recent Purchase",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            )
          ),
          FutureBuilder(
            future: recentOrderBuyerFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                Color buyerComplete, sellerComplete;
                String buyerFinished, sellerFinished;
                if (snapshot.data["buyer_complete"] == true) {
                  buyerComplete = Colors.green;
                  buyerFinished = "True";
                } else {
                  buyerComplete = Colors.red;
                  buyerFinished = "False";
                }
                if (snapshot.data["seller_complete"] == true) {
                  sellerComplete = Colors.green;
                  sellerFinished = "True";
                } else {
                  sellerComplete = Colors.red;
                  sellerFinished = "False";
                }
                return Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Container(
                    height: 125.0,
                    width: 250.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 150.0,
                              child: Text(
                                snapshot.data['listing']['name'],
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Amount: ",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                                children: <TextSpan> [
                                  TextSpan(
                                    text: snapshot.data['amount'].toString() + "       ",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Price: ",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: snapshot.data['listing']['price'].toString(),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                ]
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                        Container(
                          height: 100.0,
                          width: 1.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            )
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Buyer Complete: ",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                                children: <TextSpan> [
                                  TextSpan(
                                    text: buyerFinished,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: buyerComplete,
                                    ),
                                  ),
                                ]
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: "Seller Complete: ",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: sellerFinished,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: sellerComplete,
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.black,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: Offset(0.0, 4.0),
                          blurRadius: 1.0,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Text("loading...");
              }
            },
          ),
          Text(
            "Recent Order Requested",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          FutureBuilder(
            future: recentOrderSellerFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                Color buyerComplete, sellerComplete;
                String buyerFinished, sellerFinished;
                if (snapshot.data["buyer_complete"] == true) {
                  buyerComplete = Colors.green;
                  buyerFinished = "True";
                } else {
                  buyerComplete = Colors.red;
                  buyerFinished = "False";
                }
                if (snapshot.data["seller_complete"] == true) {
                  sellerComplete = Colors.green;
                  sellerFinished = "True";
                } else {
                  sellerComplete = Colors.red;
                  sellerFinished = "False";
                }
                return Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Container(
                    height: 125.0,
                    width: 250.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 150.0,
                              child: Text(
                                snapshot.data['listing']['name'],
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: "Amount: ",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: snapshot.data['amount'].toString() + "       ",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Price: ",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: snapshot.data['listing']['price'].toString(),
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ]
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                        Container(
                          height: 100.0,
                          width: 1.0,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              )
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RichText(
                              text: TextSpan(
                                  text: "Buyer Complete: ",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: buyerFinished,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: buyerComplete,
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: "Seller Complete: ",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: sellerFinished,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: sellerComplete,
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.black,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: Offset(0.0, 4.0),
                          blurRadius: 1.0,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Text("loading...");
              }
            },
          ),
        ],
      ),
    );
  }
}
