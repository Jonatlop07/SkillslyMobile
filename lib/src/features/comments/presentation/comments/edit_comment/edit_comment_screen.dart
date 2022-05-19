import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/palette.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_content_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/edit_comment/edit_comment_controller.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/edit_comment/edit_comment_state.dart';
import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';
import 'package:skillsly_ma/src/shared/utils/file_utils.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

class EditCommentScreen extends ConsumerStatefulWidget {
  final VoidCallback? onCommentEdited;
  final CommentDetails comment_details;
  EditCommentScreen(
      {Key? key, required this.comment_details, this.onCommentEdited})
      : super(key: key);

  @override
  ConsumerState<EditCommentScreen> createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends ConsumerState<EditCommentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  String get commentText => _commentController.text;

  File media = File('');
  var mediaController;
  var initial_description;
  var initial_media_url = '';
  var initial_media_type = '';
  var _cantSubmit = false;
  var new_image_loaded = false;

  @override
  void didChangeDependencies() {
    _commentController.text = widget.comment_details.description;
    if (widget.comment_details.media_locator.isNotEmpty) {
      initial_media_url = widget.comment_details.media_locator;
      initial_media_type = widget.comment_details.media_type;
    }
    super.didChangeDependencies();
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
        media = file;
        mediaController = chewieController;
        initial_media_url = '';
      });
    }
  }

  Future<void> _editSubmit(EditCommentState state) async {
    if (state.canUpdateCommentIfMediaExists(commentText, initial_media_url) ||
        state.canUpdateComment(commentText, media)) {
      setState(() {
        _cantSubmit = false;
      });
      final controller = ref.read(editCommentControllerProvider(null).notifier);
      if (new_image_loaded) {
        final success = await controller.editComment(widget.comment_details.id,
            CommentContentInputDetails(description: commentText, media: media));
        if (success) {
          widget.onCommentEdited?.call();
          GoRouter.of(context).goNamed(Routes.feed);
        }
      } else {
        final success = await controller.editCommentWithoutMediaLoaded(
            widget.comment_details.id,
            commentText,
            initial_media_url,
            initial_media_type);
        if (success) {
          widget.onCommentEdited?.call();
          GoRouter.of(context).goNamed(Routes.feed);
        }
      }
    } else {
      setState(() {
        _cantSubmit = true;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
        editCommentControllerProvider(null).select((state) => state.value),
        (_, state) {
      print(state);
      state.showAlertDialogOnError(context);
    });
    final state = ref.watch(editCommentControllerProvider(null));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar comentario',
        ),
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).goNamed(Routes.feed);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
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
                                borderSide:
                                    BorderSide(color: Colors.black12, width: 2),
                                borderRadius: BorderRadius.circular(20)),
                            hintText: 'Nuevo contenido de comentario'),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _loadFile();
                    },
                    icon: const Icon(Icons.image),
                  ),
                ],
              ),
            ),
          ),
          if (_cantSubmit)
            Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(5),
              child: Text(
                state.noCommentContentLabelText,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: Palette.tertiary.shade100),
              ),
            ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton(
                style:
                    ElevatedButton.styleFrom(primary: Palette.primary.shade100),
                onPressed: state.isLoading
                    ? null
                    : () => GoRouter.of(context).goNamed(Routes.feed),
                child: Text("Cancelar")),
            gapW8,
            ElevatedButton(
                onPressed: state.isLoading ? null : () => _editSubmit(state),
                style: ElevatedButton.styleFrom(
                    shadowColor: Palette.primary.shade50, elevation: 5),
                child: Text("Actualizar")),
          ]),
          if (media.path.isEmpty) renderInitialMedia(),
          if (media.path.isNotEmpty) _renderFileBox(),
        ]),
      ),
    );
  }

  Widget _renderFileBox() {
    const containerHeight = Sizes.p48 * 2;
    const containerMargin =
        EdgeInsets.symmetric(vertical: Sizes.p12, horizontal: 0);
    final File file = media;
    if (isImage(file.path)) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image(
              fit: BoxFit.cover,
              image: FileImage(file),
            ),
          ),
        ),
      );
    } else if (isVideo(file.path)) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Container(
            height: containerHeight,
            margin: containerMargin,
            child: Chewie(controller: mediaController!),
          ),
        ),
      );
    }
    return gapH4;
  }

  Widget renderInitialMedia() {
    const containerHeight = Sizes.p48 * 2;
    const containerMargin =
        EdgeInsets.symmetric(vertical: Sizes.p12, horizontal: 0);
    if (initial_media_url.isNotEmpty &&
        initial_media_type.startsWith('image')) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: initial_media_url,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (initial_media_url.isNotEmpty &&
        initial_media_type.startsWith('video')) {
      return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Container(
              margin: containerMargin,
              height: containerHeight,
              child: Chewie(
                controller: mediaController!,
              ),
            )),
      );
    }
    return Container();
  }
}
