import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  // Replace this with your backend API URL
  final String _apiUrl = 'https://webmastergame.shop/ThaiLanguage/signup.php';

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกชื่อผู้ใช้';
    }
    if (value.length > 255) {
      return 'ชื่อผู้ใช้ห้ามเกิน 255 ตัวอักษร';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return 'กรุณากรอกอีเมลที่ถูกต้อง';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    // ตรวจสอบว่าเป็นตัวเลข 8 หลัก
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return 'รหัสผ่านต้องเป็นตัวเลข 8 หลัก';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          body: {
            'username': _userNameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          },
        );

        if (response.statusCode == 200) {
          final signUpData = json.decode(response.body);

          if (signUpData['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('สมัครสมาชิกสำเร็จ!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(signUpData['error'] ?? 'เกิดข้อผิดพลาด')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ข้อผิดพลาด: ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // ใช้ MediaQuery เพื่อรับขนาดหน้าจอ
    return Scaffold(
      extendBodyBehindAppBar: true, // ขยายตัวเนื้อหาให้รวมถึงพื้นที่หลัง AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ตั้งค่าโปร่งใส
        elevation: 0, // ลบเงา
        leading: IconButton(
          icon: Icon(MdiIcons.arrowLeft, color: Colors.white), // ไอคอนย้อนกลับ
          onPressed: () {
            Navigator.pop(context); // ย้อนกลับไปหน้าก่อนหน้า
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/image.png'), // ใส่พาธของรูปภาพ
              fit: BoxFit.cover, // ปรับให้รูปภาพครอบคลุมเต็มหน้าจอ
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: kToolbarHeight + 16), // เว้นระยะด้านบนหลัง AppBar
                  _buildTextField('ชื่อเด็ก', _userNameController, _validateUsername),
                  SizedBox(height: 16),
                  _buildTextField('อีเมล', _emailController, _validateEmail),
                  SizedBox(height: 16),
                  _buildPasswordField(),
                  SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _signUp,
                      child: Text('สมัครสมาชิก'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 18), // เพิ่มความสูงของปุ่ม
                        fixedSize: Size(MediaQuery.of(context).size.width * 0.3, 60), // ความกว้างของปุ่ม 80% ของหน้าจอ
                        textStyle: TextStyle(
                          fontSize: 20, // เพิ่มขนาดตัวอักษร
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Chulamooc',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // เพิ่มมุมโค้งของปุ่ม
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?) validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18, color: Colors.black87)),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            hintText: 'กรุณากรอก$label',
            hintStyle: TextStyle(color: Colors.black45),
            contentPadding: EdgeInsets.symmetric(vertical: 25, horizontal: 16), // ปรับความสูงและระยะภายใน
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('รหัสผ่านระบุเป็นวันเดือนปีเกิดของเด็ก(ตัวอย่าง03032546)', style: TextStyle(fontSize: 18, color: Colors.black87)),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscureText,
          validator: _validatePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            hintText: 'กรุณากรอกรหัสผ่าน',
            hintStyle: TextStyle(color: Colors.black45),
            contentPadding: EdgeInsets.symmetric(vertical: 25, horizontal: 16), // ปรับความสูงและระยะภายใน
            suffixIcon: IconButton(
              icon: Icon(_obscureText ? MdiIcons.eyeOff : MdiIcons.eye),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
