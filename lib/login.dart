import 'dart:convert';
import 'package:project1/signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'HomePage.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'กรุณากรอกอีเมลและรหัสผ่าน';
      } else {
        _errorMessage = '';
      }
    });

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        final String baseUrl = "https://webmastergame.shop/ThaiLanguage/login.php";
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData['success'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomePage(userName: responseData['user']['username'] ?? ''),
              ),
            );
          } else {
            setState(() {
              _errorMessage = responseData['error'] ?? 'เกิดข้อผิดพลาด';
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาดอีเมลหรือรหัสผ่านไม่ถูกต้อง')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ui.png',
                  width: 400,
                  height: 500,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    fillColor: Colors.white70,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  ),
                  style: TextStyle(fontSize: 30), // เพิ่มขนาดข้อความที่นี่
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    fillColor: Colors.white70,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? MdiIcons.eye : MdiIcons.eyeOff,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(fontSize: 30), // เพิ่มขนาดข้อความที่นี่
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), // เปลี่ยนสีข้อความเป็นสีขาว
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(MediaQuery.of(context).size.width / 3, 60), // ปรับขนาดปุ่มให้เหลือครึ่งหนึ่งของความกว้างหน้าจอ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUp(),
                          ),
                        );
                      },
                      child: Text(
                        'สมัครสมาชิก',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                          decorationColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
