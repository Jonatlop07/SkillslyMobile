import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/users/domain/search_user_details.dart';
import 'package:skillsly_ma/src/shared/types/pagination_details.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_accessor.dart';
import '../../../shared/exception/request_exception.dart';

class SearchService {
  SearchService(this._client, Ref ref)
      : _authStateAccessor = AuthStateAccessor(ref);
  final GraphQLClient _client;
  final AuthStateAccessor _authStateAccessor;

  String? get _userId => _authStateAccessor.getAuthStateController().state?.id;

  Future<List<SearchUserDetails>> searchUser(
      String search_input, PaginationDetails? query_params) async {
    final search_users = gql('''
      query users(\$search_params: SearchParams!){
        users(search_params: \$search_params){
          name
          email
          date_of_birth
          id
        }
      }
    ''');
    final result =
        await _client.query(QueryOptions(document: search_users, variables: {
      'search_params': {
        'email': search_input,
        'name': search_input,
        'limit': query_params?.limit,
        'offset': query_params?.offset
      }
    }));

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }

    final users = result.data?['users'];

    final List<SearchUserDetails> searchedUsers = [];
    users.forEach(
        (user) => {searchedUsers.add(SearchUserDetails.fromJson(user))});

    if (result.hasException || (result.isLoading && result.data != null)) {
      throw BackendRequestException(
        result.exception != null
            ? result.exception.toString()
            : 'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
                .hardcoded,
      );
    }

    return searchedUsers;
  }
}

final searchServiceProvider = Provider<SearchService>((ref) {
  final client = ref.watch(graphQLClientProvider).value;
  return SearchService(client, ref);
});
