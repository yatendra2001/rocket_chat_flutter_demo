import 'package:flutter/material.dart';
import 'package:rocket_chat_flutter_demo/config/route_generator.dart';
import 'package:rocket_chat_flutter_demo/models/chat_room.dart';
import 'package:rocket_chat_flutter_demo/respository/api_service.dart';
import 'package:rocket_chat_flutter_demo/respository/rocket_chat.dart';
import 'package:rocket_chat_flutter_demo/screens/screens.dart';

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
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: LoginScreen.routeName,
    );
  }
}
