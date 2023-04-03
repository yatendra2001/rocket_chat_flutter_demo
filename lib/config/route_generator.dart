import 'package:flutter/material.dart';

import 'package:rocket_chat_flutter_demo/screens/screens.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => const Scaffold(),
        );
      case ChatScreen.routeName:
        return ChatScreen.route(args: settings.arguments as ChatScreenArgs);
      case ChannelsScreen.routeName:
        return ChannelsScreen.route();
      case LoginScreen.routeName:
        return LoginScreen.route();
      // case NavScreen.routeName:
      //   return NavScreen.route();
      // case PhoneScreen.routeName:
      //   return PhoneScreen.route();
      // case OtpScreen.routeName:
      //   return OtpScreen.route();
      // case ResultScreen.routeName:
      //   return ResultScreen.route();
      // case DashboardScreen.routeName:
      //   return DashboardScreen.route();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
        builder: (_) => Scaffold(
              appBar: AppBar(
                title: Text('Error'),
              ),
              body: Center(
                child: Text(
                  'Something Went Wrong!',
                  style: TextStyle(color: Colors.grey[600], fontSize: 24),
                ),
              ),
            ));
  }
}
