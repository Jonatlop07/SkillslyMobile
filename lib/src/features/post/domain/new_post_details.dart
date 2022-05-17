import 'package:skillsly_ma/src/features/post/domain/post_content_element.dart';
import 'package:skillsly_ma/src/features/post/domain/post_privacy.dart';

class NewPostDetails {
  NewPostDetails({
    required this.ownerId,
    required this.description,
    required this.privacy,
    required this.contents,
  });

  final String ownerId;
  final String description;
  final PostPrivacy privacy;
  final List<PostContentElement> contents;

  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'description': description,
      'privacy': privacy as String,
      'content_element': contents.map((content) => content.toMap()).toList(),
    };
  }
}
