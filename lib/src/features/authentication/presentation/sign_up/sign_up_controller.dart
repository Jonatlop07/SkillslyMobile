import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/features/authentication/data/auth_service.dart';
import 'package:skillsly_ma/src/features/authentication/domain/sign_up_details.dart';

import 'sign_up_state.dart';

class SignUpController extends StateNotifier<SignUpState> {
  SignUpController({
    required SignUpFormType formType,
    required this.authService,
  }) : super(SignUpState(formType: formType));

  final AuthService authService;

  Future<bool> submit(SignUpDetails signUpDetails) async {
    state = state.copyWith(value: const AsyncValue.loading());
    final value = await AsyncValue.guard(() => _signUp(signUpDetails));
    state = state.copyWith(value: value);
    return value.hasError == false;
  }

  Future<void> _signUp(SignUpDetails signUpDetails) {
    switch (state.formType) {
      case SignUpFormType.signUp:
        return authService.signUp(signUpDetails);
    }
  }

  void updateFormType(SignUpFormType formType) {
    state = state.copyWith(formType: formType);
  }
}

final signUpControllerProvider = StateNotifierProvider.autoDispose
    .family<SignUpController, SignUpState, SignUpFormType>((ref, formType) {
  final authService = ref.watch(authServiceProvider);
  return SignUpController(
    authService: authService,
    formType: formType,
  );
});
