import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Add Red Rectangle')),
        body: MyHomePage(),
      ),
    );
  }
}

class TranslationPortion {
  String original;
  String translation;

  static const String original_key = "original";
  static const String translation_key = "translation";

  // for controlling TextEdit
  TextEditingController original_controller;
  TextEditingController translation_controller;

  TranslationPortion({this.original = "", this.translation = ""}):
    original_controller =
     TextEditingController(text: original)
    ,
    translation_controller = TextEditingController(text: translation) {
      original_controller.addListener(() {
            // Update _translations whenever text is edited
            this.original = this.original_controller.text;
          });
      translation_controller.addListener(() {
            // Update _translations whenever text is edited
            this.translation = this.translation_controller.text;
          });
    }

  // Factory method to create an instance from a JSON map
  factory TranslationPortion.fromJson(Map<String, dynamic> json) {
    return TranslationPortion(
      original:    json[original_key],
      translation: json[translation_key],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      original_key:    original,
      translation_key: translation,
    };
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TranslationPortion> _translations = []; // List to hold the indices of rectangles.

  @override
  void initState() {
    super.initState();
    _load(); // Call _load() when the widget is created.
  }


  void _addRectangle() {
    setState(() {
      // Add an index to represent a new rectangle.
      _translations.add(TranslationPortion());
    });
  }
  Future<void> _load() async {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:8080/load'),
          );
          if (response.statusCode == 200) {
            final List<dynamic> loadedRectangles = jsonDecode(response.body);

            // Update state safely after data is loaded
            setState(() {
              _translations = loadedRectangles.map((json) => TranslationPortion.fromJson(json as Map<String, dynamic>))
                              .toList();
            });
          } else {
            print('Failed to load rectangles. Status code: ${response.statusCode}');
          }
        // final response = await http.get(Uri.parse('http://localhost:8080/'));
      } catch (e) {
        print(e);
      }
  }
  Future<void> _sendRequest() async {
    try {
      String jsonString = jsonEncode(_translations);
      print(jsonString);
      final response = await http.post(
        Uri.parse('http://localhost:8080/write'),
        headers: {'Content-Type': 'text/plain'},
        body: jsonString,
        );
      // final response = await http.get(Uri.parse('http://localhost:8080/'));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _addRectangle, // Add rectangle on button press.
          child: Text('Add Rectangle'),
        ),
        ElevatedButton(
          onPressed: _sendRequest, // Add rectangle on button press.
          child: Text('Add translation pair'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _translations.length,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  // First TextField
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'First Field ${index}',
                      ),
                      controller: _translations[index].original_controller,
                      maxLines: null,
                    ),
                  ),
                  SizedBox(width: 10), // Space between fields
                  // Second TextField
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'First Field ${index}',
                      ),
                      controller: _translations[index].translation_controller,
                      maxLines: null,
                    ),
                  ),
                ],
              );
            }
          )
          // child: ListView.builder(
          //   itemCount: _rectangles.length,
          //   itemBuilder: (context, index) {
          //     return Container(
          //       width: 100,
          //       height: 100,
          //       color: Colors.red,
          //       margin: EdgeInsets.only(top: 10),
          //       child: Center(
          //         child: Text(
          //           'Rectangle ${_rectangles[index]}',
          //           style: TextStyle(color: Colors.white),
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ),
      ],
    );
  }
}
