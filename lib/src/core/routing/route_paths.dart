import 'routes.dart';

class RoutePaths {
  static const home = '/';
  static const signIn = '/${Routes.signIn}';
  static const signUp = '/${Routes.signUp}';
  static const passwordRecovery = '/${Routes.passwordRecovery}';
  static const passwordReset = '/${Routes.passwordReset}';
  static const account = '/${Routes.account}';
  static const feed = '/${Routes.feed}';
  static const searchUser = '/${Routes.searchUser}';
  static postsOfUser(ownerId) =>
      '/${Routes.feed}/${Routes.postsOfUser}/$ownerId';
  static const credentials = '/${Routes.account}/${Routes.credentials}';
  static comments(postId) => '/${Routes.comments}/$postId';
}
