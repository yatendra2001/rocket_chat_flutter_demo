class ChatRoom {
  String id;
  String name;

  ChatRoom({required this.id, required this.name});

  ChatRoom.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        name = json['name'];
}
