import 'package:flutter/cupertino.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_center.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/breakpoints.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';

class CommentsBuilder extends StatelessWidget {
  const CommentsBuilder({
    Key? key,
    required this.comments,
    required this.commentBuilder,
  }) : super(key: key);

  final List<CommentDetails> comments;
  final Widget Function(BuildContext, CommentDetails, int) commentBuilder;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return ResponsiveCenter(
        child: Text('Ningún comentario ha sido creado hasta el momento'.hardcoded),
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
                final item = comments[index];
                return commentBuilder(context, item, index);
              },
              itemCount: comments.length,
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
              final item = comments[index];
              return commentBuilder(context, item, index);
            },
            itemCount: comments.length,
          ),
        ),
      ],
    );
  }
}
