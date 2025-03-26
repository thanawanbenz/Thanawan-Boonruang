import 'package:flutter/material.dart';
import 'package:project1/HomePage.dart';
import 'package:project1/login.dart';
import 'package:project1/signup.dart';

class Page extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  void initState() {
    super.initState();

// ตั้งเวลา 100 วินาทีเพื่อเปลี่ยนหน้า

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login() // เรียกหน้าถัดไป
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Ui1.jpg'), // Path ของภาพพื้นหลัง
            fit: BoxFit.cover, // ทำให้ภาพขยายเต็มหน้าจอ
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(25.4, 50, 19, 16),
                child: Stack(
                  children: [
// เนื้อหาเพิ่มเติมใน Stack (ถ้าจำเป็น)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
