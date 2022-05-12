import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/core/domain/app_user.dart';
import 'package:skillsly_ma/src/features/authentication/domain/sign_in_response.dart';
import 'package:skillsly_ma/src/features/authentication/domain/sign_up_details.dart';
import 'package:skillsly_ma/src/shared/utils/app_in_memory_store.dart';

class AuthService {
  AuthService(this._client);
  final _authState = AppInMemoryStore<AppUser?>(null);

  final ValueNotifier<GraphQLClient> _client;

  GraphQLClient get client => _client.value;

  Stream<AppUser?> authStateChanges() => _authState.stream;
  AppUser? get currentUser => _authState.value;

  Future<void> signIn(String email, String password) async {
    /*final signInUser = gql('''
      mutation login(
        \$email: String,
        \$password: String
      ) {
        login(
          credentials: {
            email: \$email,
            password: \$password
          }
        ) {
          id
          email
        }
      }
    ''');

    final result = await _client.mutate(
      MutationOptions(
        document: signInUser,
        variables: {'email': email, 'password': password},
      ),
    );
    if (result.hasException) {
    } else if (result.isLoading && result.data != null) {
    } else {
      final signInResponse = SignInResponse.fromJson(result.data?['login'] as Map<String, dynamic>);
      _createNewUser(signInResponse);
    }*/
    final m = gql('''
    mutation createCategory(\$cate: String!, \$desc: String!) {
      createCategory(category: {
        name: \$cate,
        description: \$desc
      }) {
        name
      }
    }
    ''');
    final result = await client.mutate(MutationOptions(
        document: m,
        variables: const {'cate': 'Categoria Jeisson', 'desc': 'Descripción - Categoría Jeisson'}));
    print(result);
  }

  Future<void> signUp(SignUpDetails signUpDetails) async {
    /*final signUpUser = gql('''
      mutation createUserAccount(
        \$email: String!,
        \$password: String!,
        \$name: String!,
        \$date_of_birth: String!,
        \$gender: String!
      ) {
        createUserAccount(
          account_details: {
            email: \$email,
            password: \$password,
            name: \$name,
            date_of_birth: \$date_of_birth,
            gender: \$gender,
          }
        ) {
          id
          email
          access_token
        }
      }
    ''');
    final result = await _client.mutate(
      MutationOptions(
        document: signUpUser,
        variables: signUpDetails.toMap(),
      ),
    );
    print(result);
    if (result.hasException) {
    } else if (result.isLoading && result.data != null) {
    } else {
      signIn(signUpDetails.email, signUpDetails.password);
    }*/
  }

  void dispose() => {};

  void _createNewUser(SignInResponse signInResponse) {
    _authState.value = AppUser(
      id: signInResponse.id,
      email: signInResponse.email,
      accessToken: signInResponse.accessToken,
    );
  }
}

final authServiceProvider = Provider<AuthService>(
    (ref) => AuthService(ref.watch(graphQLClientProvider))
    //final client = ref.watch(graphQLClientProvider);
    /*final auth = AuthService(/*client.value*/);
  ref.onDispose(() => auth.dispose());
  return auth;*/
    );

final authStateChangesProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final authRepository = ref.watch(authServiceProvider);
  return authRepository.authStateChanges();
});
