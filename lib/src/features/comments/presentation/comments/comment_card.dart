import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/common_widgets/video_player.dart';

import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_media.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

class CommentCard extends ConsumerStatefulWidget {
  CommentDetails comment;
  CommentCard({required this.comment, Key? key}) : super(key: key);

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  CommentMedia get media {
    String media_file = '';
    String media_type = '';
    if (widget.comment.media_locator.split(" ").length > 1) {
      media_file = widget.comment.media_locator.split(" ")[0];
      media_type = widget.comment.media_locator.split(" ")[1];
    }
    return CommentMedia(media_file: media_file, media_type: media_type);
  }

  // final _chewieController = ChewieController(
  //   videoPlayerController: VideoPlayerController.network(
  //       'https://storage.googleapis.com/skillsly_st/images/file_example_MP4_480_1_5MG-1652642483948.mp4'),
  //   autoInitialize: true,
  // );

  @override
  Widget build(BuildContext context) {
    var comment_details = widget.comment;
    return Card(
        child: Padding(
            padding: EdgeInsets.all(Sizes.p16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment_details.owner_id,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    if (comment_details.description.isNotEmpty)
                      Expanded(
                        child: Text(
                          comment_details.description,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      )
                  ],
                ),
                if (widget.comment.media_locator.isNotEmpty)
                  if (media.media_type.startsWith('image'))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: media.media_file,
                        height: 100,
                        width: 100,
                      ),
                    ),
                if (media.media_type.startsWith('video'))
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: VideoApp(
                        media: media.media_file,
                      ))
                // Chewie(
                //   controller: _chewieController,
                // ))
              ]
              // FadeInImage.memoryNetwork(
              //     placeholder: kTransparentImage, image: media.media_file)
              ,
            )));
  }
}
