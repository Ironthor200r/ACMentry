import 'package:analytics/home.dart';
import 'package:analytics/login.dart';
import 'package:analytics/reg.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: 'AIzaSyDy6vc6UG3NXam2IWZY4sS_PMp2VNdd52o',
              appId: '1:179222988612:android:3e8d0acb3ea83ac9acb911',
              messagingSenderId: '179222988612',
              projectId: 'my-consumer-rating'))
      : await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Homepage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/yelo.jpeg', // Replace with your actual image path or asset name
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            print('Error loading image: $error');
            return Container(); // Return an empty container or placeholder widget if the image fails to load
          },
        ),
      ),
    );
  }
}
