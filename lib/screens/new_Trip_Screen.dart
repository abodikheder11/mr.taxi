import 'dart:async';

import 'package:driver_app/Model_class/user_ride_request_informations.dart';
import 'package:driver_app/assistants/Assistant_methods.dart';
import 'package:driver_app/global/global.dart';
import 'package:driver_app/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class NewTripScreen extends StatefulWidget {


  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails});
  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyLine = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocater = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";


  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng, bool darkTheme) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait....",),
    );

    var directionDetailsInfo = await Assistant_methods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty){
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyLine.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      setOfPolyLine.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });

  }



  bool isRequestDirectionDetails = false;


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveAssignDriverDetailsToRequest();

  }
  getDriverLocationUpdates(){

  LatLng oldLatLng =LatLng(0, 0);
   streamSubscriptionDriverLivePosition = Geolocator.getPositionStream().listen((Position position) {
     driverCurrentPosition = position;
     onlineDriverCurrentPosition = position;
     LatLng latLngLiveDriverPosition = LatLng(onlineDriverCurrentPosition!.latitude , onlineDriverCurrentPosition!.longitude);

     Marker animatingMarker = Marker(
       markerId: MarkerId("animatedMarker"),
       position: latLngLiveDriverPosition,
       icon: iconAnimatedMarker!,
       infoWindow: InfoWindow(title: "This is Your Position"),
     );
     setState(() {
       CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition , zoom: 18);
       newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
       
       setOfMarkers.removeWhere((element) => element.markerId.value == "animatedMarker");
       setOfMarkers.add(animatingMarker);
     });
    oldLatLng = latLngLiveDriverPosition;
    updateDurationTime();

    Map driverLatLngDataMap = {
      "latitude" : onlineDriverCurrentPosition!.latitude.toString(),
      "longitude" : onlineDriverCurrentPosition!.longitude.toString(),
    };
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);

   });
  }

  updateDurationTime()async{
  if(isRequestDirectionDetails == false){
    isRequestDirectionDetails =  true;
    if(onlineDriverCurrentPosition == null){
      return ;
    }
    var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
    var destiantionLatLng;
    if(rideRequestStatus == "accepted"){
      destiantionLatLng = widget.userRideRequestDetails!.originLatLng;
    }
    else{
      destiantionLatLng = widget.userRideRequestDetails!.destinationLatLng;
    }
    var directionInformation = await Assistant_methods.obtainOriginToDestinationDirectionDetails(originLatLng, destiantionLatLng);
    if(directionInformation != null){
      setState(() {
        durationFromOriginToDestination = directionInformation.duration_text!;
      });
    }
    isRequestDirectionDetails = false;

  }
  }


  createDriverIconMarker(){
  if(iconAnimatedMarker == null){
    ImageConfiguration imageConfiguration = createLocalImageConfiguration(context , size: Size(2, 2));
    BitmapDescriptor.fromAssetImage(imageConfiguration, "images/taxi.png").then((value){
      iconAnimatedMarker = value;
    });
  }
  }

  saveRideRequestIdToDriverHistory(){
  DatabaseReference tripHistoryRef = FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("tripsHistory");
  tripHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(true);
  }

  saveAssignDriverDetailsToRequest(){
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!);
  Map driverLocationDataMap = {
    "latitude" : driverCurrentPosition!.latitude.toString(),
    "longitude" : driverCurrentPosition!.longitude.toString(),
  };
  if (databaseReference.child("driverId") != "waiting"){
    databaseReference.child("driverLocation").set(driverLocationDataMap);

    databaseReference.child("status").set("accepted");
    databaseReference.child("driverId").set(onlineDriverData.id);
    databaseReference.child("driverName").set(onlineDriverData.name);
    databaseReference.child("driverPhone").set(onlineDriverData.phone);
    databaseReference.child("driverRatings").set(onlineDriverData.ratings);
    databaseReference.child("car_details").set(onlineDriverData.car_model.toString() + " " + onlineDriverData.car_number.toString()+ " (" + onlineDriverData.car_color.toString() + ")" );

    saveRideRequestIdToDriverHistory();
  }
  else{
    Fluttertoast.showToast(msg: "This Ride is Already Accepted By Another Driver");
  }
  }



  @override
  Widget build(BuildContext context) {

  createDriverIconMarker();
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyLine,
            onMapCreated: (GoogleMapController controller){
            _controllerGoogleMap.complete(controller);
            newTripGoogleMapController = controller;
            setState(() {
              mapPadding = 350;
            });
            var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

            var userPickUpLatLng = widget.userRideRequestDetails!.originLatLng;

            drawPolyLineFromOriginToDestination(driverCurrentLatLng , userPickUpLatLng! , darkTheme);
    },
          )
        ],
      ),
    );
  }
}
