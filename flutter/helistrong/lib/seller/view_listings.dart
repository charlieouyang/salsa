import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:helistrong/authenticator.dart';
import 'dart:convert';
import "package:helistrong/listings/search_item.dart";
import 'create_listing.dart';
import 'package:helistrong/utils/utils.dart';

class ViewListingsPage extends StatefulWidget {
  @override
  _ViewListingsPageState createState() => _ViewListingsPageState();
}

class _ViewListingsPageState extends State<ViewListingsPage> {

  Future listingsFuture;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String name;
  String description;
  double price;
  int quantityAvailable;
  bool active;

  String notVerified = "";

  Future putListing(var params, String listingID) async {
    String url = "https://helistrong.com/api/v1/listings/$listingID";
    final http.Response response = await http.put(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      },
      body: jsonEncode(params),
    );
    print(jsonDecode(response.body));
    return response.statusCode;
  }

  Future getListings() async {
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
    List sellerListings = [];
    for(int x = 0; x < listings.length; x++) {
      if (listings[x]["user_id"] == currentUser.userRole) {
        sellerListings.add(listings[x]);
      }
    }
    return sellerListings;
  }

  _alertDialog(String name, String description, int amount, double price, bool isActive, String listingID) {
    nameController.text = name;
    descriptionController.text = description;
    amountController.text = amount.toString();
    bool test = false;
    priceController.text = price.toString();
    active = isActive;
    List activeColors = [];
    List inactiveColors = [];
    if (active == true) {
      activeColors = [Colors.green, Colors.white];
      inactiveColors = [Colors.white, Colors.red];
    } else {
      activeColors = [Colors.white, Colors.green];
      inactiveColors = [Colors.red, Colors.white];
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Listing"),
              content: Column(
                children: [
                  Form(
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
                          controller: nameController,
                        ),
                        TextFormField(
                          controller: descriptionController,
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
                          keyboardType: TextInputType.number,
                          controller: priceController,
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
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: amountController,
                          maxLengthEnforced: true,
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "ACTIVE?",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (activeColors[0] == Colors.white) {
                            setState(() {
                              activeColors = [Colors.green, Colors.white];
                              inactiveColors = [Colors.white, Colors.red];
                            });
                          } else {
                            setState(() {
                              activeColors = [Colors.white, Colors.green];
                            });
                          }
                        },
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                            child: Text(
                              "ACTIVE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: activeColors[1],
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                              color: Colors.green,
                            ),
                            color: activeColors[0],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (inactiveColors[0] == Colors.white) {
                            setState(() {
                              inactiveColors = [Colors.red, Colors.white];
                              activeColors = [Colors.white, Colors.green];
                            });
                          } else {
                            setState(() {
                              inactiveColors = [Colors.white, Colors.red];
                            });
                          }
                        },
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                            child: Text(
                              "INACTIVE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: inactiveColors[1],
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                              color: Colors.red,
                            ),
                            color: inactiveColors[0],
                          ),
                        ),
                      ),
                    ],
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
              actions: [
                FlatButton(
                  child: Text(
                    "APPLY CHANGES",
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
                      if(price != null && quantityAvailable != null && name != null && description != null && (activeColors[0] != Colors.white || inactiveColors[0] != Colors.white)) {
                        params['name'] = name;
                        params['description'] = description;
                        params['price'] = price;
                        params['amount_available'] = quantityAvailable;
                        if(activeColors[0] == Colors.green) {
                          params['active'] = true;
                        } else {
                          params['active'] = false;
                        }
                        var status = await putListing(params, listingID);
                        print(status);
                        if (status == 200) {
                          Navigator.pushNamed(context, '/HomePage');
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
          },
        );
      }
    );
  }

  _createListings(var listings) {
    List<Widget> widgetListingsActive = [];
    List<Widget> widgetListingsInactive = [];
    List<Widget> widgetListings = [];
    for (int i = 0; i < listings.length; i++) {
      if (listings[i]['active'] == true) {
        widgetListingsActive.add(
          GestureDetector(
            onTap: () {
              _alertDialog(listings[i]['name'], listings[i]['description'], listings[i]['amount_available'].toInt(), listings[i]['price'], listings[i]['active'], listings[i]['id']);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Container(
                    child: ListingItem(
                      thumbnail: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.network(listings[i]['product']['image_urls'][0]),
                        ),
                      ),
                      name: listings[i]['name'],
                      description: listings[i]['description'],
                      price: listings[i]['price'],
                      amountAvailable: listings[i]['amount_available'].toInt(),
                      avgNumStars: listings[i]['product']['avg_numstars'],
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
          ),
        );
      } else {
        widgetListingsInactive.add(
          GestureDetector(
            onTap: () {
              _alertDialog(listings[i]['name'], listings[i]['description'], listings[i]['amount_available'].toInt(), listings[i]['price'], listings[i]['active'], listings[i]['id']);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Container(
                    child: ListingItem(
                      thumbnail: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.network(listings[i]['product']['image_urls'][0]),
                        ),
                      ),
                      name: listings[i]['name'],
                      description: listings[i]['description'],
                      price: listings[i]['price'],
                      amountAvailable: listings[i]['amount_available'].toInt(),
                      avgNumStars: listings[i]['product']['avg_numstars'],
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
          ),
        );
      }
    }
    widgetListings.add(
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "ACTIVE:",
          style: TextStyle(
            fontSize: 23.0,
            color: Colors.green,
          ),
        ),
      ),
    );
    widgetListings.addAll(widgetListingsActive);
    widgetListings.add(
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "INACTIVE:",
          style: TextStyle(
            fontSize: 23.0,
            color: Colors.red,
          ),
        ),
      ),
    );
    widgetListings.addAll(widgetListingsInactive);
    return widgetListings;
  }

  @override
  void initState() {
    super.initState();
    listingsFuture = getListings();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Listings"),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context, PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => CreateListingPage(),
                transitionDuration: Duration(milliseconds: 400),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var begin = Offset(0.0, 1.0);
                  var end = Offset.zero;

                  var tween = Tween(begin: begin, end: end);
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ));
            },
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: listingsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            return ListView(
              children: _createListings(snapshot.data),
            );
          } else {
            return Text("loading...");
          }
        },
      ),
    );
  }
}
