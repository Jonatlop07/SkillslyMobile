import 'package:skillsly_ma/src/features/post/domain/post_content_element.dart';
import 'package:skillsly_ma/src/features/post/domain/post_privacy.dart';

class NewPostDetails {
  NewPostDetails({
    required this.description,
    required this.privacy,
    required this.contents,
  });

  final String description;
  final PostPrivacy privacy;
  final List<PostContentElement> contents;

  Map<String, dynamic> toMap(String ownerId) {
    return {
      'owner_id': ownerId,
      'description': description,
      'privacy': privacy == PostPrivacy.public ? 'public' : 'private',
      'content_element': contents.map((content) => content.toMap()).toList(),
    };
  }
}
