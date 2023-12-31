import 'dart:async';

import 'package:driver_app/push_notification/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/Assistant_methods.dart';
import '../global/global.dart';

class HomeTapPage extends StatefulWidget {
  const HomeTapPage({Key? key}) : super(key: key);

  @override
  State<HomeTapPage> createState() => _HomeTapPageState();
}

class _HomeTapPageState extends State<HomeTapPage> {

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  var geoLocater = Geolocator();
  LocationPermission? locationPermission;
  String statusText ="Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;
  LocationPermission? _locationPermission;

  checkIfLocationPermissionAllowed()async{
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition()async{
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;
    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude  , driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 15);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadAbleAddress =await Assistant_methods.searchAddressForGeographicCoordinates(driverCurrentPosition!, context);
    print("This is our address = " + humanReadAbleAddress);


  }


  readCurrentDriverInformation()async{
    currentUser = firebaseAuth.currentUser;
    FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).once().then((snap){
      if(snap.snapshot.value != null){
      onlineDriverData.id = (snap.snapshot.value as Map)["id"];
      onlineDriverData.name = (snap.snapshot.value as Map)["name"];
      onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
      onlineDriverData.email = (snap.snapshot.value as Map)["email"];
      onlineDriverData.address = (snap.snapshot.value as Map)["address"];
      onlineDriverData.car_model = (snap.snapshot.value as Map)["car_details"]["car_model"];
      onlineDriverData.car_number = (snap.snapshot.value as Map)["car_details"]["car_number"];
      onlineDriverData.car_color = (snap.snapshot.value as Map)["car_details"]["car_color"];
      onlineDriverData.car_type = (snap.snapshot.value as Map)["car_details"]["type"];

      driverVehicleType = (snap.snapshot.value as Map)["car_details"]["type"];
      }
    });
  }

@override
  void initState() {
    // TODO: implement initState
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top:40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition:  _kGooglePlex,
          onMapCreated: (GoogleMapController controller){
            _controllerGoogleMap.complete(controller);
            newGoogleMapController=controller;
          },
        ),
        statusText != "Now Online"
            ? Container(
            height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.black87,
        ): Container(),
        Positioned(
          top: statusText != "Now Online" ? MediaQuery.of(context).size.height * 0.45: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: (){
                    if(isDriverActive != true){
                      driverisOnlineNow();
                      updateDriversLocationAtRealTime();
                      setState(() {
                        statusText = "Now Online";
                        isDriverActive = true;
                        buttonColor = Colors.transparent;
                      });
                    }else{
                      driverisOffline();
                      setState(() {
                        statusText = "Now Offline";
                        isDriverActive = false;
                        buttonColor = Colors.grey;
                      });
                      Fluttertoast.showToast(msg: "You Are Offline Now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: statusText != "Now Online"
                      ? Text(statusText,style: TextStyle(
                    fontSize:16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  ) : Icon(Icons.phonelink_ring,
                  color: Colors.white,
                  size: 26,),
                  ),
            ],
          ),
        )
      ],
    );
  }

  driverisOnlineNow()async{
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");
    ref.set("idle");
    ref.onValue.listen((event) { });
  }

  void updateDriversLocationAtRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      if (isDriverActive == true){
        if (driverCurrentPosition != null) { // add null check here
          Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
          LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
          newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
        }
      }
    });
  }
  driverisOffline() {
    if (currentUser != null) {
      Geofire.removeLocation(currentUser!.uid);
      DatabaseReference? ref = FirebaseDatabase.instance.ref().child(
          currentUser!.uid).child("newRideStatus");
      ref.onDisconnect();
      ref.remove();
      ref = null;

      Future.delayed(Duration(milliseconds: 20000), () {
        SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      });
    }
  }
}
