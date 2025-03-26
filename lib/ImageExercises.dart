import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ImageExercises extends StatefulWidget {
  final String username;

  ImageExercises({required this.username});

  @override
  _ImageExercisesState createState() => _ImageExercisesState();
}

class _ImageExercisesState extends State<ImageExercises> {
  int _currentQuestionIndex = 0;
  String? _selectedChoice;
  String? _correctAnswer;
  bool _isLoading = true;
  bool _isSubmitted = false;
  List<Map<String, dynamic>> _questions = [];
  int _score = 0;
  late String _username;

  Future<void> _fetchQuestions() async {
    final url = Uri.parse('https://webmastergame.shop/ThaiLanguage/image.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        List<Map<String, dynamic>> allQuestions = data.map((q) {
          return {
            "image": q["image_url"] ?? "",
            "question": q["question"] ?? "",
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
      } else {
        throw Exception("Failed to load questions");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading questions: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _fetchQuestions();
  }

  void _onChoiceSelected(String choiceText) {
    setState(() {
      _selectedChoice = choiceText;

      final selectedOption = _questions[_currentQuestionIndex]["choices"]
          .firstWhere(
            (option) => option["text"] == choiceText,
        orElse: () => {"id": null},
      );

      if (selectedOption["id"] != null) {
        final selectedId = selectedOption["id"];
        _correctAnswer = _questions[_currentQuestionIndex]["answer"];
        _isSubmitted = true;

        if (_correctAnswer == selectedId) {
          _score++;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Selected option not found")),
        );
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
    } else {
      _showScoreDialog();
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("เสร็จสิ้น"),
        content: Text("คุณตอบคำถามทั้งหมดเสร็จสิ้นแล้ว!\nคะแนนของคุณ: $_score"),
        actions: [
          TextButton(
            onPressed: () async {
              final result = {
                "username": _username,
                "score": _score,
                "total": _questions.length,
              };

              final url = Uri.parse('https://webmastergame.shop/ThaiLanguage/score_exercise.php');
              try {
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(result),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("บันทึกคะแนนสำเร็จ")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("ไม่สามารถบันทึกคะแนนได้")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }

              Navigator.pop(context);
            },
            child: Text("บันทึกคะแนน"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("ตอบคำถามจากภาพ"),
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
          title: Text("ตอบคำถามจากภาพ"),
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
        title: Text("ตอบคำถามจากภาพ"),
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
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/home.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 80),
                Image.network(
                  currentQuestion["image"],
                  height: 300,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  currentQuestion["question"],
                  style: TextStyle(fontSize: 25, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ...currentQuestion["choices"].map<Widget>((choice) {
                  final choiceText = choice["text"];
                  final choiceId = choice["id"];
                  bool isAnswered = _isSubmitted && _selectedChoice == choiceText;
                  bool isCorrect = _correctAnswer == choiceId;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isAnswered
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
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 10),
                        elevation: 10,
                      ),
                      onPressed: _isSubmitted ? null : () {
                        _onChoiceSelected(choiceText);
                      },
                      child: Text(
                        choiceText,
                        style: TextStyle(fontSize: 30, color: Colors.black),
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
