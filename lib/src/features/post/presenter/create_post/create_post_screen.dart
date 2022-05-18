import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/common_widgets/outlined_action_button_with_icon.dart';
import 'package:skillsly_ma/src/core/common_widgets/primary_button.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_center.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_scrollable_card.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/breakpoints.dart';
import 'package:skillsly_ma/src/core/constants/palette.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/main_drawer.dart';
import 'package:skillsly_ma/src/features/post/domain/new_post_input.dart';
import 'package:skillsly_ma/src/features/post/domain/post_content_with_media.dart';
import 'package:skillsly_ma/src/features/post/domain/post_privacy.dart';
import 'package:skillsly_ma/src/features/post/presenter/create_post/create_post_controller.dart';
import 'package:skillsly_ma/src/features/post/presenter/create_post/create_post_state.dart';
import 'package:skillsly_ma/src/features/post/presenter/create_post/post_content_input.dart';
import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';
import 'package:skillsly_ma/src/shared/utils/file_utils.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  static const descriptionKey = Key('description');
  static const privacyKey = Key('privacy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva publicación'.hardcoded)),
      drawer: const MainDrawer(),
      body: const _CreatePostContent(),
    );
  }
}

class _CreatePostContent extends ConsumerStatefulWidget {
  const _CreatePostContent({
    Key? key,
    this.onPostCreated,
  }) : super(key: key);

  final VoidCallback? onPostCreated;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreatePostContentState();
}

