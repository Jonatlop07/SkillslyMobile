import 'package:skillsly_ma/src/features/comments/domain/comment_owner.dart';
import 'package:skillsly_ma/src/features/post/domain/post_owner.dart';

class InnerCommentDetails {
  const InnerCommentDetails(
      {required this.id,
      required this.owner_id,
      required this.description,
      required this.media_locator,
      required this.media_type,
      required this.created_at,
      required this.comment_id,
      required this.owner,
      this.updated_at});

  final String id;
  final String owner_id;
  final String description;
  final String media_locator;
  final String media_type;
  final String created_at;
  final String comment_id;
  final CommentOwner owner;
  final String? updated_at;

  factory InnerCommentDetails.fromJson(Map<String, dynamic> json) {
    return InnerCommentDetails(
        id: json['_id'],
        owner_id: json['owner_id'],
        description: json['description'],
        media_locator: json['media_locator'],
        media_type: json['media_type'],
        created_at: json['created_at'],
        comment_id: json['comment_id'],
        updated_at: json['updated_at'],
        owner: CommentOwner.fromJson(json['owner']));
  }
}
