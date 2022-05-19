import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comment_card_controller.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comment_card_state.dart';
import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

class CommentCard extends ConsumerStatefulWidget {
  CommentDetails comment;
  final VoidCallback? onCommentDeleted;
  CommentCard({required this.comment, Key? key, this.onCommentDeleted}) : super(key: key);

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  String owner_name = '';

  Future<void> _delete() async {
    final controller = ref.read(commentCardControllerProvider(null).notifier);
    final success = await controller.delete(widget.comment.id);
    if (success) {
      widget.onCommentDeleted?.call();
      GoRouter.of(context).goNamed(Routes.feed);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      commentCardControllerProvider(null).select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    var _chewieController;
    if (widget.comment.media_locator.isNotEmpty && widget.comment.media_type.startsWith('video')) {
      _chewieController = ChewieController(
        videoPlayerController: VideoPlayerController.network(widget.comment.media_locator),
        autoInitialize: true,
      );
    }
    var comment_details = widget.comment;
    const containerHeight = Sizes.p48 * 3;
    const containerMargin = EdgeInsets.symmetric(vertical: Sizes.p12, horizontal: 0);

    final state = ref.watch(commentCardControllerProvider(null));
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.comment.owner.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text(widget.comment.owner.email, style: Theme.of(context).textTheme.caption),
                ),
                Row(
                  children: [
                    if (comment_details.description.isNotEmpty)
                      Expanded(
                        child: Text(
                          comment_details.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    PopupMenuButton(
                        icon: const Icon(Icons.more_horiz),
                        itemBuilder: (_) => <PopupMenuItem<String>>[
                              PopupMenuItem<String>(
                                  child: Container(
                                      width: 100,
                                      // height: 30,
                                      child: const Text(
                                        "Editar",
                                      )),
                                  value: 'editar'),
                              PopupMenuItem<String>(
                                  child: Container(
                                      width: 100,
                                      // height: 30,
                                      child: const Text(
                                        "Eliminar",
                                        style: TextStyle(color: Colors.red),
                                      )),
                                  value: 'eliminar'),
                            ],
                        onSelected: (index) async {
                          switch (index) {
                            case 'editar':
                              GoRouter.of(context)
                                  .goNamed(Routes.editComment, extra: comment_details);
                              break;
                            case 'eliminar':
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                        title: const Text("¿Eliminar comentario?"),
                                        content: Text(state.removeCommentDialogText),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancelar')),
                                          TextButton(
                                              onPressed: () {
                                                _delete();
                                              },
                                              child: const Text('Eliminar'))
                                        ],
                                      ));
                              break;
                          }
                        })
                  ],
                ),
                if (widget.comment.media_locator.isNotEmpty &&
                    comment_details.media_type.startsWith('image'))
                  Container(
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: comment_details.media_locator,
                      height: Sizes.p48 * 2,
                    ),
                  ),
                if (widget.comment.media_locator.isNotEmpty &&
                    comment_details.media_type.startsWith('video'))
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Container(
                        margin: containerMargin,
                        height: containerHeight,
                        child: Chewie(
                          controller: _chewieController,
                        ),
                      ))
              ],
            )));
  }
}
