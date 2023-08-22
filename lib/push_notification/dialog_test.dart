import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/assistants/Assistant_methods.dart';
import 'package:driver_app/global/global.dart';
import 'package:driver_app/splash_screen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/push_notification/push_notification_system.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Model_class/user_ride_request_informations.dart';

class NotificationDialogBox22 extends StatefulWidget {

  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox22({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox22> createState() => _NotificationDialogBox22State();
}

class _NotificationDialogBox22State extends State<NotificationDialogBox22> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("New Uber Request", style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10),
            Text("Rider name: ${widget.userRideRequestDetails?.userName}"),
            SizedBox(height: 10),
            Text("Pickup address: ${widget.userRideRequestDetails?.originAddress}"),
            SizedBox(height: 10),
            Text("Dropoff address: ${widget.userRideRequestDetails?.destinationAddress}"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: (){},
                  child: Text("Accept"),
                ),
                ElevatedButton(
                  onPressed: (){},
                  child: Text("Reject"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


