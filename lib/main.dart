import 'package:flutter/material.dart';
import 'package:rocket_chat_flutter_demo/models/chat_room.dart';
import 'package:rocket_chat_flutter_demo/respository/api_service.dart';
import 'package:rocket_chat_flutter_demo/respository/rocket_chat.dart';
import 'package:rocket_chat_flutter_demo/screens/channels_page.dart';
import 'package:rocket_chat_flutter_demo/screens/chat_screen.dart';
import 'package:rocket_chat_flutter_demo/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: ChannelsPage(),
    );
  }
}
