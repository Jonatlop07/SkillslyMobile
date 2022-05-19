import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/constants/app.colors.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/palette.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/main_drawer.dart';
import 'package:skillsly_ma/src/core/routing/route_paths.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_provider.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /*
     AsyncValue<List<PostModel>> postsOfUserAsync = ref.watch(
      getPostsOfFriendsProvider,
    );
    return AsyncValueWidget<List<PostModel>>(
      value: postsOfUserAsync,
      data: (posts) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Feed de publicaciones'.hardcoded),
          ),
          body: PostsBuilder(
            posts: posts,
            postBuilder: (_, post, index) => Post(
              postModel: post,
              ownerName: post.owner.name,
              postIndex: index,
            ),
          ),
        );
      },
    );
    */
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed de publicaciones'.hardcoded),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: Sizes.p20),
            child: GestureDetector(
              onTap: () {
                GoRouter.of(context).goNamed(Routes.createPost);
              },
              child: const Icon(
                Icons.post_add_outlined,
                color: Palette.secondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: Sizes.p20),
            child: GestureDetector(
              onTap: () {
                GoRouter.of(context).go(
                  RoutePaths.postsOfUser(
                    ref.watch(authStateProvider.select((value) => value?.id)),
                  ),
                );
              },
              child: const Icon(
                Icons.my_library_books_outlined,
                color: AppColors.beige,
              ),
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(),
    );
  }
}
