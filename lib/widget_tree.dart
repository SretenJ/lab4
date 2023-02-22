import 'package:flutter/material.dart';
import 'package:lab3/auth.dart';
import 'package:lab3/main.dart';

import 'pages/login_register_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<StatefulWidget> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MyHomePage(
            title: "LAB 4",
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
