import 'package:skillsly_ma/src/features/post/domain/post_content_with_media.dart';

import 'post_privacy.dart';

class NewPostInput {
  NewPostInput({
    required this.description,
    required this.privacy,
    required this.contents,
  });

  final String description;
  final PostPrivacy privacy;
  final List<PostContentWithFile> contents;
}
