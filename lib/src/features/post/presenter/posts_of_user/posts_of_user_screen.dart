import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/common_widgets/async_value_widget.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/post/data/post_service.dart';
import 'package:skillsly_ma/src/features/post/domain/user_post_collection.dart';
import 'package:skillsly_ma/src/features/post/presenter/post.dart';
import 'package:skillsly_ma/src/features/post/presenter/posts_builder.dart';

class PostsOfUserScreen extends ConsumerWidget {
  const PostsOfUserScreen({Key? key, required this.ownerId}) : super(key: key);

  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PostsOfUserContents(ownerId: ownerId);
  }
}

class _PostsOfUserContents extends ConsumerStatefulWidget {
  const _PostsOfUserContents({
    Key? key,
    required this.ownerId,
  }) : super(key: key);

  final String ownerId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostsOfUserContentsState();
}

class _PostsOfUserContentsState extends ConsumerState<_PostsOfUserContents> {
  @override
  Widget build(BuildContext context) {
    AsyncValue<UserPostCollection> postsOfUserAsync = ref.watch(
      postsOfUserProvider(widget.ownerId),
    );
    return AsyncValueWidget<UserPostCollection>(
      value: postsOfUserAsync,
      data: (userPostCollection) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Publicaciones de ${userPostCollection.owner.name}'.hardcoded),
          ),
          body: PostsBuilder(
            posts: userPostCollection.posts,
            postBuilder: (_, post, index) => Post(
              postModel: post,
              ownerName: userPostCollection.owner.name,
              postIndex: index,
            ),
          ),
        );
      },
    );
  }
}
