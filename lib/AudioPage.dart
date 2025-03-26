import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AudioPage extends StatefulWidget {
  final String username;

  // รับข้อมูล username ที่ส่งมาจากหน้าหลัก
  AudioPage({required this.username});

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentQuestionIndex = 0;
  String? _selectedChoice;
  String? _correctAnswer;
  bool _isLoading = true;
  bool _isSubmitted = false;
  List<Map<String, dynamic>> _questions = [];
  int _score = 0; // To store the user's score
  List<Map<String, dynamic>> _matchedAnswers = [];
  late String _username; // ประกาศตัวแปร username

  @override
  void initState() {
    super.initState();
    _username = widget.username; // ดึง username จาก constructor
    _fetchQuestions(); // เรียกใช้งานฟังก์ชันโหลดคำถาม
  }

  Future<void> _fetchQuestions() async {
    const String apiUrl = 'https://webmastergame.shop/ThaiLanguage/audio.php';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        List<Map<String, dynamic>> allQuestions = data.map((q) {
          return {
            "audio": q["audio"],
            "question": q["question"],
            "choices": (q["options"] as List<dynamic>?)
                ?.map((option) => {
              "id": option["id"].toString(),
              "text": option["text"]
            })
                .toList() ?? [],
            "answer": q["correct_answer"].toString(),
          };
        }).toList();

        allQuestions.shuffle();
        setState(() {
          _questions = allQuestions.take(10).toList();
          _isLoading = false;
        });

        // Play the first question's audio when the questions are loaded
        if (_questions.isNotEmpty) {
          _playAudio(_questions[0]["audio"]);
        }
      } else {
        throw Exception("ไม่สามารถโหลดคำถามได้");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการโหลดคำถาม: $e")),
      );
    }
  }

  void _onChoiceSelected(String choiceText) {
    setState(() {
      _selectedChoice = choiceText;
      final selectedOption = _questions[_currentQuestionIndex]["choices"]
          .firstWhere((option) => option["text"] == choiceText,
          orElse: () => {"id": null});
      if (selectedOption["id"] != null) {
        _correctAnswer = _questions[_currentQuestionIndex]["answer"];
        _isSubmitted = true;

        // ใช้ ID ในการเปรียบเทียบคำตอบที่ถูกต้อง
        final correctAnswerId = _questions[_currentQuestionIndex]["answer"];
        if (selectedOption["id"] == correctAnswerId) {
          _score++;
          _matchedAnswers.add({
            "question": _questions[_currentQuestionIndex]["question"],
            "answer": choiceText,
            "correct": true
          });
        } else {
          _matchedAnswers.add({
            "question": _questions[_currentQuestionIndex]["question"],
            "answer": choiceText,
            "correct": false
          });
        }
      }
    });

    Future.delayed(Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedChoice = null;
        _correctAnswer = null;
        _isSubmitted = false;
      });
      _playAudio(_questions[_currentQuestionIndex]["audio"]); // Play audio for the next question
    } else {
      _saveResults(); // Save results after the last question
    }
  }

  void _playAudio(String url) async {
    print("กำลังเล่นเสียงจาก: $url"); // Check the URL being sent
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(url)); // Play the audio from the URL
  }

  void _saveResults() async {
    Map<String, dynamic> resultData = {
      "username": _username, // ใช้ username ที่ดึงมาจาก constructor
      "score": _score,
      "total": _questions.length,
    };

    // แสดงผลใน console เป็น JSON
    print(jsonEncode(resultData));

    try {
      final response = await http.post(
        Uri.parse('https://webmastergame.shop/ThaiLanguage/score_audio.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(resultData),
      );

      if (response.statusCode == 200) {
        // แสดงผลลัพธ์ในรูปแบบของ dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("บันทึกผลลัพธ์"),
            content: Text("คุณทำได้ $_score / ${_questions.length} คะแนน"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("บันทึก"),
              ),
            ],
          ),
        );
      } else {
        throw Exception('ไม่สามารถบันทึกคะแนนได้');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึกคะแนน: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("ตอบคำถามจากการฟัง"),
          leading: IconButton(
            icon: Icon(MdiIcons.arrowLeft, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("ตอบคำถามจากการฟัง"),
          leading: IconButton(
            icon: Icon(MdiIcons.arrowLeft, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(child: Text("ไม่มีคำถาม")),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("ตอบคำถามจากการฟัง"),
        leading: IconButton(
          icon: Icon(MdiIcons.arrowLeft, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/home.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0, left: 30.0, right: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(MdiIcons.playOutline, color: Colors.black, size: 250),
                    onPressed: () => _playAudio(currentQuestion["audio"]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "กดเพื่อเล่นเสียงซ้ำ",
                    style: TextStyle(fontSize: 25, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 60),
              Text(
                currentQuestion["question"],
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // First column (2 choices)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: currentQuestion["choices"]
                          .sublist(0, 2)
                          .map<Widget>((choice) {
                        final choiceText = choice["text"];
                        final choiceId = choice["id"];
                        bool isSelected = _selectedChoice == choiceText;
                        bool isCorrect = choiceId == _correctAnswer;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isCorrect ? Colors.green[200] : Colors.red[200])
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black54, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(0, 5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 28),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size(double.infinity, 10),
                              elevation: 10,
                            ),
                            onPressed: _isSubmitted
                                ? null
                                : () {
                              _onChoiceSelected(choiceText);
                            },
                            child: Text(
                              choiceText,
                              style: TextStyle(fontSize: 40, color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 60),
                  // Second column (2 choices)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: currentQuestion["choices"]
                          .sublist(2, 4)
                          .map<Widget>((choice) {
                        final choiceText = choice["text"];
                        final choiceId = choice["id"];
                        bool isSelected = _selectedChoice == choiceText;
                        bool isCorrect = choiceId == _correctAnswer;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isCorrect ? Colors.green[200] : Colors.red[200])
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black54, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(0, 5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 28),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size(double.infinity, 10),
                              elevation: 10,
                            ),
                            onPressed: _isSubmitted
                                ? null
                                : () {
                              _onChoiceSelected(choiceText);
                            },
                            child: Text(
                              choiceText,
                              style: TextStyle(fontSize: 40, color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
