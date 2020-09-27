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

import 'listing_detail.dart';


class MainListingsPage extends StatefulWidget {
  @override
  _MainListingsPageState createState() => _MainListingsPageState();
}

class _MainListingsPageState extends State<MainListingsPage> {
  final SearchBarController<Listing> _searchBarController = SearchBarController();

  Future<List<Listing>> _searchListings(String text) async {

    String url = "https://helistrong.com/api/v1/listings?embed=product&name=$text";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJjb20uc2Fsc2EuY29ubmV4aW9uIiwiaWF0IjoxNjAxMjI1NDkwLCJleHAiOjE2MDEzMTE4OTAsInVzciI6eyJpZCI6IjJlZjlmMzNlLTI5MWEtNGZiMC04M2RiLWQyNTAzMTIyODk4NiIsIm5hbWUiOiJDaGFybGllIE91IFlhbmciLCJ1cGRhdGVkX2F0IjoiMjAyMC0wOS0wN1QwMjowMzo1OC4xNTUwNDUiLCJjcmVhdGVkX2F0IjoiMjAyMC0wOS0wNVQxODoyMToyOC40MjE2NjAiLCJlbWFpbCI6ImNoYXJsaWVvdXlhbmdAZ21haWwuY29tIiwiZXh0cmFkYXRhIjoie30iLCJ1c2VyX3JvbGVfaWQiOiI1MTQ4NGQyYy03YTNkLTRmZTktYjEwZC01MmQ2ZTc0MDgwMzEifSwicHJtIjp7InRpdGxlIjoiVXNlciIsImRlc2NyaXB0aW9uIjoiUmVndWxhciB1c2VyIiwiaWQiOiI1MTQ4NGQyYy03YTNkLTRmZTktYjEwZC01MmQ2ZTc0MDgwMzEifX0.IIlBA_-i2oqBnwwQ3WxJ7Sk5o6uuPckalc6TRQJDOn0'
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
          listing_['updated_at'],
          listing_['description'],
          listing_['created_at'],
          listing_['amount_available'],
          listing_['product_id'],
          listing_['user_id'],
          Product(product_['id'],
                  product_['active'],
                  product_['name'],
                  product_['updated_at'],
                  product_['description'],
                  product_['created_at'],
                  product_['avg_numstars'],
                  product_['image_urls'].cast<String>(),
                  product_['user_id'],
                  []))
      );
    }
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
