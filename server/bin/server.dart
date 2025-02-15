import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

void main() async {
  final router = Router();
  final file = File('store/file.json');
  final certificate = File('certificates/myCA.pem');
  final key = File('certificates/myserver.key');
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

  // Proxy requests to another backend (e.g., Flutter backend on port 5000)
  var flutterBackend =
    // proxyHandler('http://localhost:5000');
    (Request request) {
    var newRequest = request.change(path: request.url.path.replaceFirst(RegExp('^flutter/'), ''));
    print(request.url.path.replaceFirst('flutter', ''));
    return proxyHandler('http://localhost:5000')(newRequest);
  };

  router.mount('/flutter', flutterBackend);


  final handler = const Pipeline()
      .addMiddleware(_addCorsHeadersMiddleware())
      .addMiddleware(logRequests())
      .addHandler(router.call);



  final server = await shelf_io.serve(handler, 'localhost', 8080,
    securityContext: // HTTPS
      SecurityContext()
        ..useCertificateChain(certificate.path)
        ..usePrivateKey(key.path,
                          //password: '2QZ^%8D7a25LQP'
                           )
  );
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

Middleware _addCorsHeadersMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Handle OPTIONS preflight requests
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders());
      }

      // Add CORS headers to all responses
      final response = await handler(request);
      return response.change(headers: _corsHeaders());
    };
  };
}

// Define CORS headers
Map<String, String> _corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
  };
}