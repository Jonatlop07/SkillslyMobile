import 'package:skillsly_ma/src/features/chat/domain/member.dart';

class Conversation {
  Conversation(
      {required this.id,
      required this.createdAt,
      required this.isPrivate,
      required this.members,
      this.name,
      this.description});

  final String id;
  final String? name;
  final String? description;
  final String createdAt;
  final List<Member> members;
  final bool isPrivate;

  factory Conversation.fromJson(dynamic json) {
    List<Member> members = [];

    json["members"]
        .forEach((element) => {members.add(Member.fromJson(element))});

    if (json.keys.contains("name") && json.keys.contains("description")) {
      return Conversation(
          id: json["conversation_id"],
          createdAt: json["created_at"],
          isPrivate: json["is_private"],
          name: json["name"],
          members: members,
          description: json["description"]);
    }

    return Conversation(
      id: json['conversation_id'],
      members: members,
      createdAt: json['created_at'],
      isPrivate: json['is_private'],
    );
  }
}
