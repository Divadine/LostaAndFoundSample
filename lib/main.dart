import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:map_initialization/firebase_options.dart';
import 'package:map_initialization/screens/home_screen.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppPreference.init();
  runApp( MapLocalization());
}

StreamController<bool> themeCtrl = StreamController.broadcast();
StreamController<String> fontCtrl = StreamController.broadcast();
//StreamController<Color> colorCtrl = StreamController.broadcast();

class MapLocalization extends StatelessWidget {
  const MapLocalization( {super.key});

  @override
  Widget build(BuildContext context){
    return StreamBuilder<bool>(
      stream: themeCtrl.stream,
      initialData: AppPreference.getTheme(),
      builder: (context, asyncSnapshot) {
        final isDark = asyncSnapshot.data ?? false;

        return StreamBuilder(
          stream: fontCtrl.stream,
          initialData: AppPreference.getFont(),
          builder: (context, asyncSnapshot) {
            fontFamily: asyncSnapshot.data;
            return MaterialApp(
              theme: ThemeData(brightness : isDark ? Brightness.dark : Brightness.light,fontFamily: asyncSnapshot.data ?? 'Inter',),
              debugShowCheckedModeBanner: false,
              home: const MapApp(),
            );
          }
        );
      }
    );
  }
}