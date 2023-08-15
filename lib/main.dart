import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:olx/RouteGenerator.dart';
import 'package:olx/views/Anuncios.dart';
import 'package:olx/views/Login.dart';

final ThemeData temaPadrao = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.purple,
    accentColor: Colors.deepPurple,
  ),
);

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: "OLX",
    theme: temaPadrao,
    home: Anuncios(),
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}
