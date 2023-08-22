import 'package:driver_app/car_info.dart';
import 'package:driver_app/splash_screen/splash_screen.dart';
import 'package:driver_app/tap_pages/home_tap.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'info_handler/app_info.dart';
import 'screens/main_screen.dart';
import 'theme_provider/theme_provider.dart';
Future<void> main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class FirebaseMessaging {
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
         create: (context) => AppInfo(),
         child:  MaterialApp(
            title: "Flutter demo",
            //themeMode: ThemeMode.system,
            theme: MyThemes.lightTheme,
            darkTheme: MyThemes.darkTheme,
            debugShowCheckedModeBanner: false,
         home: SplashScreen(),
      ),
    );
  }
}