import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:helistrong/authenticator.dart';
import 'dart:convert';
import "package:helistrong/listings/search_item.dart";
import 'create_listing.dart';

class ViewListingsPage extends StatefulWidget {
  @override
  _ViewListingsPageState createState() => _ViewListingsPageState();
}

class _ViewListingsPageState extends State<ViewListingsPage> {

  Future listingsFuture;

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
    return listings;
  }

  _createListings(var listings) {
    print(listings);
    List<Widget> widgetListingsActive = [];
    List<Widget> widgetListingsInactive = [];
    List<Widget> widgetListings = [];
    for (int i = 0; i < listings.length; i++) {
      if (listings[i]['active'] == true) {
        widgetListingsActive.add(
          Padding(
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
        );
      } else {
        widgetListingsInactive.add(
          Padding(
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
              ],
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
