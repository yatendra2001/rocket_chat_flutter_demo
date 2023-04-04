import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:rocket_chat_flutter_demo/utils/session_helper.dart';

Future<void> login() async {
  final url = Uri.parse('http://localhost:3000/api/v1/login');
  final headers = {'Content-Type': 'application/json; charset=utf-8'};
  final body =
      json.encode({'username': 'my_username', 'password': 'my_password'});

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    // Login successful, handle response
  } else {
    // Login failed, handle error
  }
}

Future<List<dynamic>?> getRooms() async {
  log("start");
  try {
    final url = Uri.parse('https://open.rocket.chat/api/v1/rooms.get');
    final headers = {
      'X-User-Id': SessionHelper.userId!,
      'X-Auth-Token': SessionHelper.authToken!,
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);
    final result = jsonDecode(response.body)['update'];
    return result;
  } catch (error) {
    log(error.toString());
  }
}

Future<void> getRoomsHistory({required String roomId}) async {
  log("start");
  try {
    log("rooms id: $roomId");
    final url =
        Uri.parse('https://open.rocket.chat/api/v1/rooms.info?roomId=$roomId');
    final headers = {
      'X-User-Id': SessionHelper.userId!,
      'X-Auth-Token': SessionHelper.authToken!,
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);
    final result = jsonDecode(response.body);
    log(jsonEncode(result));
    // return result;
  } catch (error) {
    log(error.toString());
  }
}

Future<void> getGroups() async {
  final url = Uri.parse('https://chat.myserver.com/api/v1/groups.list');
  final headers = {
    'X-User-Id': 'uJK8DarWEz4KXywZrJJ',
    'X-Auth-Token': 'HSus82-hkmVAy-gECPS-QT5G0sCISSWzEEpfA7JybCv',
    'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    // Request successful, handle response
  } else {
    // Request failed, handle error
  }
}

Future<Map<String, String>?> googleSSOLogin(
    GoogleSignInAuthentication signIn, acsCode) async {
  final accessToken = signIn.accessToken;
  final idToken = signIn.idToken;
  String? acsPayload;

  if (acsCode is String) {
    acsPayload = acsCode;
  }

  final payload = acsCode != null
      ? jsonEncode({
          'serviceName': 'google',
          'accessToken': accessToken,
          'idToken': idToken,
          'expiresIn': 3600,
          'totp': {
            'code': acsPayload,
          },
        })
      : jsonEncode({
          'serviceName': 'google',
          'accessToken': accessToken,
          'idToken': idToken,
          'expiresIn': 3600,
          'scope': 'profile',
        });

  try {
    log("Rocket chat login request sent using OAuth");
    final response = await http.post(
      Uri.parse('https://open.rocket.chat/api/v1/login'),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );
    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      return {
        "userId": data['data']['userId'],
        "authToken": data['data']['authToken'],
        "username": data['data']['me']['username'],
      };
    }

    if (data['error'] == 'totp-required') {
      return data;
    }
  } catch (err) {
    log(err.toString());
  }
}
