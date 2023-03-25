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

    // Send login request using username and password
    const loginUsingUsernamePassword = '''
    {
        "msg": "method",
        "method": "login",
        "id":"42",
        "params":[
            {
                "user": { "username": "example-user" },
                "password": {
                    "digest": "some-digest",
                    "algorithm":"sha-256"
                }
            }
        ]
    }
  ''';

    channel.sink.add(loginUsingUsernamePassword);

    // Send login request using username and password
    const loginUsingOAuthProvider = '''
    {
    "msg": "method",
    "method": "login",
    "id":"42",
    "params": [
        {
            "oauth": {
                "credentialToken":"credential-token",
                "credentialSecret":"credential-secret"
            }
        }
    ]
}
  ''';

    channel.sink.add(loginUsingOAuthProvider);

    // Create Channel
    const createChannel = '''
    {
    "msg": "method",
    "method": "createChannel",
    "id": "85",
    "params": [
        "channel-name",
        ["array-of-usernames", "who-are-in-the-channel"],
        true/false
    ]
}
  ''';

    /* Example Response for above
{
    "msg": "result",
    "id": "85",
    "result": [
        { "rid": "BBkfgYT2azf7RPTTg" }
    ]
}
  */

    channel.sink.add(createChannel);

    // To send message in a room
    const sendMessage = '''
    {
    "msg": "method",
    "method": "sendMessage",
    "id": "42",
    "params": [
        {
            "_id": "message-id",
            "rid": "room-id",
            "msg": "Hello World!"
        }
    ]
}
  ''';
  } catch (e) {
    log(e.toString());
  }
}
