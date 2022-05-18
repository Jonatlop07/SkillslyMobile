import 'package:skillsly_ma/src/features/post/domain/post_owner.dart';
import 'package:skillsly_ma/src/features/post/domain/post_privacy.dart';

import 'post_content_element.dart';

class PostModel {
  PostModel({
    required this.id,
    this.owner,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    required this.privacy,
    required this.contents,
  });

  final String id;
  final PostOwner? owner;
  final String description;
  final String createdAt;
  final String? updatedAt;
  final PostPrivacy privacy;
  final List<PostContentElement> contents;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonContents = json['content_element'];
    return PostModel(
      id: json['id'],
      owner: PostOwner.fromJson(json['owner']),
      description: json['description'],
      createdAt: json['created_at'],
      privacy: PostPrivacy.values.firstWhere((p) => p.name == json['privacy']),
      contents: jsonContents
          .map(
            (content) => PostContentElement.fromJson(content),
          )
          .toList(),
    );
  }
}
