

import 'package:flutter/material.dart';
//import 'login_form_data/login_screen_ui.dart';
import'login_form_data/login_screen_ui.dart';
//import 'registeration_form_data/register_screen_ui.dart';
import 'package:get/get.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Casper-We Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}