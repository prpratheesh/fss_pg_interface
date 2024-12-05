import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert' show json, base64, ascii;
import 'package:flutter/services.dart';
import 'package:fss_pg_interface/transaction_page.dart';
import 'package:fss_pg_interface/welcome_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return MaterialApp(
      title: "PG INTEGRATION APP",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Apply GoogleFonts.aleo() as the default font for the app
        textTheme: TextTheme(
          titleLarge: GoogleFonts.aleo(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
          headlineSmall: GoogleFonts.aleo(
              fontSize: 22.0, fontWeight: FontWeight.w500, color: Colors.blue),
          bodyLarge: GoogleFonts.aleo(
              fontSize: 16.0, color: Colors.black), // Main text body
          bodyMedium: GoogleFonts.aleo(
              fontSize: 14.0, color: Colors.grey[800]), // Secondary text body
          labelLarge: GoogleFonts.aleo(
              fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue, // Main theme color
          secondary: Colors.green, // Accent color
        ),
      ),
      // home: WelcomePage(),
      home: TransactionPage(),
    );
  }
}
