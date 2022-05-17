import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_content_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/search_comments_pagination.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_accessor.dart';
import '../../../shared/exception/request_exception.dart';

class CommentsService {
  CommentsService(this._client, Ref ref)
      : _authStateAccessor = AuthStateAccessor(ref);
  final GraphQLClient _client;
  final AuthStateAccessor _authStateAccessor;

  String? get _userId => _authStateAccessor.getAuthStateController().state?.id;

  Future<CommentDetails> getComments(
      String post_id, SearchCommentsPaginationDetails? query_params) async {
    final limit = query_params?.limit ?? 0;
    final page = query_params?.page ?? 0;
    final query_comments = gql('''
      query queryComments(\$post_id: ID!, \$comments_pagination: PaginationParams!){
        queryComments(post_id: \$post_id, comments_pagination: \$comments_pagination){
          _id
          owner_id
          description
          media_locator
          created_at
          inner_comment_count
          updated_at
        }
      }
    ''');
    final result =
        await _client.query(QueryOptions(document: query_comments, variables: {
      'post_id': post_id,
      'comments_pagination': {
        'limit': limit,
        'page': page,
      }
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    return CommentDetails.fromJson(
        result.data?['queryComments'] as Map<String, dynamic>);
  }

  Future<CommentDetails> createComment(
      String post_id, String comment, String media_locator) async {
    final create_comment = gql('''
      mutation createComment(\$comment_details: NewComment!, \$post_id: ID!){
        createComment(comment_details: \$comment_details, post_id: \$post_id){
          _id
          owner_id
          description
          media_locator
          created_at
        }
      }
    ''');
    final result = await _client
        .mutate(MutationOptions(document: create_comment, variables: {
      'comment_details': {
        'owner_id': _userId,
        'description': comment,
        'media_locator': media_locator
      },
      'post_id': post_id,
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    return CommentDetails.fromJson(
        result.data?['createComment'] as Map<String, dynamic>);
  }

  Future<CommentContentDetails> editComment(
      String comment_id, String description, String media_locator) async {
    final edit_comment = gql('''
      mutation updateComment(\$comment_id: ID!, \$new_content: CommentContentUpdate!){
        updateComment(comment_id: \$comment_id, new_content: \$new_content){
          description
          media_locator
        }
      }
    ''');
    final result = await _client
        .mutate(MutationOptions(document: edit_comment, variables: {
      'comment_id': comment_id,
      'new_content': {
        'description': description,
        'media_locator': media_locator
      },
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    return CommentContentDetails.fromJson(
        result.data?['updateComment'] as Map<String, dynamic>);
  }

  Future<String> deleteComment(String comment_id) async {
    final delete_comment = gql('''
      mutation deleteComment(\$comment_id: ID!){
        deleteComment(comment_id: \$comment_id)
      }
    ''');
    final result = await _client
        .mutate(MutationOptions(document: delete_comment, variables: {
      'comment_id': comment_id,
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    return comment_id;
  }
}

final commentServiceProvider = Provider<CommentsService>((ref) {
  final client = ref.watch(graphQLClientProvider).value;
  return CommentsService(client, ref);
});
