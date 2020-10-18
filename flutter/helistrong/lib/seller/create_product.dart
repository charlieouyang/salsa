import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:helistrong/authenticator.dart';

class CreateProduct extends StatefulWidget {
  CreateProduct({this.imageURLS, this.description, this.name, this.categoryIDs});
  final List<String> imageURLS;
  final List<String> categoryIDs;
  final String name;
  final String description;
  @override
  _CreateProductState createState() => _CreateProductState(
    imageURLS: imageURLS,
    categoryIDs: categoryIDs,
    name: name,
    description: description,
  );
}

class _CreateProductState extends State<CreateProduct> {
  _CreateProductState({this.imageURLS, this.description, this.categoryIDs, this.name});
  final List<String> imageURLS;
  final List<String> categoryIDs;
  final String name;
  final String description;

  Future categories;
  List<Color> categorySelected = [];

  Future getCategories() async {
    String url = "https://helistrong.com/api/v1/categories";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      }
    );
    return jsonDecode(response.body);
  }

  _buildCategories(var categories) {
    List<Widget> convertedCategories = [];
    for(int x = 0; x < categories.length; x++) {
      if (categoryIDs.contains(categories[x]['id'])) {
        categorySelected.add(
          Colors.indigo,
        );
      } else {
        categorySelected.add(
          Colors.blue,
        );
      }
      convertedCategories.add(
        GestureDetector(
          onTap: () {
            if (categoryIDs.contains(categories[x]['id'])) {
              categoryIDs.remove(categories[x]['id']);
              setState(() {
                categorySelected[x] = Colors.blue;
              });
            } else {
              categoryIDs.add(categories[x]['id']);
              setState(() {
                categorySelected[x] = Colors.indigo;
              });
            }
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              height: 40.0,
              width: 100.0,
              child: Center(
                child: Text(
                  categories[x]['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: categorySelected[x],
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        )
      );
    }
    return convertedCategories;
  }
  @override
  void initState() {
    super.initState();
    categories = getCategories();
    //TODO SET ALL TEXTFORMFIELD VALUES AND GRIDVIEW VALUES
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Product",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/ViewProducts'));
          },
        ),
      ),
      body: FutureBuilder(
        future: categories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                //TODO TEXTFORMFIELD FOR NAME AND DESCRIPTION
                ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: _buildCategories(snapshot.data),
                ),
                //TODO FOR IMAGE PICKER
                //TODO GESTURE DETECTOR FOR POSTING
              ],
            );
          } else {
            return Text("loading...");
          }
        },
      ),
    );
  }
}
