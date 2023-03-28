import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rocket_chat_flutter_demo/models/chat_room.dart';
import 'package:rocket_chat_flutter_demo/models/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Message> _messages = [];

  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    final uri = Uri.parse('wss://open.rocket.chat/websocket');
    _channel = WebSocketChannel.connect(uri);
    _channel.stream.listen((event) {
      log("connection succesful");
      final jsonEvent = jsonDecode(event);
      if (jsonEvent['msg'] == 'added' &&
          jsonEvent['collection'] == 'stream-room-messages') {
        final messageData = jsonEvent['fields'];
        final message = Message.fromJson(messageData);
        setState(() {
          _messages.add(message);
        });
      }
    });
    _joinRoom();
  }

  void _joinRoom() {
    final roomId = widget.chatRoom.id;
    final joinRoomMessage = jsonEncode({
      'msg': 'method',
      'method': 'joinRoom',
      'params': [roomId, null],
      'id': '1'
    });
    _channel.sink.add(joinRoomMessage);
  }

  void _sendMessage(String messageText) {
    try {
      log("sending message");
      final roomId = widget.chatRoom.id;
      final messageId = Uuid().v4();
      final sendMessageMessage = jsonEncode({
        'msg': 'method',
        'method': 'sendMessage',
        'params': [
          {'_id': messageId, 'rid': roomId, 'msg': messageText}
        ],
        'id': '2'
      });
      _channel.sink.add(sendMessageMessage);
      _textController.clear();
      log("message sent");
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.sender,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        message.time.toIso8601String(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
                    final messageText = _textController.text;
                    _sendMessage(messageText);
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
