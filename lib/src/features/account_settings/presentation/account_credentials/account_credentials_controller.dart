import 'package:skillsly_ma/src/features/account_settings/data/account_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_credentials_state.dart';

class AccountCredentialsController extends StateNotifier<AccountCredentialsState> {
  AccountCredentialsController({
    required AccountCredentialsFormType formType,
    required this.accountService,
  }) : super(AccountCredentialsState(formType: formType));

  final AccountService accountService;

  Future<bool> submit(String email, String password) async {
    state = state.copyWith(value: const AsyncValue.loading());
    final value = await AsyncValue.guard(() => _submit(password, email));
    state = state.copyWith(value: value);
    return !value.hasError;
  }

  Future<void> _submit(String password, String? email) {
    if (state.formType == AccountCredentialsFormType.deleteAccount) {
      return accountService.deleteAccount(password);
    }
    return accountService.updateCredentials(email, password);
  }

  void updateFormType(AccountCredentialsFormType formType) {
    state = state.copyWith(formType: formType);
  }
}

final accountCredentialsControllerProvider = StateNotifierProvider.autoDispose
    .family<AccountCredentialsController, AccountCredentialsState, AccountCredentialsFormType>(
  (ref, formType) {
    final accountService = ref.watch(accountServiceProvider);
    return AccountCredentialsController(
      accountService: accountService,
      formType: formType,
    );
  },
);
