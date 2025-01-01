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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> _rectangles = []; // List to hold the indices of rectangles.

  @override
  void initState() {
    super.initState();
    _load(); // Call _load() when the widget is created.
  }


  void _addRectangle() {
    setState(() {
      // Add an index to represent a new rectangle.
      _rectangles.add(_rectangles.length);
      _sendRequest();
    });
  }
  Future<void> _load() async {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:8080/load'),
          );
          if (response.statusCode == 200) {
            final List<int> loadedRectangles = List<int>.from(jsonDecode(response.body));

            // Update state safely after data is loaded
            setState(() {
              _rectangles = loadedRectangles;
            });
          } else {
            print('Failed to load rectangles. Status code: ${response.statusCode}');
          }
        // final response = await http.get(Uri.parse('http://localhost:8080/'));
      } catch (e) {
      }
  }
  Future<void> _sendRequest() async {
    try {
      String jsonString = jsonEncode(_rectangles);
      final response = await http.post(
        Uri.parse('http://localhost:8080/write'),
        headers: {'Content-Type': 'text/plain'},
        body: jsonString,
        );
      // final response = await http.get(Uri.parse('http://localhost:8080/'));
    } catch (e) {
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
        Expanded(
          child: ListView.builder(
            itemCount: _rectangles.length,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.red,
                margin: EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    'Rectangle ${_rectangles[index]}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
