import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/post/domain/new_post_details.dart';
import 'package:skillsly_ma/src/features/post/domain/post_model.dart';
import 'package:skillsly_ma/src/features/post/domain/post_owner.dart';
import 'package:skillsly_ma/src/features/post/domain/post_updates.dart';
import 'package:skillsly_ma/src/features/post/domain/user_post_collection.dart';
import 'package:skillsly_ma/src/shared/exception/request_exception.dart';
import 'package:skillsly_ma/src/shared/state/app_user.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_accessor.dart';

class PostService {
  PostService(this._client, Ref ref)
      : _authStateAccessor = AuthStateAccessor(ref);

  final GraphQLClient _client;
  final AuthStateAccessor _authStateAccessor;
  AppUser? get _user => _authStateAccessor.getAuthStateController().state;

  Future<PostModel> getPostById(String postId) async {
    final postById = gql('''
      query postById(\$post_id: ID!) {
        postById(post_id: \$post_id) {
          id
          description
          created_at
          updated_at
          privacy
          content_element {
            description
            media_locator
            media_type
          }
        }
      }
    ''');
    final result = await _client.query(
      QueryOptions(
        document: postById,
        variables: {
          'post_id': postId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
        'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
            .hardcoded,
      );
    }
    final Map<String, dynamic> post = result.data?['postById'];
    post['owner'] = {'id': _user!.id, 'name': 'Yo'};
    return PostModel.fromJson(post);
  }

  Future<List<PostModel>> getPostsOfFriends() async {
    final postsByOwnerId = gql('''
      query postsByOwnerId(\$owner_id: String!) {
        postsByOwnerId(owner_id: \$owner_id) {
          posts {
            id
            description
            created_at
            updated_at
            privacy
            content_element {
              description
              media_locator
              media_type
            }
          }
          owner {
            id
            name
          }
        }
      }
    ''');
    final result = await _client.query(
      QueryOptions(document: postsByOwnerId),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
        'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
            .hardcoded,
      );
    }
    final List<dynamic> posts = result.data?['postsByOwnerId'];
    return posts.map((post) => PostModel.fromJson(post)).toList();
  }

  Future<UserPostCollection> postsOfUser(String userId) async {
    final postsByOwnerId = gql('''
      query postsByOwnerId(\$owner_id: String!) {
        postsByOwnerId(owner_id: \$owner_id) {
          posts {
            id
            description
            created_at
            updated_at
            privacy
            content_element {
              description
              media_locator
              media_type
            }
          }
          owner {
            id
            name
          }
        }
      }
    ''');
    final result = await _client.query(
      QueryOptions(
        document: postsByOwnerId,
        variables: {
          'owner_id': userId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
        'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
            .hardcoded,
      );
    }
    final List<dynamic> posts = result.data?['postsByOwnerId']['posts'];
    final Map<String, dynamic> owner = result.data?['postsByOwnerId']['owner'];
    return UserPostCollection(
      posts: posts.map((post) {
        post['owner'] = {'id': '', 'name': ''};
        return PostModel.fromJson(post);
      }).toList(),
      owner: PostOwner.fromJson(owner),
    );
  }

  Future<PostModel> createPost(NewPostDetails newPostDetails) async {
    final createPost = gql('''
      mutation createPost(\$post_details: NewPostInputData!) {
        createPost(post_data: \$post_details) {
          id
          description
          created_at
          privacy
          content_element {
            description
            media_locator
            media_type
          }
        }
      }
    ''');
    final result = await _client.mutate(
      MutationOptions(
        document: createPost,
        variables: {'post_details': newPostDetails.toMap(_user!.id)},
      ),
    );

    print(result.data);
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
        'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
            .hardcoded,
      );
    }
    final Map<String, dynamic> createdPost = result.data?['createPost'];
    createdPost['owner'] = {'id': _user!.id, 'name': 'Yo'};
    return PostModel.fromJson(
        result.data?['createPost'] as Map<String, dynamic>);
  }

  Future<PostModel> updatePost(PostUpdates postUpdates) async {
    final updatePost = gql('''
      mutation updatePost(\$post_updates: UpdatePostInputData!) {
        updatePost(post_data: \$post_updates) {
          id
          description
          created_at
          privacy
          content_element {
            description
            media_locator
            media_type
          }
        }
      }
    ''');
    final result = await _client.mutate(
      MutationOptions(
        document: updatePost,
        variables: {'post_updates': postUpdates.toMap()},
      ),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
        'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
            .hardcoded,
      );
    }
    final Map<String, dynamic> updatedPost = result.data?['updatePost'];
    updatedPost['owner'] = {'id': _user!.id, 'name': 'Yo'};
    return PostModel.fromJson(
        result.data?['updatePost'] as Map<String, dynamic>);
  }

  Future<void> deletePost(String postId) async {
    final deletePost = gql('''
      mutation deletePost(\$post_id: String!) {
        deletePost(post_id: \$post_id) {
          id
        }
      }
    ''');
    final result = await _client.mutate(
      MutationOptions(
        document: deletePost,
        variables: {'post_id': postId},
      ),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
        'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
            .hardcoded,
      );
    }
  }
}

final postServiceProvider = Provider<PostService>((ref) {
  final client = ref.watch(graphQLClientProvider).value;
  return PostService(client, ref);
});

final postsOfUserProvider = FutureProvider.autoDispose.family<UserPostCollection, String>(
  (ref, String userId) async {
    final response = await ref.read(postServiceProvider).postsOfUser(userId);
    ref.keepAlive();
    return response;
  },
);

final getPostsOfFriendsProvider = FutureProvider<List<PostModel>>(
  (ref) {
    return ref.read(postServiceProvider).getPostsOfFriends();
  },
);
