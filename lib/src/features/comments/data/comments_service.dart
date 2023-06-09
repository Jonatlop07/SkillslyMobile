import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_collection.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_content_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_search_params.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_accessor.dart';
import '../../../shared/exception/request_exception.dart';

class CommentsService {
  CommentsService(this._client, Ref ref) : _authStateAccessor = AuthStateAccessor(ref);
  final GraphQLClient _client;
  final AuthStateAccessor _authStateAccessor;

  String? get _userId => _authStateAccessor.getAuthStateController().state?.id;

  Future<CommentCollection> getComments(CommentSearchParams search_params) async {
    final limit = search_params.pagination.limit;
    final page = search_params.pagination.page;
    final query_comments = gql('''
      query queryComments(\$post_id: ID!, \$comments_pagination: PaginationParams!){
        queryComments(post_id: \$post_id, comments_pagination: \$comments_pagination){
          _id
          owner_id
          description
          media_locator
          media_type
          created_at
          inner_comment_count
          updated_at
          owner {
            name
            email
          }
        }
      }
    ''');
    final result = await _client.query(QueryOptions(document: query_comments, variables: {
      'post_id': search_params.postId,
      'comments_pagination': {
        'page': page,
        'limit': limit,
      }
    }));
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }

    final queryResult = result.data?['queryComments'];
    final List<CommentDetails> comments = [];
    queryResult.forEach((comment) => {comments.add(CommentDetails.fromJson(comment))});
    print(comments);
    return CommentCollection(comments: comments);
  }

  Future<CommentDetails> createComment(
      String post_id, String comment, String media_locator, String media_type) async {
    print('creating');
    final create_comment = gql('''
      mutation createComment(\$comment_details: NewComment!, \$post_id: ID!){
        createComment(comment_details: \$comment_details, post_id: \$post_id){
          _id
          owner_id
          description
          media_locator
          media_type
          created_at
          owner {
            name
            email
          }
        }
      }
    ''');
    final result = await _client.mutate(MutationOptions(document: create_comment, variables: {
      'comment_details': {
        'owner_id': _userId,
        'description': comment,
        'media_locator': media_locator,
        'media_type': media_type
      },
      'post_id': post_id,
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }

    print(result.data?['createComment']);

    return CommentDetails.fromJson(result.data?['createComment'] as Map<String, dynamic>);
  }

  Future<CommentContentDetails> editComment(
      String comment_id, String description, String media_locator, String media_type) async {
    final edit_comment = gql('''
      mutation updateComment(\$comment_id: ID!, \$new_content: CommentContentUpdate!){
        updateComment(comment_id: \$comment_id, new_content: \$new_content){
          description
          media_locator
          media_type
        }
      }
    ''');
    final result = await _client.mutate(MutationOptions(document: edit_comment, variables: {
      'comment_id': comment_id,
      'new_content': {
        'description': description,
        'media_locator': media_locator,
        'media_type': media_type
      },
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    return CommentContentDetails.fromJson(result.data?['updateComment'] as Map<String, dynamic>);
  }

  Future<String> deleteComment(String comment_id) async {
    final delete_comment = gql('''
      mutation deleteComment(\$comment_id: ID!){
        deleteComment(comment_id: \$comment_id)
      }
    ''');
    final result = await _client.mutate(MutationOptions(document: delete_comment, variables: {
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

final postCommentsProvider =
    FutureProvider.autoDispose.family<CommentCollection, CommentSearchParams>(
  (ref, CommentSearchParams searchParams) async {
    return ref.read(commentServiceProvider).getComments(searchParams);
  },
);
