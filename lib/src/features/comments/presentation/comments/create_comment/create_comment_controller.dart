import 'dart:core';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/comments/data/comments_service.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/shared/service/media_service.dart';
import 'package:skillsly_ma/src/shared/types/external_file_descriptor.dart';
import 'package:skillsly_ma/src/shared/utils/file_utils.dart';

import 'create_comment_state.dart';

class CreateCommentController extends StateNotifier<CreateCommentState> {
  CreateCommentController(
      {required this.mediaService, required this.commentService})
      : super(CreateCommentState());

  final MediaService mediaService;
  final CommentsService commentService;

  Future<bool> submit(String post_id, String comment, File? media) async {
    state = state.copyWith(value: const AsyncValue.loading());
    final value =
        await AsyncValue.guard(() => _submitComment(post_id, comment, media));
    state = state.copyWith(value: value);
    return !value.hasError;
  }

  Future<CommentDetails> _submitComment(
      String post_id, String comment, File? media) async {
    final String uploaded_media =
        media != null ? await _uploadCommentMedia(media) : '';
    return await _createComment(post_id, comment, uploaded_media);
  }

  Future<String> _uploadCommentMedia(File media) async {
    String filePath = media.path;
    if (!isImage(filePath) && !isVideo(filePath)) {
      throw Exception('Not a valid file'.hardcoded);
    }
    final ExternalFileDescriptor fileDescriptor =
        await mediaService.uploadFile(media);
    return '${fileDescriptor.mediaLocator} ${fileDescriptor.mediaType}';
  }

  Future<CommentDetails> _createComment(
      String post_id, String comment, String uploaded_media) async {
    return await commentService.createComment(post_id, comment, uploaded_media);
  }
}

final createCommentControllerProvider = StateNotifierProvider.autoDispose
    .family<CreateCommentController, CreateCommentState, void>((ref, _) {
  final mediaService = ref.watch(mediaServiceProvider);
  final commentService = ref.watch(commentServiceProvider);
  return CreateCommentController(
      mediaService: mediaService, commentService: commentService);
});
