class Message {
  String text;
  String sender;
  DateTime time;

  Message({required this.text, required this.sender, required this.time});

  Message.fromJson(Map<String, dynamic> json)
      : text = json['msg'],
        sender = json['u']['username'],
        time = DateTime.parse(json['ts']);
}
