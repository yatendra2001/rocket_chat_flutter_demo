import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rocket_chat_flutter_demo/models/chat_room.dart';
import 'package:rocket_chat_flutter_demo/models/message.dart';
import 'package:rocket_chat_flutter_demo/utils/session_helper.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ChatScreenArgs {
  final ChatRoom chatRoom;
  ChatScreenArgs({
    required this.chatRoom,
  });
}

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  final ChatRoom chatRoom;

  const ChatScreen({Key? key, required this.chatRoom}) : super(key: key);

  static Route route({required ChatScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => ChatScreen(
        chatRoom: args.chatRoom,
      ),
    );
  }

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Message> _messages = [];

  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    getMessageHistoryUsingRest();
  }

  void sendMessage({required String inputMessage}) async {
    try {
      log("Sending message request");
      final uri = Uri.parse('wss://open.rocket.chat/websocket');
      _channel = WebSocketChannel.connect(uri);
      _channel.sink.add(jsonEncode({
        "msg": "connect",
        "version": "1",
        "support": ["1"]
      }));

      _channel.stream.listen((message) {
        log('Received: $message');
        final parsedMessage = jsonDecode(message);

        if (parsedMessage['msg'] == 'ping') {
          // Respond with 'pong' to keep the connection alive
          _channel.sink.add('{"msg": "pong"}');
        } else if (parsedMessage['msg'] == 'connected') {
          // Respond with 'pong' to keep the connection alive
          _channel.sink.add('{"msg": "pong"}');
          String roomID = widget.chatRoom.id;

          _channel.sink.add(jsonEncode({
            "msg": "method",
            "method": "sendMessage",
            "id": "2",
            "params": [
              {
                "_id": const Uuid().v4(),
                "rid": roomID,
                "msg": inputMessage,
              }
            ],
            "authToken": "${SessionHelper.authToken}",
            "userId": "${SessionHelper.userId}",
          }));
        }
      });

      // Add the sent message to the local messages list
      setState(() {
        _messages.add(
          Message(
            id: const Uuid().v4(),
            text: inputMessage,
            senderId: SessionHelper.userId!,
            sender: "You",
            time: DateTime.now(),
          ),
        );
      });
    } catch (error) {
      log(error.toString());
    }
  }

  void sendMessageUsingRest({required String inputMessage}) async {
    try {
      log("Sending message request");

      String roomID = widget.chatRoom.id;
      String endpoint;

      if (widget.chatRoom.type == 'd') {
        endpoint = 'https://open.rocket.chat/api/v1/chat.postMessage';
      } else {
        endpoint = 'https://open.rocket.chat/api/v1/chat.postMessage';
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-Auth-Token': SessionHelper.authToken!,
          'X-User-Id': SessionHelper.userId!,
        },
        body: jsonEncode({
          'roomId': roomID,
          'text': inputMessage,
        }),
      );

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        log('Message sent successfully: ${parsedResponse.toString()}');
      } else {
        log('Failed to send message. Please check your roomId, userId, and authToken.');
      }
    } catch (error) {
      log(error.toString());
    }
  }

  void getMessageHistory() async {
    try {
      log("Sending message history request");
      log("roomid: ${widget.chatRoom.id}, userId: ${SessionHelper.userId}, authToken: ${SessionHelper.authToken}");
      final uri = Uri.parse('wss://open.rocket.chat/websocket');
      _channel = WebSocketChannel.connect(uri);
      _channel.sink.add(jsonEncode({
        "msg": "connect",
        "version": "1",
        "support": ["1"]
      }));

      _channel.stream.listen((message) async {
        log('Received: $message');
        final parsedMessage = jsonDecode(message);

        if (parsedMessage['msg'] == 'connected') {
          _channel.sink.add(jsonEncode({
            "msg": "method",
            "method": "login",
            "id": "0",
            "params": [
              {"resume": "${SessionHelper.authToken}"}
            ]
          }));
        }

        if (parsedMessage['msg'] == 'result' && parsedMessage['id'] == '0') {
          _channel.sink.add(jsonEncode({
            "msg": "sub",
            "id": "2",
            "name": "stream-room-messages",
            "params": [(widget.chatRoom.id), false]
          }));

          String roomID = widget.chatRoom.id;

          _channel.sink.add(jsonEncode({
            "msg": "method",
            "method": "loadHistory",
            "id": "1",
            "params": [
              roomID,
              null,
              50,
              {"\$date": DateTime.now().millisecondsSinceEpoch},
              {
                "userId": "${SessionHelper.userId}",
                "authToken": "${SessionHelper.authToken}"
              }
            ]
          }));
        }

        if (parsedMessage['msg'] == 'ping') {
          _channel.sink.add('{"msg": "pong"}');
        }
        if (parsedMessage.containsKey('result') &&
            parsedMessage['result'].containsKey('messages')) {
          List<dynamic> messages = parsedMessage['result']['messages'];
          log(messages.toString());
        } else {
          log("Failed to load room history. Please check your roomId, userId, and authToken.");
        }
      });
    } catch (error) {
      log(error.toString());
    }
  }

  void getMessageHistoryUsingRest() async {
    try {
      log("Sending message history request");
      log("roomid: ${widget.chatRoom.id}, userId: ${SessionHelper.userId}, authToken: ${SessionHelper.authToken}");

      String roomID = widget.chatRoom.id;
      String endpoint;

      if (widget.chatRoom.type == 'd') {
        endpoint = 'https://open.rocket.chat/api/v1/im.history';
      } else {
        endpoint = 'https://open.rocket.chat/api/v1/channels.history';
      }

      final response = await http.get(
        Uri.parse('$endpoint?roomId=$roomID&count=50'),
        headers: {
          'Content-Type': 'application/json',
          'X-Auth-Token': SessionHelper.authToken!,
          'X-User-Id': SessionHelper.userId!,
        },
      );
      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        List<dynamic> messagesJson = parsedResponse['messages'];
        setState(() {
          _messages =
              messagesJson.map((json) => Message.fromJson(json)).toList();
        });
      } else {
        log("Failed to load room history. Please check your roomId, userId, and authToken.");
      }
    } catch (error) {
      log(error.toString());
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.name),
      ),
      body: _messages.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isCurrentUser =
                          message.senderId == SessionHelper.userId;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: isCurrentUser
                                  ? Colors.blue[200]
                                  : Colors.grey[300],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.sender,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message.text,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM d, h:mm a')
                                      .format(message.time),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          final inputMessage = _textController.text;
                          sendMessageUsingRest(inputMessage: inputMessage);
                          _textController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
