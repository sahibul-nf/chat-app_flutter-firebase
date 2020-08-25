import 'package:chat_app/chat_page.dart';
import 'package:chat_app/signin_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignIn(),
      builder: (BuildContext context, Widget page) {
        return FutureBuilder<FirebaseApp>(
            future: Firebase.initializeApp(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return page;
              } else {
                return Container();
              }
            });
      },
    );
  }
}
