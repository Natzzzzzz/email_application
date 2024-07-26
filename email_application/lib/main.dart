import 'package:email_application/firebase_options.dart';
import 'package:email_application/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:email_application/login/login.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.center();
    await windowManager.setTitle('Email Application');
  });


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWidget(),
    );
  }
}

class AuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  Widget firstWidget;

  if (firebaseUser == null) {
    firstWidget = LoginScreen();
  } else {
    firstWidget = HomePage();
  }
    return firstWidget;
  }
}

