import 'package:flutter/cupertino.dart';
import 'package:helistrong/purchased/buyer_purchases.dart';
import 'package:helistrong/purchased/seller_purchases.dart';
import 'package:flutter/material.dart';

class RecentActivityPage extends StatefulWidget {
  @override
  _RecentActivityPageState createState() => _RecentActivityPageState();
}

class _RecentActivityPageState extends State<RecentActivityPage> {

  int _currentIndex = 0;
  List<Color> _activeColors = [
    Colors.black,
    Colors.grey,
  ];
  List<double> _chosenWidth = [
    2.5,
    1.0,
  ];
  List<FontWeight> _fontWeight = [
    FontWeight.bold,
    FontWeight.normal,
  ];

  final List<Widget> _tabs = [
    BuyerPurchases(),
    SellerPurchases(),
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                if(_activeColors[0] != Colors.black) {
                  setState(() {
                    _fontWeight[0] = FontWeight.bold;
                    _activeColors[0] = Colors.black;
                    _chosenWidth[0] = 2.5;
                    _fontWeight[1] = FontWeight.normal;
                    _activeColors[1] = Colors.grey;
                    _chosenWidth[1] = 1.0;
                    _currentIndex = 0;
                  });
                }
              },
              child: Container(
                height: 40.0,
                width: 150.0,
                child: Center(
                  child: Text(
                    "BOUGHT",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: _fontWeight[0],
                      color: _activeColors[0],
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: _chosenWidth[0], color: _activeColors[0]),
                  ),
                ),
              ),
            ),
            Container(
              height: 25.0,
              width: 1.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                )
              ),
            ),
            GestureDetector(
              onTap: (){
                if(_activeColors[1] != Colors.black) {
                  setState(() {
                    _chosenWidth[1] = 2.5;
                    _fontWeight[1] = FontWeight.bold;
                    _activeColors[1] = Colors.black;
                    _chosenWidth[0] = 1.0;
                    _fontWeight[0] = FontWeight.normal;
                    _activeColors[0] = Colors.grey;
                    _currentIndex = 1;
                  });
                }
              },
              child: Container(
                height: 40.0,
                width: 150.0,
                child: Center(
                  child: Text(
                    "SOLD",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: _fontWeight[1],
                      color: _activeColors[1],
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: _chosenWidth[1], color: _activeColors[1]),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Container(
            height: 1.0,
            width: 50.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey
              )
            ),
          ),
        ),
        Expanded(child: _tabs[_currentIndex]),
      ],
    );
  }
}
