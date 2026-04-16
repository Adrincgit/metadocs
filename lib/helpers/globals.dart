// lib/helpers/globals.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Keys globales -----------------------------------------------------------
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

late final SharedPreferences prefs;

Future<void> initGlobals() async {
  prefs = await SharedPreferences.getInstance();
}
