import 'package:flutter/material.dart';
import 'package:helistrong/seller/create_product.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:convert';
import 'package:helistrong/authenticator.dart';

class MyApp extends StatefulWidget {
  MyApp({this.description, this.name, this.categoryIDs});
  final List<String> categoryIDs;
  final String name;
  final String description;

  @override
  _MyAppState createState() => new _MyAppState(
    categoryIDs: categoryIDs,
    name: name,
    description: description,
  );
}

class _MyAppState extends State<MyApp> {
  _MyAppState({this.categoryIDs, this.name, this.description});
  final List<String> categoryIDs;
  final String name;
  final String description;

  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  Future<void> submitAssets() async {
    print('SUBMITTING!');

    // string to uri
    Uri uri = Uri.parse('https://helistrong.com/api/v1/images');

    // create multipart request
    http.MultipartRequest request = http.MultipartRequest("POST", uri);

    for (int i=0; i<images.length; i++) {
      ByteData byteData;
      ByteData tempByteData = await images[i].getByteData();

      int imageSize = tempByteData.lengthInBytes;
      if (imageSize > 10000000) {
        // Image is 10MB or greater
        print('GOT HERE 1');
        byteData = await images[i].getByteData(quality: 25);
      } else if (imageSize > 1000000 && imageSize<= 10000000) {
        // Image is between 1MB to 10MB
        print('GOT HERE 2');
        byteData = await images[i].getByteData(quality: 50);
      } else {
        // Image is 1MB or smaller
        print('GOT HERE 3');
        byteData = tempByteData;
      }

      List<int> imageData = byteData.buffer.asUint8List();

      print('PRINTING LENGTH OF BYTES');
      print(imageData.length);

      // add file to multipart
      request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageData,
            filename: i.toString() + '.png',
          )
      );
    }

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${currentUser.userToken}'
    });
    // send

    print('request finished building');
    print(request);
    print(request.fields);
    print(request.headers);
    print(request.files);
    print('sending request...');
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print('Finished! Response');
    print(response.body);

    var responseObject = json.decode(response.body);
    var statusCode = responseObject['status_code'];
    // Status codes
    if (statusCode == 201) {
      // 201 - Success: Images created
      List<String> fileUrls = [];
      for (int x = 0; x < responseObject['file_urls'].length; x++) {
        fileUrls.add(responseObject['file_urls'][x]);
      }
      print('GOT FILE URLS! Going to add them to the product');
      print(fileUrls);
      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateProduct(
        description: description,
        categoryIDs: categoryIDs,
        name: name,
        imageURLS: fileUrls,
      )));
    } else if (statusCode == 400) {
      // 400 - Bad request
      var errorDetails = responseObject['detail'];
      print('UH OH! This request is not valid.');
      print(errorDetails);

    } else if (statusCode == 500) {
      // 500 - Internal Server Error
      var errorDetails = responseObject['detail'];
      print('UH OH! An error happened on the server side. Please try again later');
      print(errorDetails);

    } else {
      // UNHANDLED
      print('SHOULD NEVER BE HERE');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Center(child: Text('Error: $_error')),
            RaisedButton(
              child: Text("Pick"),
              onPressed: loadAssets,
            ),
            RaisedButton(
              child: Text("Submit"),
              onPressed: submitAssets,
            ),
            Expanded(
              child: buildGridView(),
            )
          ],
        ),
      ),
    );
  }
}

