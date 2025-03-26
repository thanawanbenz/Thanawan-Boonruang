import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project1/ImageText.dart';
import 'AudioPage.dart';
import 'ImageExercises.dart';
import 'ScorePage.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final String userName;

  HomePage({required this.userName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      _showLogoutDialog();
    } else if (index == 0) {
      _goToScorePage();
    }
  }

  void _goToScorePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScorePage(userName: widget.userName), // ส่งชื่อผู้ใช้ไปที่ ScorePage
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการออกจากระบบ'),
          content: Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()), // ไปที่หน้า Login
                      (route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ออกจากระบบสำเร็จ')),
                );
              },
              child: Text('ยืนยัน'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สวัสดี', // แสดงข้อความต้อนรับ
              style: TextStyle(color: Colors.black),
            ),
            Text(
              widget.userName, // แสดงชื่อผู้ใช้ที่ส่งมา
              style: TextStyle(color: Colors.black, fontSize: 22),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/ui.png',
                  width: 400,
                  height: 500,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImageExercises(username: widget.userName)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(450, 100),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  child: Text('ตอบคำถามจากภาพ'),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AudioPage(username: widget.userName,)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(450, 100),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  child: Text('ตอบคำถามจากการฟัง'),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImageText(username: widget.userName,)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(450, 100),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  child: Text('จับคู่ความสัมพันธ์'),
                ),
                Spacer(),
              ],
            ),
          ),

        ),
      ),
      bottomNavigationBar: Container(
        height: 90,
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.trophy),
              label: 'ผลคะแนน',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.home),
              label: 'หน้าหลัก',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.logout),
              label: 'ออกจากระบบ',
            ),
          ],
          iconSize: 45,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
