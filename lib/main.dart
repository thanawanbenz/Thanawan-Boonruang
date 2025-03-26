import 'package:project1/HomePage.dart';
import 'package:project1/login.dart';
import 'package:project1/signup.dart';
import 'package:flutter/material.dart';
import 'package:project1/page.dart' as MyPage;

import 'ImageExercises.dart';

void main() => runApp(const MyApp());
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true, // ปรับเป็น true เพื่อแก้ปัญหาคอนเทนต์ซ้อน
        body: PageView(
          children: <Widget>[
            MyPage.Page(),
            Login(),
            SignUp()//
          ],
        ),
      ),
    );
  }
}