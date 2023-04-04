import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rocket_chat_flutter_demo/models/chat_room.dart';
import 'package:rocket_chat_flutter_demo/models/message.dart';
import 'package:rocket_chat_flutter_demo/utils/session_helper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../repositories/repositories.dart';

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
  String? _typingStatus;
  final APIServiceRepository _apiServiceRepository = APIServiceRepository();

  @override
  void initState() {
    super.initState();
    getMessageHistoryUsingRest();
  }

  void sendTypingStatus({required bool isTyping}) {
    if (_channel != null) {
      _channel.sink.add(jsonEncode({
        "msg": "method",
        "method": "stream-notify-room",
        "id": "3",
        "params": [
          "${widget.chatRoom.id}/typing",
          SessionHelper.username,
          isTyping
        ],
        "authToken": "${SessionHelper.authToken}",
        "userId": "${SessionHelper.userId}",
      }));
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

      // Subscribe to typing events
      final uri = Uri.parse('wss://open.rocket.chat/websocket');
      _channel = WebSocketChannel.connect(uri);
      _channel.sink.add(jsonEncode({
        "msg": "connect",
        "version": "1",
        "support": ["1"],
      }));
      _channel.stream.listen((message) {
        log('Received: $message');
        final parsedMessage = jsonDecode(message);

        if (parsedMessage['msg'] == 'ping') {
          _channel.sink.add('{"msg": "pong"}');
        } else if (parsedMessage['msg'] == 'connected') {
          _channel.sink.add(jsonEncode({
            "msg": "method",
            "method": "login",
            "id": "1",
            "params": [
              {"resume": "${SessionHelper.authToken}"}
            ]
          }));
        } else if (parsedMessage['msg'] == 'result' &&
            parsedMessage['id'] == '0') {
          _channel.sink.add(jsonEncode({
            "msg": "sub",
            "id": "1",
            "name": "stream-notify-room",
            "params": ["${widget.chatRoom.id}/typing", false],
          }));
        } else if (parsedMessage['msg'] == 'changed' &&
            parsedMessage['collection'] == 'stream-notify-room') {
          final fields = parsedMessage['fields'];
          final eventName = fields['eventName'].split('/')[1];
          if (eventName == 'typing') {
            final user = fields['args'][0];
            final isTyping = fields['args'][1];
            setState(() {
              _typingStatus = isTyping ? '$user is typing' : null;
            });
          }
        }
      });

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
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              sendTypingStatus(isTyping: true);
                            } else {
                              sendTypingStatus(isTyping: false);
                            }
                          },
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
                        onPressed: () async {
                          final inputMessage = _textController.text;
                          final Message? message =
                              await _apiServiceRepository.sendMessageUsingRest(
                                  inputMessage: inputMessage,
                                  roomID: widget.chatRoom.id);
                          setState(() {
                            _messages.add(message!);
                          });
                          _textController.clear();
                        },
                      ),
                    ],
                  ),
                ),
                if (_typingStatus != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _typingStatus!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