class _CreatePostContentState extends ConsumerState<_CreatePostContent> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  PostPrivacy _privacy = PostPrivacy.public;
  final List<PostContentInput> _contents = [];

  String get description => _descriptionController.text;

  var _submitted = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    for (PostContentInput element in _contents) {
      element.descriptionController!.dispose();
      if (element.videoController != null) {
        element.videoController!.videoPlayerController.dispose();
        element.videoController!.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _submit(CreatePostState state) async {
    setState(() => _submitted = true);
    // only submit the form if validation passes
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(createPostControllerProvider(null).notifier);
      final success = await controller.submit(
        NewPostInput(
          description: description,
          privacy: _privacy,
          contents: _contents
              .map(
                (content) => PostContentWithFile(
                  media: content.media,
                  mediaType: content.media != null ? getMediaType(getFileName(content.media!)) : '',
                  description: content.descriptionController!.text,
                ),
              )
              .toList(),
        ),
      );
      if (success) {
        widget.onPostCreated?.call();
      }
    }
  }

  _addPostElement() {
    setState(() {
      _contents.add(
        PostContentInput(
          media: null,
          descriptionController: TextEditingController(),
          videoController: null,
        ),
      );
    });
  }

  Future<void> _loadFile(int index) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      VideoPlayerController? videoController;
      ChewieController? chewieController;
      if (isVideo(file.path)) {
        videoController = VideoPlayerController.file(file)..initialize();
        chewieController = ChewieController(
          videoPlayerController: videoController,
        );
      }
      setState(() {
        _contents[index].media = file;
        _contents[index].videoController = chewieController;
      });
    }
  }

  _removePostElement(int index) {
    setState(() {
      _contents.removeAt(index);
    });
  }

  Widget _renderFileBox(int index) {
    const containerHeight = Sizes.p48 * 3;
    const containerMargin = EdgeInsets.symmetric(vertical: Sizes.p12, horizontal: 0);
    final File file = _contents[index].media!;
    if (isImage(file.path)) {
      return Container(
        height: containerHeight,
        margin: containerMargin,
        child: Image(
          image: FileImage(file),
        ),
      );
    } else if (isVideo(file.path)) {
      return Container(
        height: containerHeight,
        margin: containerMargin,
        child: Chewie(controller: _contents[index].videoController!),
      );
    }
    return gapH4;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      createPostControllerProvider(null).select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(createPostControllerProvider(null));
    final List<Map<String, dynamic>> privacyOptions = [
      {'value': PostPrivacy.public, 'text': 'Pública'.hardcoded},
      {'value': PostPrivacy.private, 'text': 'Privada'.hardcoded},
    ];
    return ResponsiveScrollableCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              key: CreatePostScreen.descriptionKey,
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: state.descriptionLabelText,
                enabled: !state.isLoading,
              ),
              maxLength: state.textFieldMaxLength,
              minLines: state.textFieldMinLines,
              maxLines: state.textFieldMaxLines,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (description) =>
                  !_submitted ? null : state.descriptionErrorText(description ?? ''),
              autocorrect: false,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.multiline,
              keyboardAppearance: Brightness.light,
            ),
            gapH4,
            SizedBox(
              height: Sizes.p64,
              child: Column(
                children: [
                  DropdownButton(
                    key: CreatePostScreen.privacyKey,
                    value: _privacy,
                    items: privacyOptions
                        .map(
                          (privacy) => DropdownMenuItem(
                            value: privacy['value'],
                            child: Text(privacy['text']!),
                          ),
                        )
                        .toList(),
                    onChanged: (Object? newValue) {
                      setState(() {
                        _privacy = newValue! as PostPrivacy;
                      });
                    },
                  ),
                ],
              ),
            ),
            gapH4,
            SizedBox(
                height: state.postContentContainerHeight,
                child: SingleChildScrollView(
                  child: ResponsiveCenter(
                    maxContentWidth: Breakpoint.tablet,
                    child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(Sizes.p12),
                          child: _contents.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _contents.length,
                                  itemBuilder: (context, i) => Card(
                                    child: Container(
                                      margin: const EdgeInsets.all(Sizes.p12),
                                      padding: const EdgeInsets.all(Sizes.p12),
                                      child: Column(
                                        children: [
                                          ResponsiveCenter(
                                            child: TextFormField(
                                              key: const Key('description_el'),
                                              controller: _contents[i].descriptionController,
                                              decoration: InputDecoration(
                                                labelText: state.contentDescriptionLabelText,
                                                enabled: !state.isLoading,
                                              ),
                                              maxLength: state.textFieldMaxLength,
                                              minLines: state.textFieldMinLines,
                                              maxLines: state.textFieldMaxLines,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              validator: (description) => !_submitted
                                                  ? null
                                                  : state.descriptionErrorText(description ?? ''),
                                              autocorrect: false,
                                              textInputAction: TextInputAction.next,
                                              keyboardType: TextInputType.multiline,
                                              keyboardAppearance: Brightness.light,
                                            ),
                                          ),
                                          gapH8,
                                          if (_contents[i].media != null) _renderFileBox(i),
                                          ResponsiveCenter(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 0, vertical: Sizes.p12),
                                              child: Text(
                                                _contents[i].media != null
                                                    ? getFileName(_contents[i].media!)
                                                    : state.noFileLoadedLabelText,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          ResponsiveCenter(
                                            child: OutlinedActionButtonWithIcon(
                                              text: state.selectMediaLabelText,
                                              color: Palette.primary.shade200,
                                              iconData: Icons.upload_file,
                                              onPressed: () {
                                                _loadFile(i);
                                              },
                                            ),
                                          ),
                                          gapH8,
                                          ListTile(
                                            trailing: OutlinedActionButtonWithIcon(
                                              text: state.deletePostElementLabelText,
                                              color: Palette.tertiary,
                                              iconData: Icons.remove_circle_outline_outlined,
                                              onPressed: () {
                                                _removePostElement(i);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    state.noContentLabelText.hardcoded,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: Sizes.p16),
                                  ),
                                )),
                    ),
                  ),
                )),
            if (_contents.isNotEmpty) gapH8,
            OutlinedActionButtonWithIcon(
              text: state.addPostElementLabelText,
              color: Palette.secondary,
              iconData: Icons.add_box_outlined,
              onPressed: state.isLoading ? null : () => _addPostElement(),
            ),
            gapH8,
            PrimaryButton(
              text: state.submitButtonText,
              isLoading: state.isLoading,
              onPressed: state.isLoading ? null : () => _submit(state),
            ),
          ],
        ),
      ),
    );
  }
}
