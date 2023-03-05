import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflitepractice/homePage.dart';
import 'package:sqflitepractice/provider/sqlProvider.dart';
import 'package:sqflitepractice/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final themeService = await ThemeService.instance;
  var initTheme = themeService.initial;
  runApp(MyApp(theme: initTheme));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.theme});

  final ThemeData theme;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SqlProvider(),
      child: ThemeProvider(
          initTheme: theme,
          builder: (context, theme) {
            return MaterialApp(
              title: 'SQFlite',
              debugShowCheckedModeBanner: false, theme: theme,
              // theme: ThemeData(
              //   primarySwatch: Colors.blue,
              // ),
              home: MyHomePage.create(context),
            );
          }),
    );
  }
}
