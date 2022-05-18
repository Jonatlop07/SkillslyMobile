import 'dart:core';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/features/account_settings/data/account_service.dart';
import 'package:skillsly_ma/src/features/comments/data/comments_service.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_owner.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comment_card_state.dart';

class CommentCardController extends StateNotifier<CommentCardState> {
  CommentCardController(
      {required this.commentService, required this.accountService})
      : super(CommentCardState());

  final CommentsService commentService;
  final AccountService accountService;

  Future<bool> delete(String comment_id) async {
    state = state.copyWith(value: const AsyncValue.loading());
    final value = await AsyncValue.guard(() => _deleteComment(comment_id));
    state = state.copyWith(value: value);
    return !value.hasError;
  }

  Future<String> _deleteComment(String comment_id) async {
    return await commentService.deleteComment(comment_id);
  }

  Future<CommentOwner> _getOwnerData(String owner_id) async {
    return await accountService.getUserData(owner_id);
  }
}

final commentCardControllerProvider = StateNotifierProvider.autoDispose
    .family<CommentCardController, CommentCardState, void>((ref, _) {
  final commentService = ref.watch(commentServiceProvider);
  final accountService = ref.watch(accountServiceProvider);
  return CommentCardController(
      commentService: commentService, accountService: accountService);
});
