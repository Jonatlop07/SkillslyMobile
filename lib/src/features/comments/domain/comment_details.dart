import 'package:skillsly_ma/src/features/comments/domain/comment_owner.dart';

class CommentDetails {
  const CommentDetails(
      {required this.id,
      required this.owner_id,
      required this.description,
      required this.media_locator,
      required this.media_type,
      required this.created_at,
      required this.owner,
      this.inner_comment_count,
      this.updated_at});

  final String id;
  final String owner_id;
  final String description;
  final String media_locator;
  final String media_type;
  final String created_at;
  final int? inner_comment_count;
  final String? updated_at;
  final CommentOwner owner;

  factory CommentDetails.fromJson(Map<String, dynamic> json) {
    return CommentDetails(
        id: json['_id'],
        owner_id: json['owner_id'],
        description: json['description'],
        media_locator: json['media_locator'],
        media_type: json['media_type'],
        created_at: json['created_at'],
        inner_comment_count: json['inner_comment_count'],
        updated_at: json['updated_at'],
        owner: CommentOwner.fromJson(json['owner']));
  }
}
