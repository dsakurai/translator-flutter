import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Simple File Handling')),
        body: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
              child: const Text('Add Rectangle'),
            ),
            ElevatedButton(
              onPressed: _saveRectangles,
              child: const Text('Save Rectangles'),
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
                margin: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    'Rectangle ${_rectangles[index]}',
                    style: const TextStyle(color: Colors.white),
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
