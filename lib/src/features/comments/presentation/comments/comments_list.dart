import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_center.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/breakpoints.dart';
import 'package:skillsly_ma/src/features/comments/data/comments_service.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/search_comments_pagination.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comment_card.dart';

class CommentsList extends ConsumerStatefulWidget {
  final String post_id;
  const CommentsList({Key? key, required this.post_id}) : super(key: key);

  @override
  ConsumerState<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<CommentsList> {
  int page = 0;
  final int limit = 10;
  List<CommentDetails> comments = [];

  Future<List<CommentDetails>> fetchComments() async {
    final commentService = ref.read(commentServiceProvider);
    return await commentService.getComments(widget.post_id,
        SearchCommentsPaginationDetails(page: page, limit: limit));
  }

  void loadComments() async {
    var fetchedComments = await fetchComments();
    setState(() {
      comments = fetchedComments;
      page += 1;
    });
  }

  @override
  void initState() {
    loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
          (context, index) => ResponsiveCenter(
                child: CommentCard(comment: comments[index]),
                padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p16, vertical: Sizes.p8),
              ),
          childCount: comments.length),
    );
  }
}
