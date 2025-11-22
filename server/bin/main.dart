import 'dart:io';
import '../lib/controllers/game_controller.dart';

void main() async {
  final controller = GameController();
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);

  print(
      'WS server listening on ${server.address.host}  ws://localhost:${server.port}');
  await for (HttpRequest req in server) {
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      WebSocketTransformer.upgrade(req).then(controller.handleSocket);
    } else {
      req.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.text
        ..write('WebSocket server alive.\n')
        ..close();
    }
  }
}
