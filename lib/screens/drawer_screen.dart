import 'package:driver_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import 'login_screen.dart';
class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: darkTheme? Colors.amber.shade400 : Colors.lightBlue,
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text(
                    userModelCurrentInfo?.name ?? 'No Name',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  ),
                  SizedBox(height: 30,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder:(c)=>ProfileScreen()));
                    },
                    child: Text("Edit Profile",
                      style: TextStyle(
                      fontSize:15 ,
                        fontWeight: FontWeight.bold,
                        color: darkTheme? Colors.amber.shade400 : Colors.lightBlue,
                    ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("Your Trip", style: TextStyle(fontSize:15 , fontWeight: FontWeight.bold, color: darkTheme? Colors.amber.shade400 : Colors.lightBlue,),),

                  SizedBox(height: 30),
                  Text("Payment", style: TextStyle(fontSize:15 , fontWeight: FontWeight.bold, color: darkTheme? Colors.amber.shade400 : Colors.lightBlue,),),

                  SizedBox(height: 30),
                  Text("Notification", style: TextStyle(fontSize:15 , fontWeight: FontWeight.bold, color: darkTheme? Colors.amber.shade400 : Colors.lightBlue,),),

                  SizedBox(height: 30),
                  Text("Edit Profile", style: TextStyle(fontSize:15 , fontWeight: FontWeight.bold, color: darkTheme? Colors.amber.shade400 : Colors.lightBlue,),),

                  SizedBox(height: 30),
                  Text("Help", style: TextStyle(fontSize:15 , fontWeight: FontWeight.bold, color: darkTheme? Colors.amber.shade400 : Colors.lightBlue,),),

                  SizedBox(height: 30),
                  Text("Free Trips", style: TextStyle(fontSize:15 , fontWeight: FontWeight.bold, color: darkTheme? Colors.amber.shade400 : Colors.lightBlue,),),
                ],
              ),
              GestureDetector(
                onTap: (){
                  firebaseAuth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder:(c)=>LoginScreen()));
                },
                child: Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                      color: Colors.red,

                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
