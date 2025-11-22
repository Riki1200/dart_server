import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  WebSocketChannel? _channel;
  final _streamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _streamController.stream;

  void connect(String url) {
    if (_channel != null) return;
    final wsUrl = Uri.parse(url);
    _channel = WebSocketChannel.connect(wsUrl);
    _channel!.stream.listen(
      (data) {
        final msg = jsonDecode(data) as Map<String, dynamic>;
        _streamController.add(msg);
      },
      onDone: () {
        _disconnect();
      },
      onError: (error) {
        _streamController.addError(error);
      },
    );
  }

  void send(String type, Map<String, dynamic> payload) {
    if (_channel == null) return;
    final msg = jsonEncode({'type': type, 'payload': payload});
    _channel!.sink.add(msg);
  }

  void close() {
    _channel?.sink.close();
    _disconnect();
  }

  void _disconnect() {
    _channel = null;
  }
}
