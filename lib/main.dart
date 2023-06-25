import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ani_meet/pages/root_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:ani_meet/pages/signin_page.dart';
import 'package:ani_meet/theme/colors.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
    );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);
  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user != null) {
      print(user.uid);
      runApp(MaterialApp(
        theme: ThemeData(colorScheme: ColorScheme.fromSwatch().copyWith(secondary: hot_pink)),
        debugShowCheckedModeBanner: false,
        home: RootPage(),
      ));
    }
    else{
      print('Not logged in');
      runApp(MaterialApp(
        theme: ThemeData(colorScheme: ColorScheme.fromSwatch().copyWith(secondary: hot_pink)),
        debugShowCheckedModeBanner: false,
        home: SignInScreen(),
      ));
    }
  });
}
