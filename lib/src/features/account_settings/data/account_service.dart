import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/account_settings/domain/update_user_account_details.dart';
import 'package:skillsly_ma/src/features/account_settings/domain/user_account_details.dart';
import 'package:skillsly_ma/src/shared/exception/request_exception.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_accessor.dart';

class AccountService {
  AccountService(this._client, Ref ref) : _authStateAccessor = AuthStateAccessor(ref);

  final GraphQLClient _client;
  final AuthStateAccessor _authStateAccessor;

  String? get _userId => _authStateAccessor.getAuthStateController().state?.id;

  Future<UserAccountDetails> getUserAccountDetails() async {
    final getUserAccountDetails = gql('''
      query user(\$id: String!) {
        user(id: \$id) {
          email
          name
          date_of_birth
          gender
          created_at
          updated_at
        }
      }
    ''');
    final result = await _client.query(QueryOptions(
      document: getUserAccountDetails,
      variables: {
        'id': _userId,
      },
    ));
    if (result.hasException || (result.isLoading && result.data != null)) {
      throw BackendRequestException(
        result.exception != null
            ? result.exception.toString()
            : 'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'.hardcoded,
      );
    }
    return UserAccountDetails.fromJson(result.data?['user'] as Map<String, dynamic>);
  }

  Future<UserAccountDetails> updateAccountDetails(UpdateUserAccountDetails accountDetails) async {
    final updateUserAccountDetails = gql('''
      mutation updateUserAccount(
        \$user_id: ID!,
        \$updates: UserAccountUpdates!
      ) {
        updateUserAccount(
          user_id: \$user_id,
          updates: \$updates
        ) {
          email
          name
          date_of_birth
          gender
          created_at
          updated_at
        }
      }
    ''');
    final result = await _client.mutate(
      MutationOptions(
        document: updateUserAccountDetails,
        variables: {
          'user_id': _userId,
          'updates': {
            'email': accountDetails.email,
            'name': accountDetails.name,
            'date_of_birth': accountDetails.dateOfBirth,
            'gender': accountDetails.gender
          }
        },
      ),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'.hardcoded);
    }
    return UserAccountDetails.fromJson(result.data?['updateUserAccount'] as Map<String, dynamic>);
  }

  Future<void> updateCredentials(String? email, String? password) async {}

  Future<void> deleteAccount(String password) async {
    final deleteAccount = gql('''
      mutation deleteAccount(
        \$user_id: ID!,
        \$password: String
      ) {
        deleteUserAccount() {
          user_id: \$user_id,
          password: \$password
        } {
          email
        }
      }
    ''');
    final result = await _client.mutate(
      MutationOptions(
        document: deleteAccount,
        variables: {'user_id': _userId, 'password': password},
      ),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'.hardcoded);
    }
  }
}

final accountServiceProvider = Provider<AccountService>((ref) {
  final client = ref.watch(graphQLClientProvider).value;
  return AccountService(client, ref);
});
