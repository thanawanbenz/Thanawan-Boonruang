import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project1/HomePage.dart';

class ScorePage extends StatefulWidget {
  final String userName;

  ScorePage({required this.userName});

  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  int _selectedIndex = 0;
  Map<String, dynamic> scoreData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchScoreData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      _showLogoutDialog();
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userName: widget.userName),
        ),
      );
    }
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
                Navigator.pushReplacementNamed(context, '/login');
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

  void _fetchScoreData() async {
    final response = await http.get(Uri.parse(
        'https://webmastergame.shop/ThaiLanguage/getscore.php?username=${widget.userName}'));

    if (response.statusCode == 200) {
      String body = response.body;
      print("Raw API Response:\n$body");

      try {
        Map<String, dynamic> decodedData = jsonDecode(body);
        print("Converted JSON Data:\n$decodedData");

        setState(() {
          scoreData['score_audio'] = List.from(decodedData['data']['score_audio'] ?? []).reversed.toList();
          scoreData['score_exercise'] = List.from(decodedData['data']['score_exercise'] ?? []).reversed.toList();
          scoreData['score_image'] = List.from(decodedData['data']['score_image'] ?? []).reversed.toList();
          isLoading = false;
        });
      } catch (e) {
        print("Error parsing data: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("Failed to load data, status code: ${response.statusCode}");
      throw Exception('Failed to load score data');
    }
  }

  Widget _buildCategoryList(String title, List<dynamic>? categoryData) {
    categoryData ??= [];
    print("Rendering $title: ${categoryData.length} entries");

    return Card(
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25, // ปรับขนาดข้อความที่นี่
          ),
        ),
        trailing: Icon(MdiIcons.chevronDown), // ไอคอนที่ด้านขวาของหมวดหมู่
        children: categoryData.isEmpty
            ? [Padding(padding: EdgeInsets.all(10), child: Text('ไม่มีข้อมูล'))]
            : categoryData.map<Widget>((scoreEntry) {
          return ListTile(
            leading: Icon(MdiIcons.star), // ไอคอนที่ด้านซ้ายของรายการ
            title: Text(
              'คะแนน: ${scoreEntry['score']}',
              style: TextStyle(fontSize: 20), // ปรับขนาดตัวอักษรที่นี่
            ),
            subtitle: scoreEntry.containsKey('total')
                ? Text(
              'คะแนนรวม: ${scoreEntry['total']}',
              style: TextStyle(fontSize: 20), // ปรับขนาดตัวอักษรที่นี่
            )
                : null,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('ผลคะแนน', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  String title;
                  List<dynamic>? categoryData;

                  if (index == 0) {
                    title = "คะแนนแบบฝึกหัดตอบคำถามจากภาพ";
                    categoryData = scoreData['score_exercise'];
                  } else if (index == 1) {
                    title = "คะแนนแบบฝึกหัดตอบคำถามจากการฟัง";
                    categoryData = scoreData['score_audio'];
                  } else {
                    title = "คะแนนแบบฝึกหัดจับคู่ความสัมพันธ์";
                    categoryData = scoreData['score_image'];
                  }

                  print("Category Data: $categoryData");

                  return _buildCategoryList(title, categoryData);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
