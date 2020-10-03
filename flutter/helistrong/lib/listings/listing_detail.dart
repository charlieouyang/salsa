import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:helistrong/models/listing.dart';
import 'package:helistrong/models/product.dart';
import 'package:helistrong/models/review.dart';
import 'package:helistrong/models/user.dart';
import 'package:helistrong/purchase/buy_dialog.dart';
import 'package:helistrong/reviews/review_item.dart';
import 'package:http/http.dart' as http;
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../authenticator.dart';


class ListingDetail extends StatefulWidget {

  final String listingId;

  // In the constructor, require a Todo.
  const ListingDetail({Key key, @required this.listingId}) : super(key: key);

  @override
  _ListingDetailState createState() => _ListingDetailState();
}

class _ListingDetailState extends State<ListingDetail> {

  int _currentImage = 0;
  Listing listingDetail;
  bool dataLoaded = false;

  Future<Listing> _getListingInfo(String listingId) async {
    print(listingId);
    if (this.dataLoaded) {
      print('ALREADY LOADED');
      return this.listingDetail;
    }

    var headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${currentUser.userToken}'
    };

    print('Making request for listing and product');
    String url = "https://helistrong.com/api/v1/listings/$listingId?embed=product";
    final http.Response listingResponse = await http.get(
      url,
      headers: headers
    );
    print('Product/listing request finished');
    var listing_ = json.decode(listingResponse.body);
    var product_ = listing_['product'];
    var productId = product_['id'];

    print('Making request for reviews');
    url = "https://helistrong.com/api/v1/reviews?product_id=$productId";
    final http.Response reviewsResponse = await http.get(
        url,
        headers: headers
    );
    print('Reviews request Finished');

    var reviewsResponse_ = json.decode(reviewsResponse.body);

    print('Making request for user that created listing');
    url = "https://helistrong.com/api/v1/user_accounts/${listing_['user_id']}";
    final http.Response userResponse = await http.get(
        url,
        headers: headers
    );
    print('User request Finished');

    var userResponse_ = json.decode(userResponse.body);
    User user = User(userResponse_['id'],
        userResponse_['name'],
        userResponse_['email'],
        userResponse_['extradata'],
        userResponse_['user_role_id'],
        DateTime.parse(userResponse_['created_at']),
        DateTime.parse(userResponse_['updated_at']));

    List<Review> reviews = [];
    for (var reviewObject in reviewsResponse_) {
      int numStars = reviewObject['numstars'];
      print(numStars);
      reviews.add(Review(
        reviewObject['id'],
        reviewObject['name'],
        reviewObject['description'],
        numStars.toDouble(),
        reviewObject['purchase_id'],
        reviewObject['user_id'],
        DateTime.parse(reviewObject['created_at']),
        DateTime.parse(reviewObject['updated_at']),
      ));
    }

    var listingDetail = Listing(
        listing_['id'],
        listing_['active'],
        listing_['name'],
        listing_['price'],
        DateTime.parse(listing_['updated_at']),
        listing_['description'],
        DateTime.parse(listing_['created_at']),
        listing_['amount_available'],
        listing_['product_id'],
        user,
        Product(product_['id'],
            product_['active'],
            product_['name'],
            DateTime.parse(product_['updated_at']),
            product_['description'],
            DateTime.parse(product_['created_at']),
            product_['avg_numstars'],
            product_['image_urls'].cast<String>(),
            user,
            reviews));

    listingDetail.product.reviews.sort((b, a) => a.createdAt.compareTo(b.createdAt));
    this.dataLoaded = true;
    return listingDetail;
  }

  // user defined function
  void _showBuyDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return BuyDialog(listing: listingDetail);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('IN LISTING_DETAIL PAGE');
    print(widget.listingId);

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
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Colors.black,
            onPressed: _showBuyDialog,
          ),
        ],
        backgroundColor: Colors.white,
        title: Text(
          "View Listing",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Listing>(
          future: _getListingInfo(widget.listingId),
          builder: (BuildContext context, AsyncSnapshot<Listing> snapshot) {
            List<Widget> children;

            if (snapshot.hasData) {
              //Data retrieved!
              print('Data retrieved!');
              listingDetail = snapshot.data;
              int totalReviews = listingDetail.product.reviews.length;

              List<Review> portionReviews = listingDetail.product.reviews;
              if (portionReviews.length > 3) {
                portionReviews = portionReviews.sublist(0, 3);
              }

              return ListView(
                children: [
                  CarouselSlider(
                    items: listingDetail.product.imageUrls.map((item) => Container(
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
                    )).toList(),
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
                            listingDetail.name,
                            style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w900,),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "\$ ${listingDetail.price}",
                                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ]
                          ),
                        ),
                        Text(
                          "Available: ${listingDetail.amountAvailable.toInt()}",
                          style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600,),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                    child: Text(
                      "From ${listingDetail.user.name}",
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    child: Text(
                      listingDetail.description,
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700,),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 14, 8),
                    child: RatingBar(
                      initialRating: listingDetail.product.avgNumStars,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 25,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: Text(
                      "Reviewed $totalReviews times",
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700,),
                    ),
                  ),

                ]..addAll(portionReviews.map((value) {
                  return ReviewItem(review: value);
                }).toList(),),

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