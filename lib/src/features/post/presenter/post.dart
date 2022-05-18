import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/common_widgets/outlined_action_button_with_icon.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_center.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_scrollable_card.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/palette.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comments_list.dart';
import 'package:skillsly_ma/src/features/post/data/post_service.dart';
import 'package:skillsly_ma/src/features/post/domain/post_content_element.dart';
import 'package:skillsly_ma/src/features/post/domain/post_model.dart';
import 'package:video_player/video_player.dart';

class Post extends ConsumerStatefulWidget {
  const Post({
    Key? key,
    required this.postModel,
    this.ownerName,
    this.postIndex,
  }) : super(key: key);

  final PostModel postModel;
  final String? ownerName;
  final int? postIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostState();
}

class _PostState extends ConsumerState<Post> {
  final List<ChewieController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializeVideoControllers());
  }

  bool _isImage(String mediaType) {
    return mediaType.startsWith('image/');
  }

  Future<void> _initializeVideoControllers() async {
    await Future.wait(
      widget.postModel.contents.asMap().entries.map(
        (entry) async {
          int index = entry.key;
          final PostContentElement element = entry.value;
          if (element.mediaLocator != null && !_isImage(element.mediaType!)) {
            VideoPlayerController? videoController =
                VideoPlayerController.network(element.mediaLocator!);
            await videoController.initialize();
            _videoControllers[index] = ChewieController(
              videoPlayerController: videoController,
            );
          }
        },
      ),
    );
  }

  Widget _renderFileBox(int index) {
    const containerHeight = Sizes.p48 * 3;
    const containerMargin =
        EdgeInsets.symmetric(vertical: Sizes.p12, horizontal: 0);
    if (_isImage(widget.postModel.contents[index].mediaType!)) {
      return Container(
          height: containerHeight,
          margin: containerMargin,
          child: Image.network(widget.postModel.contents[index].mediaLocator!));
    }
    return Container(
      height: containerHeight,
      margin: containerMargin,
      child: Chewie(controller: _videoControllers[index]),
    );
  }

  Future<void> _deletePost() async {
    await ref.read(postServiceProvider).deletePost(widget.postModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScrollableCard(
      child: ResponsiveCenter(
        child: Column(
          children: [
            SizedBox(
              height: Sizes.p24,
              child: Text(
                widget.ownerName != null
                    ? widget.ownerName!
                    : widget.postModel.owner.name,
                style: const TextStyle(
                  fontSize: Sizes.p20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: Sizes.p20,
              child: Text(
                widget.postModel.createdAt,
                style: const TextStyle(
                  fontSize: Sizes.p16,
                ),
              ),
            ),
            SizedBox(
              height: Sizes.p24,
              child: Text(
                widget.postModel.description,
                style: const TextStyle(
                  fontSize: Sizes.p20,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.postModel.contents.length,
              itemBuilder: (context, i) => Card(
                child: Container(
                  margin: const EdgeInsets.all(Sizes.p12),
                  padding: const EdgeInsets.all(Sizes.p12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: Sizes.p24,
                        child: Text(
                          widget.postModel.description,
                          style: const TextStyle(
                            fontSize: Sizes.p20,
                          ),
                        ),
                      ),
                      gapH8,
                      if (widget.postModel.contents[i].mediaLocator != null)
                        _renderFileBox(i),
                      ResponsiveCenter(
                        child: OutlinedActionButtonWithIcon(
                          text: 'Editar'.hardcoded,
                          color: Palette.primary.shade200,
                          iconData: Icons.upload_file,
                          onPressed: () {},
                        ),
                      ),
                      gapH8,
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              trailing: OutlinedActionButtonWithIcon(
                text: 'Borrar'.hardcoded,
                color: Palette.tertiary,
                iconData: Icons.remove_circle_outline_outlined,
                onPressed: () async {
                  await _deletePost();
                  GoRouter.of(context).goNamed(Routes.feed);
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.all(5)),
                  child: Text('Ver comentarios',
                      style: TextStyle(
                          fontSize: Sizes.p12,
                          color: Palette.primary.shade300)),
                  onPressed: () {
                    GoRouter.of(context).goNamed(Routes.comments,
                        params: {'postId': widget.postModel.id});
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
