import 'routes.dart';

class RoutePaths {
  static const home = '/';
  static const signIn = '/${Routes.signIn}';
  static const signUp = '/${Routes.signUp}';
  static const passwordRecovery = '/${Routes.passwordRecovery}';
  static const passwordReset = '/${Routes.passwordReset}';
  static const account = '/${Routes.account}';
  static const feed = '/${Routes.feed}';
  static postsOfUser(ownerId) => '/${Routes.feed}/${Routes.postsOfUser}/$ownerId';
  static const credentials = '/${Routes.account}/${Routes.credentials}';
}
