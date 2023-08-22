



import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/Model_class/user_ride_request_informations.dart';
import 'package:driver_app/global/global.dart';
import 'package:driver_app/push_notification/dialog_test.dart';
import 'package:driver_app/push_notification/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    print("Context222: $context");
    //1. Teminated
    //When the app is closed and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){
      if(remoteMessage != null && remoteMessage.data["rideRequestId"] != null){
        print("Initial message data: ${remoteMessage.data["rideRequestId"]}");
        readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
      }
    });

    //2. Foreground
    //When the app is open and receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage != null && remoteMessage.data["rideRequestId"] != null){
        print("Initial message data: ${remoteMessage.data["rideRequestId"]}");
        readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
      }
    });

    //3. Background
    //When the app is in the background and opened directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage != null && remoteMessage.data["rideRequestId"] != null){
        print("Initial message data: ${remoteMessage.data["rideRequestId"]}");
        readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
      }
    });
  }

  readUserRideRequestInformation(String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).child("driverId").onValue.listen((event) {
      if(event.snapshot.value == "waiting" || event.snapshot.value == firebaseAuth.currentUser!.uid){
        FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).once().then((snapData){
          if(snapData.snapshot.value != null){



            double originLat = ((snapData.snapshot.value! as Map)["origin"] != null && (snapData.snapshot.value! as Map)["origin"]["latitude"] != null) ? double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]) : 0.0;
            double originLng = ((snapData.snapshot.value! as Map)["origin"] != null && (snapData.snapshot.value! as Map)["origin"]["longitude"] != null) ? double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]) : 0.0;

            String originAddress = (snapData.snapshot.value! as Map)["originAddress"];


            double destinationLat = ((snapData.snapshot.value! as Map)["destination"] != null && (snapData.snapshot.value! as Map)["destination"]["latitude"] != null) ? double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]) : 0.0;
            double destinationLng = ((snapData.snapshot.value! as Map)["destination"] != null && (snapData.snapshot.value! as Map)["destination"]["longitude"] != null) ? double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]) : 0.0;

            String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

            String? rideRequestId = snapData.snapshot.key;

            UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();
            userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
            userRideRequestDetails.originAddress = originAddress;
            userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
            userRideRequestDetails.destinationAddress = destinationAddress;
            userRideRequestDetails.userName = userName;
            userRideRequestDetails.userPhone = userPhone;

            userRideRequestDetails.rideRequestId = rideRequestId;

            showDialog(
                context: context,
                builder: (BuildContext context) => NotificationDialogBox(userRideRequestDetails: userRideRequestDetails,)
            );
          }
          else{
            Fluttertoast.showToast(msg: "This Ride Request Id do not exists.");
          }
        });
      }
      else{
        Fluttertoast.showToast(msg: "This Ride Request has been cancelled");
      }
    });
  }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM registration Token: ${registrationToken}");

    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}


