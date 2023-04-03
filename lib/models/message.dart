// ignore_for_file: public_member_api_docs, sort_constructors_first
class Message {
  String text;
  String sender;
  DateTime time;
  String id;
  String senderId;

  Message({
    required this.text,
    required this.sender,
    required this.time,
    required this.id,
    required this.senderId,
  });

  Message.fromJson(Map<String, dynamic> json)
      : text = json['msg'],
        sender = json['u']['username'],
        time = DateTime.parse(json['ts']),
        id = json['_id'],
        senderId = json['u']['_id'];
}
