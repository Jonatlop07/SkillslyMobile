import 'package:flutter/cupertino.dart';
import 'package:skillsly_ma/src/core/common_widgets/empty_placeholder_widget.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_center.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/breakpoints.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/post/domain/post_model.dart';

class PostsBuilder extends StatelessWidget {
  const PostsBuilder({
    Key? key,
    required this.posts,
    required this.postBuilder,
  }) : super(key: key);

  final List<PostModel> posts;
  final Widget Function(BuildContext, PostModel, int) postBuilder;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return EmptyPlaceholderWidget(
        message: 'Ningúna publicación ha sido creada hasta el momento'.hardcoded,
      );
    }
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= Breakpoint.tablet) {
      return ResponsiveCenter(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
        child: Row(
          children: [
            ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: Sizes.p16),
              itemBuilder: (context, index) {
                final item = posts[index];
                return postBuilder(context, item, index);
              },
              itemCount: posts.length,
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(Sizes.p16),
            itemBuilder: (context, index) {
              final item = posts[index];
              return postBuilder(context, item, index);
            },
            itemCount: posts.length,
          ),
        ),
      ],
    );
  }
}
