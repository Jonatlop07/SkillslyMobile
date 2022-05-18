import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/create_comment/create_comment_controller.dart';
import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';
import 'package:skillsly_ma/src/shared/utils/file_utils.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/constants/app.sizes.dart';
import 'create_comment_state.dart';

class CreateCommentWidget extends ConsumerStatefulWidget {
  String post_id;
  String? comment_id;
  final VoidCallback? onCommentCreated;
  CreateCommentWidget(
      {Key? key, required this.post_id, this.onCommentCreated, this.comment_id})
      : super(key: key);

  @override
  ConsumerState<CreateCommentWidget> createState() =>
      _CreateCommentWidgetState();
}

class _CreateCommentWidgetState extends ConsumerState<CreateCommentWidget> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  String get commentText => _commentController.text;

  var media = File('');
  var mediaController;
  var _cantSubmit = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      VideoPlayerController? videoController;
      ChewieController? chewieController;
      if (isVideo(file.path)) {
        videoController = VideoPlayerController.file(file)..initialize();
        chewieController =
            ChewieController(videoPlayerController: videoController);
      }
      setState(() {
        _cantSubmit = false;
        media = file;
        mediaController = chewieController;
      });
    }
  }

  Future<void> _submit(CreateCommentState state) async {
    if (state.canSubmitComment(commentText, media)) {
      setState(() {
        _cantSubmit = false;
      });
      final controller =
          ref.read(createCommentControllerProvider(null).notifier);
      final success =
          await controller.submit(widget.post_id, commentText, media);
      if (success) {
        widget.onCommentCreated?.call();
        GoRouter.of(context).goNamed(Routes.account);
      }
    } else {
      setState(() {
        _cantSubmit = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
        createCommentControllerProvider(null).select((state) => state.value),
        (_, state) {
      state.showAlertDialogOnError(context);
    });

    final state = ref.watch(createCommentControllerProvider(null));
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          if (media.path.isNotEmpty)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(20)),
              child: _renderFileBox(),
            ),
          if (_cantSubmit)
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(2),
              child: Text(
                state.noCommentContentLabelText,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: Colors.red.shade300),
              ),
            ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TextFormField(
                        controller: _commentController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(15, 5, 0, 5),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black12, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'Escribe un comentario'),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _loadFile();
                    },
                    icon: Icon(Icons.image),
                  ),
                  IconButton(
                      onPressed: state.isLoading ? null : () => _submit(state),
                      icon: Icon(Icons.send))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderFileBox() {
    const containerHeight = Sizes.p48 * 3;
    const containerMargin = EdgeInsets.symmetric(vertical: 0, horizontal: 0);
    final File file = media;
    if (isImage(file.path)) {
      return Stack(
        children: [
          Container(
            height: containerHeight,
            margin: containerMargin,
            alignment: Alignment.center,
            child: Image(
              image: FileImage(file),
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    this.media = File('');
                  });
                },
              ))
        ],
      );
    } else if (isVideo(file.path)) {
      return Container(
        height: containerHeight,
        margin: containerMargin,
        child: Chewie(controller: mediaController!),
      );
    }
    return gapH4;
  }
}
