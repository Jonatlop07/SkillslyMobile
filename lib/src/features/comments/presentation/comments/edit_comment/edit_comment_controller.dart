import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/comments/data/comments_service.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_content_details.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/edit_comment/edit_comment_state.dart';
import 'package:skillsly_ma/src/shared/service/media_service.dart';
import 'package:skillsly_ma/src/shared/types/external_file_descriptor.dart';
import 'package:skillsly_ma/src/shared/utils/file_utils.dart';

class EditCommentController extends StateNotifier<EditCommentState> {
  EditCommentController(
      {required this.commentsService, required this.mediaService})
      : super(EditCommentState());

  final CommentsService commentsService;
  final MediaService mediaService;

  Future<bool> editComment(
      String comment_id, CommentContentInputDetails new_content) async {
    state = state.copyWith(value: const AsyncValue.loading());
    final value =
        await AsyncValue.guard(() => _submitComment(comment_id, new_content));
    state = state.copyWith(value: value);
    return !value.hasError;
  }

  Future<CommentContentDetails> _submitComment(
      String comment_id, CommentContentInputDetails new_content) async {
    final String uploaded_media = new_content.media != null
        ? await _uploadCommentMedia(new_content.media)
        : '';
    return await _updateComment(
        comment_id, new_content.description, uploaded_media);
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

  Future<CommentContentDetails> _updateComment(
      String comment_id, String description, String media_locator) async {
    return await commentsService.editComment(
        comment_id, description, media_locator);
  }
}

final editCommentControllerProvider = StateNotifierProvider.autoDispose
    .family<EditCommentController, EditCommentState, void>((ref, _) {
  final mediaService = ref.watch(mediaServiceProvider);
  final commentsService = ref.watch(commentServiceProvider);
  return EditCommentController(
      commentsService: commentsService, mediaService: mediaService);
});
