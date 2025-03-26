import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ImageText extends StatefulWidget {
  final String username;

  ImageText({required this.username});

  @override
  _ImageTextState createState() => _ImageTextState();
}

class _ImageTextState extends State<ImageText> {
  List<Map<String, String>> _allItems = [];
  List<Map<String, String>> _items = [];
  List<Map<String, String>> _shuffledItems = [];
  Map<String, String?> _matchedAnswers = {};
  Set<String> _usedChoices = {};
  bool _isLoading = true;
  int _currentPage = 0;
  int _score = 0;
  late String _username;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _fetchData();
  }

  Future<void> _fetchData() async {
    final url = Uri.parse('https://webmastergame.shop/ThaiLanguage/imagetext.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        List<Map<String, String>> fetchedItems = [];

        for (var item in data) {
          if (item is Map<String, dynamic> && item.containsKey("image") && item.containsKey("text")) {
            fetchedItems.add({
              "image": item["image"].toString(),
              "text": item["text"].toString()
            });
          }
        }

        fetchedItems.shuffle();
        setState(() {
          _allItems = fetchedItems.take(12).toList();
          _isLoading = false;
          _loadNextPage();
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
    }
  }

  void _loadNextPage() {
    if (_currentPage >= 3) {
      _showScoreDialog();
      return;
    }

    setState(() {
      _items = _allItems.skip(_currentPage * 4).take(4).toList();
      _shuffledItems = List.from(_items)..shuffle();
      _matchedAnswers = {for (var item in _items) item["image"]!: null};
      _usedChoices.clear();
      _currentPage++;
    });
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
                "total": 12,
              };

              final url = Uri.parse('https://webmastergame.shop/ThaiLanguage/score_image.php');
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
          title: Text("ลากวางคำตอบ"),
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

    return Scaffold(
      appBar: AppBar(
        title: Text("จับคู่คำให้ถูกต้อง (ลากคำที่ถูกต้องมาวาง)"),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 55,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      children: [
                        Image.network(
                          item["image"]!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 25),
                        DragTarget<String>(
                          onWillAccept: (data) => !_usedChoices.contains(data),
                          onAccept: (receivedText) {
                            setState(() {
                              _matchedAnswers[item["image"]!] = receivedText;
                              _usedChoices.add(receivedText);
                            });
                            if (_matchedAnswers.values.where((value) => value != null).length == 4) {
                              _checkAnswers();
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            bool isCorrect = _matchedAnswers[item["image"]!] == item["text"];
                            bool isAnswered = _matchedAnswers[item["image"]!] != null;

                            return Container(
                              width: 150,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isAnswered
                                    ? (isCorrect ? Colors.green[200] : Colors.red[200])
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black54, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _matchedAnswers[item["image"]!] ?? "วางคำตอบที่นี่",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 30),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _shuffledItems
                      .where((item) => !_usedChoices.contains(item["text"]))
                      .map((item) {
                    return Draggable<String>(
                      data: item["text"]!,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: Text(
                            item["text"]!,
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Text(
                          item["text"]!,
                          style: TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswers() {
    _matchedAnswers.forEach((image, text) {
      final correctText = _items.firstWhere((item) => item["image"] == image)["text"];
      if (text == correctText) {
        _score++;
      }
    });
    Future.delayed(Duration(seconds: 1), () {
      _loadNextPage();
    });
  }
}
