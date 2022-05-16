import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_provider.dart';

import 'app_user.dart';

class AuthStateAccessor {
  AuthStateAccessor(this.ref);
  final Ref ref;

  StateController<AppUser?> getAuthStateController() {
    return ref.watch(authStateProvider.notifier);
  }
}
