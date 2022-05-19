import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/common_widgets/async_value_widget.dart';
import 'package:skillsly_ma/src/features/comments/data/comments_service.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_collection.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_search_params.dart';
import 'package:skillsly_ma/src/features/comments/domain/search_comments_pagination.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comment_card.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comments_builder.dart';

class CommentsList extends ConsumerStatefulWidget {
  final String postId;
  const CommentsList({Key? key, required this.postId}) : super(key: key);

  @override
  ConsumerState<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<CommentsList> {
  // List<CommentDetails> comments = [];

  // Future<List<CommentDetails>> fetchComments() async {
  //   final commentService = ref.read(commentServiceProvider);
  //   return await commentService.getComments(CommentSearchParams(
  //       postId: widget.postId,
  //       pagination: SearchCommentsPaginationDetails(page: page, limit: limit)));
  // }

  // void loadComments() async {
  //   print(widget.postId);
  //   var fetchedComments = await fetchComments();
  //   print(fetchedComments);
  //   setState(() {
  //     comments = fetchedComments;
  //     page += 1;
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   loadComments();
  // }

  @override
  Widget build(BuildContext context) {
    const int page = 0;
    const int limit = 10;
    final CommentSearchParams searchParams = CommentSearchParams(
      postId: widget.postId,
      pagination: const SearchCommentsPaginationDetails(page: page, limit: limit),
    );
    AsyncValue<CommentCollection> postCommentsAsync = ref.read(
      postCommentsProvider(searchParams),
    );
    return AsyncValueWidget<CommentCollection>(
        value: postCommentsAsync,
        data: (postComments) {
          print('hola' + postComments.toString());
          return Scaffold(
            appBar: AppBar(),
            body: CommentsBuilder(
              comments: postComments.comments,
              commentBuilder: (_, comment, index) => CommentCard(
                comment: comment,
              ),
            ),
          );
        });
  }
}
