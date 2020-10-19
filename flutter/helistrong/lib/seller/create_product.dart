import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:helistrong/authenticator.dart';
import 'image_picker.dart';

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

  final TextEditingController productName = TextEditingController();
  final TextEditingController productDescription = TextEditingController();

  Future categories;
  List<Color> categorySelected = [];

  final _formKey = GlobalKey<FormState>();

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
          Colors.black,
        );
      } else {
        categorySelected.add(
          Colors.black38,
        );
      }
      convertedCategories.add(
        GestureDetector(
          onTap: () {
            if (categoryIDs.contains(categories[x]['id'])) {
              categoryIDs.remove(categories[x]['id']);
              setState(() {
                categorySelected[x] = Colors.black38;
              });
            } else {
              categoryIDs.add(categories[x]['id']);
              setState(() {
                categorySelected[x] = Colors.black;
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
                    fontSize: 12.0,
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
    productName.text = name;
    productDescription.text = description;
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
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Product Name",
                      ),
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      controller: productName,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Description",
                      ),
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400,),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      controller: productDescription,
                      maxLines: null,
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    SizedBox(
                      height: 70.0,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: _buildCategories(snapshot.data),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      height: 250,
                      child: GridView.count(
                        crossAxisCount: 3,
                        children: List.generate(imageURLS.length, (index) {
                          return Image(
                            image: NetworkImage(imageURLS[index]),
                            width: 250,
                            height: 250,
                          );
                        }),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black12
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp(
                          description: productDescription.text,
                          name: productName.text,
                          categoryIDs: categoryIDs,
                        )));
                      },
                      child: Container(
                        height: 40.0,
                        width: 150.0,
                        child: Center(
                          child: Text(
                            "Pick Images",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black87,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: Colors.black,
                          )
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35.0,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState.validate() == true) {
                          var params = {};
                          params['active'] = true;
                          params['name'] = productName.text;
                          params['description'] = productDescription.text;
                          params['image_urls'] = imageURLS;
                          String url = "https://helistrong.com/api/v1/products";
                          final http.Response response = await http.post(
                            url,
                            headers: {
                              'Content-type': 'application/json',
                              'Accept': 'application/json',
                              'Authorization': 'Bearer ${currentUser.userToken}'
                            },
                            body: jsonEncode(params),
                          );
                          if (response.statusCode == 201) {
                            Navigator.pushNamedAndRemoveUntil(context, '/ViewProducts', ModalRoute.withName('/ViewProducts'));
                          }
                        }
                      },
                      child: Container(
                        height: 55.0,
                        width: 250.0,
                        child: Center(
                          child: Text(
                            "CREATE!",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.blue,
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Text("loading...");
          }
        },
      ),
    );
  }
}
