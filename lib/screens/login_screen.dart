import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rocket_chat_flutter_demo/repositories/auth/auth_repository.dart';
import 'package:rocket_chat_flutter_demo/respository/api_service.dart';

class LoginScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'openid']);

  Future<GoogleSignInAuthentication?> _handleSignIn() async {
    try {
      _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      log(googleUser.toString());
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? idToken = googleAuth.idToken;
        final String? accessToken = googleAuth.accessToken;
        print('idToken: $idToken');
        print('accessToken: $accessToken');
        return googleAuth;
      }
    } catch (error) {
      log(error.toString());
    }
  }
  // Future<GoogleSignInAuthentication?> _handleSignIn() async {
  //   try {
  //     final user = await _googleSignIn.signIn();
  //     if (user != null) {
  //       final result = user.authentication;
  //       return result;
  //     }
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                final result = await getChannels();
                // await googleSSOLogin(result!, null);
              },
              icon: Image.asset(
                'assets/logo/google_logo.png',
                height: 25,
                width: 25,
              ),
              label: Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
