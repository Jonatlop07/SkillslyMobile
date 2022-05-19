import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';

class CommentCollection {
  const CommentCollection({
    required this.comments,
  });

  final List<CommentDetails> comments;
}
