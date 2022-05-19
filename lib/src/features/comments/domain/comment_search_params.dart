import 'package:skillsly_ma/src/features/comments/domain/search_comments_pagination.dart';

class CommentSearchParams {
  const CommentSearchParams({
    required this.postId,
    required this.pagination,
  });

  final SearchCommentsPaginationDetails pagination;
  final String postId;
}
