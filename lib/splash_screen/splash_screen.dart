import 'dart:async';
import 'package:flutter/material.dart';
import '../assistants/Assistant_methods.dart';
import '../global/global.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer(){
    Timer(Duration(seconds: 3),() async{
      if(await firebaseAuth.currentUser != null){
        Assistant_methods.readCurrentOnlineUserInfo();
        Navigator.push(context, MaterialPageRoute(builder :(c)=>  MainScreen(),),);
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Mr Taxi",style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),),
      ),
    );
  }
}
