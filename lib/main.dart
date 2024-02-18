import 'package:flutter/material.dart';
import 'package:chat_app_sendbird/pages/home-page.dart';
import "package:flutter_sizer/flutter_sizer.dart";
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return  FlutterSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.dark),
          title: 'Flutter SendBird',
          home: HomePage(key: key)
        );
    });
  }

  ThemeData _theme(brightness) {
    var defaultTheme = ThemeData(brightness: brightness);

    return defaultTheme.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(defaultTheme.textTheme),
    );
  }
}