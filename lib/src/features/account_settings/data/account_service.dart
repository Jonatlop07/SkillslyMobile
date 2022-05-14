import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/account_settings/domain/update_user_account_details.dart';
import 'package:skillsly_ma/src/features/account_settings/domain/user_account_details.dart';
import 'package:skillsly_ma/src/shared/exception/request_exception.dart';
import 'package:skillsly_ma/src/shared/state/auth_token_provider.dart';

class AccountService {
  AccountService(this._ref);

  final Ref _ref;

  GraphQLClient get client => _ref.read(graphQLClientProvider).value;

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
    final String? userId = _ref.read(authStateProvider)?.id;
    final result = await client
        .query(QueryOptions(document: getUserAccountDetails, variables: {'id': userId}));
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
    final String? userId = _ref.read(authStateProvider)?.id;
    final result = await client.mutate(
      MutationOptions(
        document: updateUserAccountDetails,
        variables: {
          'user_id': userId,
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
    return UserAccountDetails.fromJson(result.data?['user'] as Map<String, dynamic>);
  }
}

final accountServiceProvider = Provider<AccountService>((ref) => AccountService(ref));
