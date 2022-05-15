class Conversation {
  Conversation(this.name, this.description,
      {required this.id, required this.createdAt, required this.isPrivate});

  final String id;
  final String name;
  final String description;
  final String createdAt;
  final bool isPrivate;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      json['name'],
      json['description'],
      id: json['conversation_id'],
      createdAt: json['created_at'],
      isPrivate: json['isPrivate'],
    );
  }
}
