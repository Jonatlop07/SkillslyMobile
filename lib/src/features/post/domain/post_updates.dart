import 'post_content_element.dart';
import 'post_privacy.dart';

class PostUpdates {
  PostUpdates({
    required this.id,
    required this.ownerId,
    required this.description,
    required this.privacy,
    required this.contents,
  });

  final String id;
  final String ownerId;
  final String description;
  final PostPrivacy privacy;
  final List<PostContentElement> contents;

  Map<String, dynamic> toMap() {
    return {
      'post_id': id,
      'owner_id': ownerId,
      'description': description,
      'privacy': privacy as String,
      'content_element': contents.map((content) => content.toMap()).toList(),
    };
  }
}
