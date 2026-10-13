import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'theme.dart';

void main() => runApp(const SplyceApp());

class SplyceApp extends StatefulWidget {
  const SplyceApp({super.key});
  @override
  State<SplyceApp> createState() => _SplyceAppState();
}

class _SplyceAppState extends State<SplyceApp> {
  String? user;
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Splyce',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: user == null
            ? LoginPage(onLogin: (n) => setState(() => user = n))
            : HomePage(userName: user!, onSignOut: () => setState(() => user = null)),
      );
}
