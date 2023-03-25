import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

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

Future<void> getChannels() async {
  final url = Uri.parse('https://chat.myserver.com/api/v1/channels.list');
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
