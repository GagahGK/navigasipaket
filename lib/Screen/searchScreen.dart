import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllWidgets/Divider.dart';
import 'package:rider_app/AllWidgets/configMaps.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/Assistants/requestAssistants.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/Models/placePredictions.dart';

class SearchScreen extends StatefulWidget {
  final String uid;

  const SearchScreen({Key key, this.uid}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePrediction> placePredictionsList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;

    // ignore: unused_local_variable
    String _scanBarcode = '';

    Future<void> scanQR() async {
      String barcodeScanRes;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);
        print(barcodeScanRes);
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      if (barcodeScanRes != '-1') {
        var withoutslash = barcodeScanRes.split('/');
        var longitudelatitude = withoutslash[6];
        var longitudelatitudewithat = longitudelatitude.split('@');
        var longitudelatitudewithoutat = longitudelatitudewithat[1];
        var longitudelatitudewithcoma = longitudelatitudewithoutat.split(',');

        var namaTempat = withoutslash[5];
        var namaTempatwithplus = namaTempat.split('+');
        var namaTempatwithoutplus = '';

        for (var i = 0; i < namaTempatwithplus.length; i++) {
          namaTempatwithoutplus += "${namaTempatwithplus[i]} ";
        }

        print(namaTempatwithoutplus);

        Address dropOffAddress = new Address();
        dropOffAddress.longitude = double.parse(longitudelatitudewithcoma[0]);
        dropOffAddress.latitude = double.parse(longitudelatitudewithcoma[1]);
        dropOffAddress.placeName = namaTempatwithoutplus;

        findPlace(dropOffAddress.placeName);
      }

      setState(() {
        _scanBarcode = barcodeScanRes;
      });
    }

    void readHistoryFB(String uid) async {
      DatabaseReference dbRef =
          FirebaseDatabase.instance.reference().child("Users");

      var oy;
      await dbRef
          .child(uid)
          .child('history')
          .once()
          .then((DataSnapshot dataSnapshot) {
        Map listHistory = dataSnapshot.value;

        List idhistory = listHistory.keys.toList();

        for (var i = 0; i < idhistory.length; i++) {
          oy = listHistory[idhistory[i]]['placeId'].toString();
          findPlaceByID(oy);
        }
      });
      // print(listHistory);
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215.0,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              )
            ]),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 25.0, top: 25.0, right: 25.0, bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 5.0),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Center(
                        child: Text(
                          "Set Drop off",
                          style: TextStyle(
                              fontSize: 18.0, fontFamily: "Brand-Bold"),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                hintText: "PickUp Location",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              onChanged: (val) {
                                findPlace(val);
                              },
                              controller: dropOffTextEditingController,
                              decoration: InputDecoration(
                                hintText: "Where to?",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => scanQR(),
                child: Text("QR Scanner"),
              ),
              TextButton(
                onPressed: () {
                  placePredictionsList.clear();
                  readHistoryFB(widget.uid);
                },
                child: Text("History"),
              ),
            ],
          ),
          (placePredictionsList.length > 0)
              ? Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0.0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePrediction:
                            placePredictionsList[index] ?? PlacePrediction(),
                        uid: widget.uid,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        DividerWidget(),
                    itemCount: placePredictionsList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapkey&sessiontoken=1234567890";

      var res = await RequestAssistant.getRequest(Uri.parse(autoCompleteUrl));

      if (res == "failed") {
        return;
      }

      if (res["status"] == "OK") {
        var predictions = res["predictions"];

        var placeList = (predictions as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();

        setState(() {
          placePredictionsList = placeList;
        });
      }
    }
  }

  void findPlaceByID(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeName&key=$mapkey";

      var res = await RequestAssistant.getRequest(Uri.parse(autoCompleteUrl));

      if (res == "failed") {
        return;
      }

      if (res["status"] == "OK") {
        Address address = Address();
        address.placeFormattedAddress = res["result"]["vicinity"];
        address.placeName = res["result"]["name"];
        address.placeId = placeName;
        address.latitude = res["result"]["geometry"]["location"]["lat"];
        address.longitude = res["result"]["geometry"]["location"]["lng"];

        PlacePrediction pred = PlacePrediction();

        pred.secondaryText = address.placeFormattedAddress;
        pred.mainText = address.placeName;
        pred.placeId = address.placeId;

        setState(() {
          placePredictionsList.add(pred);
        });
      }
    }
  }
}

void addHistoryFB(String uid, Address address) {
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Users");

  dbRef
      .child(uid)
      .child('history')
      .child(Random().nextInt(10000).toString())
      .set({
    "latitude": address.latitude,
    "longitude": address.longitude,
    "placeFormattedAddress": address.placeFormattedAddress,
    "placeId": address.placeId,
    "placeName": address.placeName
  });
}

class PredictionTile extends StatelessWidget {
  final PlacePrediction placePrediction;
  final String uid;

  PredictionTile({Key key, this.placePrediction, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlacedAddressedDetails(placePrediction.placeId, uid, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        placePrediction.mainText ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        placePrediction.secondaryText ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      SizedBox(
                        width: 2.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> checkerHistory(String uid, Address address) async {
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Users");

  bool status = false;

  try {
    await dbRef
        .child(uid)
        .child('history')
        .once()
        .then((DataSnapshot dataSnapshot) {
      Map listHistory = dataSnapshot.value;

      List idhistory = listHistory.keys.toList();

      for (var i = 0; i < idhistory.length; i++) {
        if (address.placeName ==
            listHistory[idhistory[i]]['placeName'].toString()) {
          status = true;
        }
      }
    });
  } catch (e) {
    return false;
  }

  if (status == false) {
    return false;
  } else {
    return true;
  }
}

void getPlacedAddressedDetails(
    String placeId, String uid, BuildContext context) async {
  showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
            message: "Setting Dropoff, Please wait...",
          ));

  String placeDetailsUrl =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey";

  var res = await RequestAssistant.getRequest(Uri.parse(placeDetailsUrl));

  Navigator.pop(context);

  if (res == "failed") {
    return;
  }

  if (res["status"] == "OK") {
    Address address = Address();
    address.placeName = res["result"]["name"];
    address.placeId = placeId;
    address.latitude = res["result"]["geometry"]["location"]["lat"];
    address.longitude = res["result"]["geometry"]["location"]["lng"];

    Future<bool> histostat = checkerHistory(uid, address);
    if (await histostat == false) {
      addHistoryFB(uid, address);
    }

    Provider.of<AppData>(context, listen: false)
        .updatedropOffLocationAddress(address);
    print("This is Drop Off Location :: ");
    print(address.placeName);

    Navigator.pop(context, "obtainDirection");
  }
}
