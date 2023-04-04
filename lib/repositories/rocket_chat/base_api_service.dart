import 'package:google_sign_in/google_sign_in.dart';
import 'package:rocket_chat_flutter_demo/models/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class BaseAPIServiceRepository {
  Future<List<dynamic>?> getRooms();
  Future<void> getRoomsHistory({required String roomId});
  Future<void> getGroups();
  Future<Map<String, String>?> googleSSOLogin(
      GoogleSignInAuthentication signIn, acsCode);
  Future<Message?> sendMessageUsingRest(
      {required String inputMessage, required String roomID});
}
