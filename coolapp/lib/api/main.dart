import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  final handler = (Request request) {
    return Response.ok('Hello, REST API!');
  };

  await io.serve(handler, 'localhost', 8080);
}
