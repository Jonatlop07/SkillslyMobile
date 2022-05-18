class Message {
  Message(
      {required this.content,
      required this.created_at,
      required this.owner_user_id});

  final String content;
  final String created_at;
  final String owner_user_id;

  factory Message.fromJson(dynamic json) {
    return Message(
        content: json["content"],
        created_at: json["created_at"],
        owner_user_id: json['owner_user_id']);
  }
}
