import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rocket_chat_flutter_demo/models/chat_room.dart';
import 'package:rocket_chat_flutter_demo/respository/api_service.dart';
import 'package:rocket_chat_flutter_demo/screens/screens.dart';

class ChannelsScreen extends StatefulWidget {
  static const routeName = '/channels-screen';
  const ChannelsScreen({Key? key}) : super(key: key);
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const ChannelsScreen(),
    );
  }

  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  List<dynamic> channels = [];

  @override
  void initState() {
    super.initState();
    getAllRooms();
  }

  Future<void> getAllRooms() async {
    try {
      final response = await getRooms();
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
        title: Text('Rocket Chat'),
        automaticallyImplyLeading: false,
      ),
      body: channels.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: channels.length,
              itemBuilder: (BuildContext context, int index) {
                final channel = channels[index];
                final String name = channel['name'] ?? channel["usernames"][0];
                final lastMessage = channel['lastMessage'];
                final text =
                    lastMessage != null ? lastMessage['msg'] ?? '' : '';
                final time = channel['_updatedAt'] ?? '';
                final parsedTime = DateTime.tryParse(time);
                final formattedTime = parsedTime != null
                    ? DateFormat('MMM d, h:mm a').format(parsedTime)
                    : '';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to chat room screen
                      Navigator.of(context).pushNamed(
                        ChatScreen.routeName,
                        arguments: ChatScreenArgs(
                          chatRoom: ChatRoom(
                              id: channel['_id'],
                              name: name,
                              type: channel['t']),
                        ),
                      );
                      // await getRoomsHistory(roomId: channel['_id']);
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
                                channel['name'] != null ? "#$name" : "@$name",
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
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            formattedTime,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
