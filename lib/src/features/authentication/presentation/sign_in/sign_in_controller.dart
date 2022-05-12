import 'package:skillsly_ma/src/features/authentication/data/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sign_in_state.dart';

class SignInController extends StateNotifier<SignInState> {
  SignInController({
    required SignInFormType formType,
    required this.authService,
  }) : super(SignInState(formType: formType));

  final AuthService authService;

  Future<bool> submit(String email, String password) async {
    state = state.copyWith(value: const AsyncValue.loading());
    final value = await AsyncValue.guard(() => _authenticate(email, password));
    state = state.copyWith(value: value);
    return value.hasError == false;
  }

  Future<void> _authenticate(String email, String password) {
    switch (state.formType) {
      case SignInFormType.signIn:
        return authService.signIn(email, password);
      case SignInFormType.twoFactorSignIn:
        return authService.signIn(email, password);
    }
  }

  void updateFormType(SignInFormType formType) {
    state = state.copyWith(formType: formType);
  }
}

final signInControllerProvider =
    StateNotifierProvider.autoDispose.family<SignInController, SignInState, SignInFormType>(
  (ref, formType) {
    final authService = ref.watch(authServiceProvider);
    return SignInController(
      authService: authService,
      formType: formType,
    );
  },
);
