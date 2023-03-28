import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rocket_chat_flutter_demo/respository/api_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> channels = [];

  @override
  void initState() {
    super.initState();
    getAllChannels();
  }

  Future<void> getAllChannels() async {
    try {
      final response = await getChannels();
      setState(() {
        // Initialize as empty list if null
        channels = response ?? [];
      });
      log(jsonEncode(channels));
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: channels.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: channels.length,
              itemBuilder: (BuildContext context, int index) {
                final channel = channels[index];
                final String name = channel['name'] ?? '';
                final lastMessage = channel['lastMessage'];
                final text =
                    lastMessage != null ? lastMessage['msg'] ?? '' : '';
                final time = channel['_updatedAt'] ?? '';
                final parsedTime = DateTime.tryParse(time);
                final formattedTime = parsedTime != null
                    ? DateFormat('MMM d, h:mm a').format(parsedTime)
                    : '';

                return channel['name'] != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            // TODO: Navigate to chat room screen
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "# $name",
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      text,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              },
            ),
    );
  }
}
