import 'dart:async';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // aller sur la page todo après 3s
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "todo");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("images/todo.png"),
      ),
    );
  }
}
