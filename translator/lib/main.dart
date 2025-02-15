import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Translation')),
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
            original = original_controller.text;
          });
      translation_controller.addListener(() {
            // Update _translations whenever text is edited
            translation = translation_controller.text;
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
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TranslationPortion> _translations = []; // List to hold the indices of rectangles.

  @override
  void initState() {
    super.initState();
    _loadSavedText(); // Call _load() when the widget is created.
  }


  void _addTranslationPair() {
    setState(() {
      // Add an index to represent a new rectangle.
      _translations.add(TranslationPortion());
    });
  }
  Future<void> _loadSavedText() async {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:8080/load'),
          );
          if (response.statusCode == 200) {
            final List<dynamic> loadedRectangles = jsonDecode(response.body);

            // Update state after data is loaded
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
  Future<void> _saveAtServer() async {
    try {
      String jsonString = const JsonEncoder.withIndent('  ').convert(_translations);
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
        const SizedBox(height: 8.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: _addTranslationPair, // Add rectangle on button press.
              child: const Text('Add Translation pair'),
            ),
            ElevatedButton(
              onPressed: _saveAtServer, // Add rectangle on button press.
              child: const Text('Save'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(top: 20.0, bottom: MediaQuery.of(context).size.height * 0.5),
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
            itemCount: _translations.length,
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First TextField
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Original paragraph $index',
                      ),
                      controller: _translations[index].original_controller,
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 10), // Space between fields
                  // Second TextField
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Translated paragraph $index',
                      ),
                      controller: _translations[index].translation_controller,
                      maxLines: null,
                    ),
                  ),
                ],
              );
            }
          )
        ),
      ],
    );
  }
}
