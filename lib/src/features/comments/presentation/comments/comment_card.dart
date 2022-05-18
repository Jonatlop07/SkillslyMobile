import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/account_settings/data/account_service.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_media.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_owner.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comment_card_controller.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comment_card_state.dart';
import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

class CommentCard extends ConsumerStatefulWidget {
  CommentDetails comment;
  final VoidCallback? onCommentDeleted;
  CommentCard({required this.comment, Key? key, this.onCommentDeleted})
      : super(key: key);

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
    }
  }

  Future<CommentOwner> _getOwner() async {
    final controller = ref.read(accountServiceProvider);
    return await controller.getUserData(widget.comment.id);
  }

  void setOwner() async {
    var ownerData = await _getOwner();
    print('owner allo? $ownerData');
    setState(() {
      owner_name = ownerData.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      commentCardControllerProvider(null).select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    var _chewieController;
    if (widget.comment.media_locator.isNotEmpty &&
        media.media_type.startsWith('video')) {
      _chewieController = ChewieController(
        videoPlayerController: VideoPlayerController.network(media.media_file),
        autoInitialize: true,
      );
    }
    var comment_details = widget.comment;
    const containerHeight = Sizes.p48 * 3;
    const containerMargin =
        EdgeInsets.symmetric(vertical: Sizes.p12, horizontal: 0);

    final state = ref.watch(commentCardControllerProvider(null));
    return Card(
        child: Padding(
            padding: EdgeInsets.all(Sizes.p16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.comment.owner_id,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    if (comment_details.description.isNotEmpty)
                      Expanded(
                        child: Text(
                          comment_details.description,
                          style: Theme.of(context).textTheme.caption,
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
                              GoRouter.of(context).goNamed(Routes.editComment,
                                  extra: comment_details);
                              break;
                            case 'eliminar':
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title:
                                            const Text("¿Eliminar comentario?"),
                                        content:
                                            Text(state.removeCommentDialogText),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancelar')),
                                          TextButton(
                                              onPressed: () {
                                                _delete();
                                                Navigator.pop(context);
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
                    media.media_type.startsWith('image'))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: media.media_file,
                      height: Sizes.p48 * 2,
                    ),
                  ),
                if (widget.comment.media_locator.isNotEmpty &&
                    media.media_type.startsWith('video'))
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

  CommentMedia get media {
    String media_file = '';
    String media_type = '';
    if (widget.comment.media_locator.split(" ").length < 2) {
      media_file = widget.comment.media_locator.split(" ")[0];
      media_type = widget.comment.media_locator.split(" ")[1];
    } else {
      media_file = widget.comment.media_locator.split(" ")[0] +
          " " +
          widget.comment.media_locator.split(" ")[1];
      media_type = widget.comment.media_locator.split(" ")[2];
    }
    return CommentMedia(media_file: media_file, media_type: media_type);
  }
}
