import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:helistrong/authenticator.dart';
import 'create_product.dart';

class ViewProducts extends StatefulWidget {
  @override
  _ViewProductsState createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  
  Future products;
  
  Future getProducts() async {
    List<dynamic> userProducts = [];
    String url = "https://helistrong.com/api/v1/products";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      }
    );
    var products = jsonDecode(response.body);
    for (int x = 0; x < products.length; x++) {
      if (products[x]['user_id'] == currentUser.userRole) {
        userProducts.add(products[x]);
      }
    }
    return userProducts;
  }

  List<Widget> _convertProducts(var products) {
    List<Widget> convertedPurchases = [];
    for (int x = 0; x < products.length; x++) {
      convertedPurchases.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.network(products[x]['image_urls'][0]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${products[x]['name']}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                                        Text(
                                          '${products[x]['description']}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          RatingBar(
                                            initialRating: products[x]['avg_numstars'],
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 15,
                                            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      );
    }
    return convertedPurchases;
  }

  @override
  void initState() {
    super.initState();
    products = getProducts();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateProduct(
                imageURLS: [],
                description: "",
                name: "",
                categoryIDs: [],
              )));
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: products,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: ListView(
                children: _convertProducts(snapshot.data),
              ),
            );
          } else {
            return Text("Loading...");
          }
        },
      ),
    );
  }
}

