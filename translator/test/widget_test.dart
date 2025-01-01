import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Simple File Handling')),
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
  final String _fileName = 'rectangles.json';
  List<int> _rectangles = [];

  Future<File> _getFile() async {
    return File(_fileName); // Relative path to the file.
  }

  Future<void> _loadRectangles() async {
    final file = await _getFile();
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);
      setState(() {
        _rectangles = List<int>.from(data);
      });
    }
  }

  Future<void> _saveRectangles() async {
    final file = await _getFile();
    final jsonString = jsonEncode(_rectangles);
    await file.writeAsString(jsonString);
    print('Saved: $jsonString');
  }

  void _addRectangle() {
    setState(() {
      _rectangles.add(_rectangles.length);
    });
  }

  @override
  void initState() {
    super.initState();
    // _loadRectangles();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _addRectangle,
              child: Text('Add Rectangle'),
            ),
            ElevatedButton(
              onPressed: _saveRectangles,
              child: Text('Save Rectangles'),
            ),
          ],
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
