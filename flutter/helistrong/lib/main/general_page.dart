import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:helistrong/authenticator.dart';
import 'package:flutter/cupertino.dart';
import 'package:helistrong/authenticator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:helistrong/listings/search_item.dart';
import 'package:helistrong/listings/listing_detail.dart';

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

  Widget buildPurchase(Color buyerComplete, Color sellerComplete, String buyer, String seller, int amount, double price, String name) {
    return Container(
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
                      '$name',
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
                            text: buyer,
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
                              text: seller,
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
                            '\$ $price',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Amount: ${amount.toString()}',
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
    );
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
          Text(
              "Deal of the day",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              )
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: FutureBuilder(
              future: randomListingFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    child: Container(
                      child: ListingItem(
                        thumbnail: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.network(snapshot.data['product']['image_urls'][0]),
                          ),
                        ),
                        name: snapshot.data['name'],
                        description: snapshot.data['description'],
                        price: snapshot.data['price'],
                        amountAvailable: snapshot.data['amount_available'].toInt(),
                        avgNumStars: snapshot.data['product']['avg_numstars'],
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListingDetail(listingId: snapshot.data['id'])));
                    },
                  );
                } else {
                  return Text("loading");
                }
              },
            ),
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
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: buildPurchase(buyerComplete, sellerComplete, buyerFinished, sellerFinished, snapshot.data['amount'].toInt(), snapshot.data['listing']['price'], snapshot.data['listing']['name']),
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
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: buildPurchase(buyerComplete, sellerComplete, buyerFinished, sellerFinished, snapshot.data['amount'].toInt(), snapshot.data['listing']['price'], snapshot.data['listing']['name']),
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
