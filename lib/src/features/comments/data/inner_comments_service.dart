import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_content_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/inner_comment_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/search_comments_pagination.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_accessor.dart';
import '../../../shared/exception/request_exception.dart';

class InnerCommentsService {
  InnerCommentsService(this._client, Ref ref)
      : _authStateAccessor = AuthStateAccessor(ref);
  final GraphQLClient _client;
  final AuthStateAccessor _authStateAccessor;

  String? get _userId => _authStateAccessor.getAuthStateController().state?.id;

  Future<List<InnerCommentDetails>> getInnerComments(
      String comment_id, SearchCommentsPaginationDetails? query_params) async {
    final limit = query_params?.limit ?? 0;
    final page = query_params?.page ?? 0;
    final query_inner_comments = gql('''
      query queryInnerComments(\$comment_id: ID!, \$inner_comments_pagination: PaginationParams!){
        queryInnerComments(inner_comments_pagination: \$inner_comments_pagination, comment_id: \$comment_id){
          _id
          owner_id
          description
          media_locator
          created_at
          comment_id
          updated_at
        }
      }
    ''');
    final result = await _client
        .query(QueryOptions(document: query_inner_comments, variables: {
      'inner_comments_pagination': {
        'limit': limit,
        'page': page,
      },
      'comment_id': comment_id,
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    final queryResult = result.data?['queryInnerComments'];
    final List<InnerCommentDetails> innerComments = [];
    queryResult.forEach((comment) =>
        {innerComments.add(InnerCommentDetails.fromJson(comment))});

    return innerComments;
  }

  Future<InnerCommentDetails> createInnerComment(
      String comment_id, String comment, String media_locator) async {
    final create_inner_comment = gql('''
      mutation createInnerComment(\$inner_comment_details: NewInnerComment!, \$comment_id: ID!){
        createInnerComment(inner_comment_details: \$inner_comment_details, comment_id: \$comment_id){
          _id
          description
          media_locator
          created_at
          comment_id
          owner_id
        }
      }
    ''');
    final result = await _client
        .mutate(MutationOptions(document: create_inner_comment, variables: {
      'inner_comment_details': {
        'owner_id': _userId,
        'description': comment,
        'media_locator': media_locator
      },
      'comment_id': comment_id,
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    return InnerCommentDetails.fromJson(
        result.data?['createInnerComment'] as Map<String, dynamic>);
  }

  Future<CommentContentDetails> editInnerComment(
      String inner_comment_id, String description, String media_locator) async {
    final edit_inner_comment = gql('''
      mutation updateInnerComment(\$inner_comment_id: ID!, \$new_content: CommentContentUpdate!){
        updateInnerComment(inner_comment_id: \$inner_comment_id, new_content: \$new_content){
          description
          media_locator
        }
      }
    ''');
    final result = await _client
        .mutate(MutationOptions(document: edit_inner_comment, variables: {
      'inner_comment_id': inner_comment_id,
      'new_content': {
        'description': description,
        'media_locator': media_locator
      },
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    return CommentContentDetails.fromJson(
        result.data?['updateInnerComment'] as Map<String, dynamic>);
  }

  Future<String> deleteInnerComment(String inner_comment_id) async {
    final delete_inner_comment = gql('''
      mutation deleteInnerComment(\$inner_comment_id: ID!){
        deleteInnerComment(inner_comment_id: \$inner_comment_id)
      }
    ''');
    final result = await _client
        .mutate(MutationOptions(document: delete_inner_comment, variables: {
      'inner_comment_id': inner_comment_id,
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    return inner_comment_id;
  }
}

final innerCommentServiceProvider = Provider<InnerCommentsService>((ref) {
  final client = ref.watch(graphQLClientProvider).value;
  return InnerCommentsService(client, ref);
});
