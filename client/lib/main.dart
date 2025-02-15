import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Server Connection Example')),
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
  String _serverResponse = 'No response yet';

  Future<void> _sendRequest() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/'));
      setState(() {
        _serverResponse = response.body;
      });
    } catch (e) {
      setState(() {
        _serverResponse = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _sendRequest,
          child: const Text('Send Request to Server'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_serverResponse),
        ),
      ],
    );
  }
}
