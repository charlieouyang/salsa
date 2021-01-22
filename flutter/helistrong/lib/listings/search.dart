import 'dart:convert';

import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';

import 'dart:math';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:helistrong/listings/search_item.dart';
import 'package:helistrong/models/product.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/listing.dart';
import 'package:http/http.dart' as http;
import 'package:helistrong/authenticator.dart';
import 'listing_detail.dart';


class MainListingsPage extends StatefulWidget {
  @override
  _MainListingsPageState createState() => _MainListingsPageState();
}

class _MainListingsPageState extends State<MainListingsPage> {
  final SearchBarController<Listing> _searchBarController = SearchBarController();

  Future<List<Listing>> _searchListings(String text) async {

    print('currentUser.userToken');
    print(currentUser.userToken);

    String url = "https://helistrong.com/api/v1/listings?embed=product&name=$text";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      },
    );

    var listingDataParsed = json.decode(response.body);

    List<Listing> listings = [];
    for (int i = 0; i < listingDataParsed.length; i++) {
      var listing_ = listingDataParsed[i];
      var product_ = listing_['product'];
      listings.add(Listing(
          listing_['id'],
          listing_['active'],
          listing_['name'],
          listing_['price'],
          DateTime.parse(listing_['updated_at']),
          listing_['description'],
          DateTime.parse(listing_['created_at']),
          listing_['amount_available'],
          listing_['product_id'],
          null,
          Product(product_['id'],
                  product_['active'],
                  product_['name'],
                  DateTime.parse(product_['updated_at']),
                  product_['description'],
                  DateTime.parse(product_['created_at']),
                  product_['avg_numstars'],
                  product_['image_urls'].cast<String>(),
                  null,
                  []))
      );
    }

    print('listings');
    print(listings);
    return listings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SearchBar<Listing>(
          searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
          headerPadding: EdgeInsets.symmetric(horizontal: 10),
          listPadding: EdgeInsets.symmetric(horizontal: 10),
          onSearch: _searchListings,
          searchBarController: _searchBarController,
          placeHolder: Text("No results"),
          cancellationWidget: Text("Cancel"),
          emptyWidget: Text("Uh oh! Found nothing"),
          onCancelled: () {
            print("Cancelled triggered");
          },
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 1,
          onItemFound: (Listing listing, int index) {
            //Default Butters UH OH url for no images
            var imageUrl = "https://pbs.twimg.com/profile_images/823057704038133760/Ol_jkIFF_400x400.jpg";
            if (listing.product.imageUrls.length > 0) {
              imageUrl = listing.product.imageUrls[0];
            }
            return GestureDetector(
              child: Container(
                child: ListingItem(
                  thumbnail: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.network(imageUrl),
                    ),
                  ),
                  name: listing.name,
                  description: listing.description,
                  price: listing.price,
                  amountAvailable: listing.amountAvailable.toInt(),
                  avgNumStars: listing.product.avgNumStars,
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
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListingDetail(listingId: listing.id)));
              },
            );
          },
        ),
      ),
    );
  }
}
