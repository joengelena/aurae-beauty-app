import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/main_scaffold.dart';
import 'package:motorix_app/utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: MainScaffold(),
    );
  }
}
