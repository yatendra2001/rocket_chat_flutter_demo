import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rocket_chat_flutter_demo/repositories/auth/auth_repository.dart';
import 'package:rocket_chat_flutter_demo/repositories/rocket_chat/api_service_repository.dart';
import 'package:rocket_chat_flutter_demo/screens/screens.dart';
import 'package:rocket_chat_flutter_demo/utils/session_helper.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login-screen';
  LoginScreen({Key? key}) : super(key: key);
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => LoginScreen(),
    );
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'openid']);
  final APIServiceRepository _apiServiceRepository = APIServiceRepository();
  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo/rocket_chat_logo.png',
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 50),
            Text(
              'Rocket Chat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              onPressed: () async {
                final result = await _authRepository.signInByGoogle();
                final data =
                    await _apiServiceRepository.googleSSOLogin(result!, null);
                SessionHelper.userId = data!["userId"];
                SessionHelper.authToken = data["authToken"];
                SessionHelper.username = data["username"];
                log(SessionHelper.userId!);
                log(SessionHelper.authToken!);
                Navigator.of(context).pushNamed(ChannelsScreen.routeName);
              },
              icon: Image.asset(
                'assets/logo/google_logo.png',
                height: 25,
                width: 25,
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Access your open.rocket.chat server',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
