import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllWidgets/configMaps.dart';
import 'package:rider_app/Assistants/requestAssistants.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/Models/directDetails.dart';

class AssistantMethod {
  static const String BASE_API_URL = 'https://maps.googleapis.com/maps/api/';
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    var st = new List<String>.filled(6, '');
    String url =
        "${BASE_API_URL}geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";

    var response = await RequestAssistant.getRequest(Uri.parse(url));

    if (response != "failed") {
      //placeAddress = response["results"][0]["formatted_address"];
      var result = response["results"][0]["address_components"];
      for (var i = 1; i < 6; i++) {
        st[i] = result[i]["long_name"];
      }
      placeAddress = st.join(', ');

      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "${BASE_API_URL}directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapkey";

    var res = await RequestAssistant.getRequest(Uri.parse(directionUrl));
    print(directionUrl);
    print(res);
    if (res == "request failed" || res["status"] == "ZERO_RESULTS") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }
}
