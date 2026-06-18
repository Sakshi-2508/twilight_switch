import 'package:flutter/material.dart';
import 'package:twilight_switch/twilight_switch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Twilight Switch'),
        ),
        body: Center(
          child: TwilightSwitch(
            value: isDark,
            onChanged: (value) {
              setState(() {
                isDark = value;
              });
            },
          ),
        ),
      ),
    );
  }
}