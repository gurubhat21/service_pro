import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:service_pro/app.dart';
import 'package:service_pro/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set Google Sign-In server client ID
  // Get this from: Firebase Console → Authentication → Sign-in method → Google → Web Client ID
  // It looks like: xxxxx-xxxxx.apps.googleusercontent.com
  AuthService.setServerClientId(
    '// TODO: Replace with your Web Client ID from Firebase Console',
  );

  runApp(const ServiceProApp());
}
