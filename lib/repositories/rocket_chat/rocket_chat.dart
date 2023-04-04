import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future connect() async {
  try {
    final channel =
        WebSocketChannel.connect(Uri.parse('wss://open.rocket.chat/websocket'));

    // Send connect message
    channel.sink.add('{"msg": "connect", "version": "1", "support": ["1"]}');

    print('WebSocket connection successful.');

    // Listen for incoming messages
    channel.stream.listen((message) {
      final parsedMessage = jsonDecode(message);
      final messageType = parsedMessage['msg'];
      log(messageType ?? 'null');

      if (messageType == 'ping') {
        // Respond with 'pong' to keep the connection alive
        channel.sink.add('{"msg": "pong"}');
      } else if (messageType == 'result') {
        // Handle method call result
      } else if (messageType == 'changed') {
        // Handle subscription data change
      } else {
        // Handle unknown message type
      }
    });
  } catch (e) {
    log(e.toString());
  }
}
