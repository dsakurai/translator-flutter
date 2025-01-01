import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();
  final file = File('store/file.txt');
  String items = await _loadItemsFromFile(file);

  // Define routes

  router.get('/', (Request request) {
    return Response.ok('This is the I/O server.');
  });

  router.get('/load', (Request request) {
    return Response.ok(items, headers: {'Content-Type': 'text/plain'});
  });

  router.post('/write', (Request request) async {
    items = await request.readAsString();

    await _saveItemsToFile(file, items);
    return Response.ok('File overwritten');
  });

  router.get('/shutdown', (Request request) async {
    await Future.delayed(Duration(seconds: 1)); // Allow response before shutdown
    print('Server shutting down...');
    exit(0);
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Server running on http://${server.address.host}:${server.port}');
}

Future<String> _loadItemsFromFile(File file) async {
  if (await file.exists()) {
    final contents = await file.readAsString();
    return contents;
  } else {
    // If the file doesn't exist, create it with an empty map
    final contents = "";
    file.createSync(recursive: true);
    await file.writeAsString(contents);
    return contents;
  }
}

Future<void> _saveItemsToFile(File file, String items) async {
  await file.writeAsString(items);
}
