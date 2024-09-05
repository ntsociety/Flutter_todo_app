import 'package:flutter/material.dart';
import 'package:todo/splash.dart';
import 'package:todo/todo.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
      routes: {
        'todo': (context) => TodoList(),
      },
    );
  }
}
