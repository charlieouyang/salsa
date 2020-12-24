import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:helistrong/authenticator.dart';
import 'dart:convert';
import 'image_picker.dart';

class EditProduct extends StatefulWidget {
  EditProduct({this.productName, this.description, this.categoryIDs, this.imageURLs, this.productID});
  final String productName;
  final String description;
  final List<String> categoryIDs;
  final List<String> imageURLs;
  final String productID;
  @override
  _EditProductState createState() => _EditProductState(
    productName: productName,
    description: description,
    categoryIDs: categoryIDs,
    imageURLs: imageURLs,
    productID: productID,
  );
}

class _EditProductState extends State<EditProduct> {
  _EditProductState({this.productName, this.description, this.categoryIDs, this.imageURLs, this.productID});
  final String productName;
  final String description;
  final List<String> categoryIDs;
  final List<String> imageURLs;
  final String productID;

  final TextEditingController product = TextEditingController();
  final TextEditingController productDescription = TextEditingController();

  Future categories;
  Future convertCategories;
  List<String> productCategories = [];
  List<Color> categorySelected = [];
  final _formKey = GlobalKey<FormState>();

  Future getCategories() async {
    convertProductCategories();
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

  Future convertProductCategories() async {
    String url = "https://helistrong.com/api/v1/product_categories/$productID";
    final http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      },
    );
    var body = jsonDecode(response.body);
    for (int x = 0; x < body.length; x++) {
      productCategories.add(body[x]['category_id']);
      print (productCategories);
    }
    return true;
  }

  _buildCategories(var categories) {
    List<Widget> convertedCategories = [];
    for(int x = 0; x < categories.length; x++) {
      if (productCategories.contains(categories[x]['id'])) {
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
              if (productCategories.contains(categories[x]['id'])) {
                productCategories.remove(categories[x]['id']);
                setState(() {
                  categorySelected[x] = Colors.black38;
                });
                print(productCategories);
              } else {
                productCategories.add(categories[x]['id']);
                setState(() {
                  categorySelected[x] = Colors.black;
                });
                print(productCategories);
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
    product.text = productName;
    productDescription.text = description;
    categories = getCategories();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Product",
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
                      controller: product,
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
                        children: List.generate(imageURLs.length, (index) {
                          return Image(
                            image: NetworkImage(imageURLs[index]),
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
                          name: product.text,
                          categoryIDs: categoryIDs,
                          edit: true,
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
                          params['name'] = product.text;
                          params['description'] = productDescription.text;
                          if (imageURLs.isEmpty) {
                            imageURLs.add("https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1200px-No_image_available.svg.png");
                          }
                          params['image_urls'] = imageURLs;
                          String url = "https://helistrong.com/api/v1/products/$productID";
                          final http.Response response = await http.put(
                            url,
                            headers: {
                              'Content-type': 'application/json',
                              'Accept': 'application/json',
                              'Authorization': 'Bearer ${currentUser.userToken}'
                            },
                            body: jsonEncode(params),
                          );
                          print(response.statusCode);
                          if (response.statusCode == 200) {
                            var categoryParams = {};
                            categoryParams['product_id'] = productID;
                            categoryParams['category_ids'] = productCategories;
                            final http.Response categoryResponse = await http.post(
                              "https://helistrong.com/api/v1/product_categories",
                              headers: {
                                'Content-type': 'application/json',
                                'Accept': 'application/json',
                                'Authorization': 'Bearer ${currentUser.userToken}'
                              },
                              body: jsonEncode(categoryParams),
                            );
                            print(categoryResponse.body);
                            print(categoryResponse.statusCode);
                            if (categoryResponse.statusCode == 201) {
                              Navigator.pushNamedAndRemoveUntil(context, '/HomePage', ModalRoute.withName('/HomePage'));
                            }
                          }
                        }
                      },
                      child: Container(
                        height: 55.0,
                        width: 250.0,
                        child: Center(
                          child: Text(
                            "SAVE!",
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
