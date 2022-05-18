import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_center.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/routing/route_paths.dart';
import 'package:skillsly_ma/src/features/comments/data/comments_service.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/search_comments_pagination.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comment_card.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/create_comment/create_comment.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_provider.dart';

class CommentsList extends ConsumerStatefulWidget {
  final String postId;
  const CommentsList({Key? key, required this.postId}) : super(key: key);

  @override
  ConsumerState<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<CommentsList> {
  int page = 0;
  final int limit = 4;
  List<CommentDetails> comments = [];

  Future<List<CommentDetails>> fetchComments() async {
    final commentService = ref.read(commentServiceProvider);
    return await commentService.getComments(widget.postId,
        SearchCommentsPaginationDetails(page: page, limit: limit));
  }

  void loadComments() async {
    print(widget.postId);
    var fetchedComments = await fetchComments();
    setState(() {
      comments = fetchedComments;
      page += 1;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        // IconButton(
        //     onPressed: () {
        //       GoRouter.of(context).go(
        //         RoutePaths.postsOfUser(
        //           ref.watch(authStateProvider.select((value) => value?.id)),
        //         ),
        //       );
        //     },
        //     icon: Icon(Icons.arrow_back)),
      ]),
      body: Container(
          child: Column(
        children: [
          Expanded(
            child: SizedBox(
              child: ListView.builder(
                  itemBuilder: (context, index) => ResponsiveCenter(
                        child: CommentCard(
                          comment: comments[index],
                          onCommentDeleted: () {
                            print('Comment deleted');
                          },
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.p16, vertical: Sizes.p8),
                      ),
                  itemCount: comments.length),
            ),
          ),
          CreateCommentWidget(
            onCommentCreated: () {
              print('Comment created');
            },
            post_id: widget.postId,
          )
        ],
      )),
    );
  }
}
