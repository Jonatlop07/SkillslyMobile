import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/shared/state/app_user.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/shared/exception/request_exception.dart';
import 'package:skillsly_ma/src/features/authentication/domain/sign_in_response.dart';
import 'package:skillsly_ma/src/features/authentication/domain/sign_up_details.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_accessor.dart';

class AuthService {
  AuthService(this._client, Ref ref)
      : _authStateAccessor = AuthStateAccessor(ref);

  final GraphQLClient _client;
  final AuthStateAccessor _authStateAccessor;

  Stream<AppUser?> authStateChanges() =>
      _authStateAccessor.getAuthStateController().stream;
  AppUser? get currentUser => _authStateAccessor.getAuthStateController().state;

  bool isLoggedIn() {
    return _authStateAccessor.getAuthStateController().state != null;
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

    final result = await _client.mutate(
      MutationOptions(
        document: signInUser,
        variables: {'email': email, 'password': password},
      ),
    );

    print(result.data?['login']);
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
              .hardcoded);
    }
    final signInResponse =
        SignInResponse.fromJson(result.data?['login'] as Map<String, dynamic>);
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
    final result = await _client.mutate(
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
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
              .hardcoded);
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
    _authStateAccessor.getAuthStateController().state = user;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(graphQLClientProvider).value;
  return AuthService(client, ref);
});

final authStateChangesProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final authRepository = ref.watch(authServiceProvider);
  return authRepository.authStateChanges();
});
