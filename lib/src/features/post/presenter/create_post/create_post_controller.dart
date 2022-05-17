import 'dart:core';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/post/data/post_service.dart';
import 'package:skillsly_ma/src/features/post/domain/new_post_details.dart';
import 'package:skillsly_ma/src/features/post/domain/new_post_input.dart';
import 'package:skillsly_ma/src/features/post/domain/post_content_element.dart';
import 'package:skillsly_ma/src/features/post/domain/post_content_with_media.dart';
import 'package:skillsly_ma/src/features/post/domain/post_model.dart';
import 'package:skillsly_ma/src/features/post/presenter/create_post/create_post_state.dart';
import 'package:skillsly_ma/src/shared/service/media_service.dart';
import 'package:skillsly_ma/src/shared/types/external_file_descriptor.dart';
import 'package:skillsly_ma/src/shared/utils/file_utils.dart';

class CreatePostController extends StateNotifier<CreatePostState> {
  CreatePostController({
    required this.mediaService,
    required this.postService,
  }) : super(CreatePostState());

  final MediaService mediaService;
  final PostService postService;

  Future<bool> submit(NewPostInput newPostInput) async {
    state = state.copyWith(value: const AsyncValue.loading());
    final value = await AsyncValue.guard(() => _submitPost(newPostInput));
    state = state.copyWith(value: value);
    return !value.hasError;
  }

  Future<PostModel> _submitPost(NewPostInput newPostInput) async {
    final List<PostContentElement> uploadedContents = await _uploadFiles(newPostInput.contents);
    final newPostDetails = NewPostDetails(
      description: newPostInput.description,
      privacy: newPostInput.privacy,
      contents: uploadedContents,
    );
    return await _createPost(newPostDetails);
  }

  Future<List<PostContentElement>> _uploadFiles(List<PostContentWithFile> contents) async {
    return await Future.wait(
      contents.map(
        (content) async {
          if (content.media == null || content.mediaType == null) {
            return PostContentElement(
              description: content.description,
              mediaLocator: null,
              mediaType: null,
            );
          }
          String filePath = content.media!.path;
          if (!isImage(filePath) && !isVideo(filePath)) {
            throw Exception('Not a valid file'.hardcoded);
          }
          final ExternalFileDescriptor fileDescriptor =
              await mediaService.uploadFile(content.media!);
          return PostContentElement(
            description: content.description,
            mediaLocator: fileDescriptor.mediaLocator,
            mediaType: fileDescriptor.mediaType,
          );
        },
      ),
    );
  }

  Future<PostModel> _createPost(NewPostDetails newPostDetails) async {
    return await postService.createPost(newPostDetails);
  }
}

final createPostControllerProvider =
    StateNotifierProvider.autoDispose.family<CreatePostController, CreatePostState, void>((ref, _) {
  final mediaService = ref.watch(mediaServiceProvider);
  final postService = ref.watch(postServiceProvider);
  return CreatePostController(
    mediaService: mediaService,
    postService: postService,
  );
});
