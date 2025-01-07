
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:glancey/call_sreen.dart';
import 'package:glancey/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async{
  runApp(const MyApp());
  await requestPermissions();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey,
              disabledForegroundColor: Colors.grey,
              side: const BorderSide(color:Color(0xFF247D80)),
              padding: const EdgeInsets.symmetric(vertical: 18,horizontal: 18),
              textStyle: const TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )
        ),
      ),
      home: const HomeScreen()
        
    );
  }
}

Future<void> requestPermissions() async {
  // Request camera permission
  var cameraStatus = await Permission.camera.request();
  if (cameraStatus.isDenied) {
    print("Camera permission denied");
    return;
  }

  // Request microphone permission
  var microphoneStatus = await Permission.microphone.request();
  if (microphoneStatus.isDenied) {
    print("Microphone permission denied");
    return;
  }

  // Both permissions granted
  print("Camera and Microphone permissions granted");
}



