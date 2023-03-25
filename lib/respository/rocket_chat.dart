import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/io.dart';

Future connect() async {
  try {
    final channel =
        IOWebSocketChannel.connect('wss://localhost:3000/websocket');

    // Send connect message
    channel.sink.add('{"msg": "connect", "version": "1", "support": ["1"]}');

    // Listen for incoming messages
    channel.stream.listen((message) {
      final parsedMessage = jsonDecode(message);
      final messageType = parsedMessage['msg'];

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

    // Make method call
    channel.sink.add(
        '{"msg": "method", "id": "unique-id", "method": "methodName", "params": ["param1", "param2"]}');

    // Subscribe to data changes
    channel.sink.add(
        '{"msg": "sub", "id": "unique-id", "name": "subscriptionName", "params": ["param1", "param2"]}');
  } catch (e) {
    log(e.toString());
  }
}
