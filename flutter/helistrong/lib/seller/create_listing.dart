import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:helistrong/authenticator.dart';
import 'product_item.dart';
import 'package:helistrong/utils/utils.dart';
import 'package:helistrong/main/main_scaffold.dart';


class CreateListingPage extends StatefulWidget {
  @override
  _CreateListingPageState createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  Future productsFuture;
  String name;
  String description;
  String productID;
  double price;
  int quantityAvailable;
  String notVerified = "";

  Future postListing(var params) async {
    String url = "https://helistrong.com/api/v1/listings";
    final http.Response response = await http.post(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      },
      body: jsonEncode(params),
    );
    var status = response.statusCode;
    return status;
  }

  Future getProducts() async {
    List<dynamic> userProducts = [];
    String url = "https://helistrong.com/api/v1/products";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      },
    );
    var products = jsonDecode(response.body);
    for (int x = 0; x < products.length; x++) {
      if (products[x]['user_id'] == currentUser.userRole) {
        userProducts.add(products[x]);
      }
    }
    return userProducts;
  }

  _alertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Listing Information"),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    hintText: 'Name',
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
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                  ),
                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a description';
                    }
                    description = value;
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    hintText: 'Enter price',
                  ),
                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                  validator: (value) {
                    if (!isNumeric(value)) {
                      return 'Please enter a number';
                    }
                    price = double.parse(value);
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  maxLengthEnforced: true,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    hintText: 'Enter quantity available',
                  ),
                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                  validator: (value) {
                    if (!isNumeric(value)) {
                      return 'Please enter a number';
                    }
                    quantityAvailable = int.parse(value);
                    return null;
                  },
                ),
                Text(
                  notVerified,
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text(
                "PURCHASE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  // Process data.
                  print(price);
                  print(description);
                  var params = {};
                  if(price != null && quantityAvailable != null && name != null && description != null) {
                    params['name'] = name;
                    params['description'] = description;
                    params['price'] = price;
                    params['amount_available'] = quantityAvailable;
                    params['active'] = true;
                    params['product_id'] = productID;
                    print(params);
                    var status = await postListing(params);
                    print(status);
                    if (status == 201) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                    } else {
                      setState(() {
                        notVerified = "Something went wrong";
                      });
                    }
                  }
                  else {
                    this.setState(() {
                      notVerified = "Please ensure all fields are filled";
                    });
                  }
                }
              },
            ),
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }

  _convertProducts(var products) {
    List<Widget> convertedProjects = [];
    for(int x = 0; x < products.length; x++) {
      convertedProjects.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: GestureDetector(
            onTap: (){
              productID = products[x]['id'];
              _alertDialog();
            },
            child: Container(
              child: ListingItem(
                thumbnail: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.network(products[x]['image_urls'][0]),
                  ),
                ),
                name: products[x]['name'],
                description: products[x]['description'],
                avgNumStars:products[x]['avg_numstars'],
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
    return convertedProjects;
  }

  @override
  void initState() {
    super.initState();
    productsFuture = getProducts();
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
          "Choose one of your products",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder(
        future: productsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            return ListView(
              children: _convertProducts(snapshot.data),
            );
          } else {
            return Text("loading...");
          }
        },
      ),
    );
  }
}
