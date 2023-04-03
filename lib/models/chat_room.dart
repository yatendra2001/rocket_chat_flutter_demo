// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatRoom {
  String id;
  String name;
  String type;

  ChatRoom({
    required this.id,
    required this.name,
    required this.type,
  });

  ChatRoom.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        name = json['name'],
        type = json['t'];
}
