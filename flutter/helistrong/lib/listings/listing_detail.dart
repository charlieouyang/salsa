import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:helistrong/models/listing.dart';
import 'package:helistrong/models/product.dart';
import 'package:helistrong/models/review.dart';
import 'package:http/http.dart' as http;
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:carousel_slider/carousel_slider.dart';



class ListingDetail extends StatefulWidget {

  final String listingId;

  // In the constructor, require a Todo.
  const ListingDetail({Key key, @required this.listingId}) : super(key: key);

  @override
  _ListingDetailState createState() => _ListingDetailState();
}

class _ListingDetailState extends State<ListingDetail> {

  int _currentImage = 0;
  final List<String> imgList = ["https://thestayathomechef.com/wp-content/uploads/2014/10/Classic-Braised-Beef-Short-Ribs-3-small.jpg",
    "https://recipetineats.com/wp-content/uploads/2019/02/Slow-Cooked-Braised-Beef-Short-Ribs_3.jpg",
    "https://www.thespruceeats.com/thmb/XW_JuQ6Wk642VsnSQts9GIv-eLw=/2243x1682/smart/filters:no_upscale()/short-ribs-2500-56a20fc53df78cf772718708.jpg"];

  Future<Listing> _getListingInfo(String listingId) async {
    print(listingId);

    var headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJjb20uc2Fsc2EuY29ubmV4aW9uIiwiaWF0IjoxNjAxMjI1NDkwLCJleHAiOjE2MDEzMTE4OTAsInVzciI6eyJpZCI6IjJlZjlmMzNlLTI5MWEtNGZiMC04M2RiLWQyNTAzMTIyODk4NiIsIm5hbWUiOiJDaGFybGllIE91IFlhbmciLCJ1cGRhdGVkX2F0IjoiMjAyMC0wOS0wN1QwMjowMzo1OC4xNTUwNDUiLCJjcmVhdGVkX2F0IjoiMjAyMC0wOS0wNVQxODoyMToyOC40MjE2NjAiLCJlbWFpbCI6ImNoYXJsaWVvdXlhbmdAZ21haWwuY29tIiwiZXh0cmFkYXRhIjoie30iLCJ1c2VyX3JvbGVfaWQiOiI1MTQ4NGQyYy03YTNkLTRmZTktYjEwZC01MmQ2ZTc0MDgwMzEifSwicHJtIjp7InRpdGxlIjoiVXNlciIsImRlc2NyaXB0aW9uIjoiUmVndWxhciB1c2VyIiwiaWQiOiI1MTQ4NGQyYy03YTNkLTRmZTktYjEwZC01MmQ2ZTc0MDgwMzEifX0.IIlBA_-i2oqBnwwQ3WxJ7Sk5o6uuPckalc6TRQJDOn0'
    };
    String url = "https://helistrong.com/api/v1/listings/$listingId?embed=product";
    final http.Response listingResponse = await http.get(
      url,
      headers: headers
    );
    var listing_ = json.decode(listingResponse.body);
    var product_ = listing_['product'];

    url = "https://helistrong.com/api/v1/reviews?product_id=$listingId";
    final http.Response ReviewsResponse = await http.get(
        url,
        headers: headers
    );
    print('REQUEST FINISHED!!!!!!');

    var reviewsResponse_ = json.decode(ReviewsResponse.body);
    List<Review> reviews = [];
    for (var reviewObject in reviewsResponse_) {
      reviews.add(Review(
        reviewObject['id'],
        reviewObject['name'],
        reviewObject['description'],
        reviewObject['numStars'],
        reviewObject['purchaseId'],
        reviewObject['userId'],
        reviewObject['createdAt'],
        reviewObject['updatedAt'],
      ));
    }

    var listingDetail = Listing(
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
            reviews));

    return listingDetail;
  }

  @override
  Widget build(BuildContext context) {
    print('IN LISTING_DETAIL PAGE');
    print(widget.listingId);

    final List<Widget> imageSliders = imgList.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(3.0),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                Image.network(item, fit: BoxFit.cover, width: 1000.0),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  ),
                ),
              ],
            )
        ),
      ),
    )).toList();

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Listing>(
          future: _getListingInfo(widget.listingId),
          builder: (BuildContext context, AsyncSnapshot<Listing> snapshot) {
            List<Widget> children;

            if (snapshot.hasData) {
              //Data retrieved!
              print('Data retrieved!');
              Listing listing = snapshot.data;

              return ListView(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CarouselSlider(
                    items: imageSliders,
                    options: CarouselOptions(
                        aspectRatio: 2.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImage = index;
                          });
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 24, 14, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.name,
                            style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w900,),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "\$ ${listing.price}",
                                  style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ]
                          ),
                        ),
                        Text(
                          "Available: ${listing.amountAvailable.toInt()}",
                          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w700,),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    child: Text(
                      listing.description,
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700,),
                    ),
                  ),
                ],
              );

            } else if (snapshot.hasError) {
              //Error in retrieving data
              print('UH OH... Error retrieving data');
              return Container();
            } else {
              //Loading
              print('Loading...');
              return Column(
                  children: [
                    Container(
                      child: Expanded(
                        child: Center(
                          child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Colors.black),
                        ),
                      ),
                    ),
                  ]
              );
            }
          }
        ),
      ),
    );
  }
}