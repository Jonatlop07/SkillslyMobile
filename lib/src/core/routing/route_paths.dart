import 'routes.dart';

class RoutePaths {
  static const auth = '/${Routes.auth}';
  static const signIn = '${RoutePaths.auth}/${Routes.signIn}';
  static const signUp = '${RoutePaths.auth}/${Routes.signUp}';
  static const passwordRecovery =
      '${RoutePaths.auth}/${Routes.passwordRecovery}';
  static const passwordReset = '${RoutePaths.auth}/${Routes.passwordReset}';

  static const account = '/${Routes.account}';
  static const feed = '/${Routes.feed}';
}
