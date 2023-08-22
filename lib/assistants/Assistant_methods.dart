import 'dart:async';

import 'package:driver_app/assistants/request_assistant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


import '../Model_class/Direction_details_info.dart';
import '../Model_class/directions.dart';
import '../Model_class/user_model.dart';
import '../global/global.dart';
import '../global/map_key.dart';
import '../info_handler/app_info.dart';

class Assistant_methods{
  static void readCurrentOnlineUserInfo () async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);
    userRef.once().then((snap){
      if(snap.snapshot.value!=null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });



  }

  static Future<String> searchAddressForGeographicCoordinates(Position position,context)async{

    String apiUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
     String humanReadAbleAddress= "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse!="Error Occurred. Failed. No response."){
      if (requestResponse["results"].isNotEmpty) {
        humanReadAbleAddress =
        requestResponse["results"][0]["formatted_address"];
      }
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadAbleAddress;
      Provider.of<AppInfo>(context ,listen : false).updatePickUpLocationAddress(userPickUpAddress);

    }

    return  humanReadAbleAddress;
  }


  static Future<DirectionDetails> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async {

    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    // if(responseDirectionApi == "Error Occured. Failed. No Response."){
    //   return "";
    // }
    print(responseDirectionApi);
    DirectionDetails directionDetailsInfo = DirectionDetails();
    if (responseDirectionApi["routes"][0]["legs"].length > 0 &&
        responseDirectionApi["routes"][0]["legs"][0]["steps"].length > 0 &&
        responseDirectionApi["routes"][0]["legs"][0]["steps"][0]["polyline"]["points"].length > 0) {
      directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["legs"][0]["steps"][0]["polyline"]["points"][0];
    } else {
      print("the list is empty");
    }

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }
  static pauseLiveLocationUpdates(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }
}