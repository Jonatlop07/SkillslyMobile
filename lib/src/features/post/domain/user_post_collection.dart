import 'package:skillsly_ma/src/features/post/domain/post_model.dart';
import 'package:skillsly_ma/src/features/post/domain/post_owner.dart';

class UserPostCollection {
  UserPostCollection({required this.posts, required this.owner});

  final List<PostModel> posts;
  final PostOwner owner;
}
