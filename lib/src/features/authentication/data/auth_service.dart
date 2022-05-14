import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/core/domain/app_user.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/shared/exception/request_exception.dart';
import 'package:skillsly_ma/src/features/authentication/domain/sign_in_response.dart';
import 'package:skillsly_ma/src/features/authentication/domain/sign_up_details.dart';
import 'package:skillsly_ma/src/shared/state/auth_token_provider.dart';
import 'package:skillsly_ma/src/shared/utils/app_in_memory_store.dart';

class AuthService {
  AuthService(this._ref);

  final Ref _ref;

  final _authState = AppInMemoryStore<AppUser?>(null);

  GraphQLClient get client => _ref.read(graphQLClientProvider).value;

  Stream<AppUser?> authStateChanges() => _authState.stream;
  AppUser? get currentUser => _authState.value;

  bool isLoggedIn() {
    return currentUser != null;
  }

  Future<void> signIn(String email, String password) async {
    final signInUser = gql('''
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
          access_token
        }
      }
    ''');

    final result = await client.mutate(
      MutationOptions(
        document: signInUser,
        variables: {'email': email, 'password': password},
      ),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'.hardcoded);
    }
    final signInResponse = SignInResponse.fromJson(result.data?['login'] as Map<String, dynamic>);
    _createNewUser(signInResponse);
  }

  Future<void> signUp(SignUpDetails signUpDetails) async {
    final signUpUser = gql('''
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
        }
      }
    ''');
    final result = await client.mutate(
      MutationOptions(
        document: signUpUser,
        variables: signUpDetails.toMap(),
      ),
    );
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'.hardcoded);
    }
    signIn(signUpDetails.email, signUpDetails.password);
  }

  void logOut() {
    _setAuthState(null);
  }

  void dispose() => {};

  void _createNewUser(SignInResponse signInResponse) {
    AppUser user = AppUser(
      id: signInResponse.id,
      email: signInResponse.email,
      accessToken: signInResponse.accessToken,
    );
    _setAuthState(user);
  }

  void _setAuthState(AppUser? user) {
    _authState.value = user;
    _ref.read(authStateProvider.notifier).state = user;
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

final authStateChangesProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final authRepository = ref.watch(authServiceProvider);
  return authRepository.authStateChanges();
});
